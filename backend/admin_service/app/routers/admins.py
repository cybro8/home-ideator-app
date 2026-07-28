from fastapi import APIRouter, Depends, HTTPException, status
from app.core.rbac import admin_only
from app.core.security import hash_password
from app.db.connections import get_pool
from app.models.admin import AdminCreate, AdminUpdate, AdminStatusUpdate, AdminOut
import aiomysql

router = APIRouter(prefix="/admins", tags=["admins"])


@router.get("", response_model=list[AdminOut])
async def list_admins(current: dict = Depends(admin_only)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute("SELECT * FROM admin_users ORDER BY created_at DESC")
            return [AdminOut(**row) for row in await cur.fetchall()]


@router.post("", response_model=AdminOut, status_code=201)
async def create_admin(body: AdminCreate, current: dict = Depends(admin_only)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            try:
                await cur.execute(
                    "INSERT INTO admin_users (username, email, password_hash, role) "
                    "VALUES (%s, %s, %s, %s)",
                    (body.username, body.email, hash_password(body.password), body.role),
                )
                new_id = cur.lastrowid
                await cur.execute("SELECT * FROM admin_users WHERE id = %s", (new_id,))
                return AdminOut(**await cur.fetchone())
            except Exception as e:
                if "Duplicate" in str(e):
                    raise HTTPException(status_code=409, detail="Username or email already exists.")
                raise


@router.get("/{admin_id}", response_model=AdminOut)
async def get_admin(admin_id: int, current: dict = Depends(admin_only)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute("SELECT * FROM admin_users WHERE id = %s", (admin_id,))
            row = await cur.fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Admin not found.")
    return AdminOut(**row)


@router.patch("/{admin_id}", response_model=AdminOut)
async def update_admin(admin_id: int, body: AdminUpdate, current: dict = Depends(admin_only)):
    updates = {k: v for k, v in body.model_dump().items() if v is not None}
    if not updates:
        raise HTTPException(status_code=400, detail="No fields to update.")
    set_clause = ", ".join(f"{k} = %s" for k in updates)
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(
                f"UPDATE admin_users SET {set_clause} WHERE id = %s",
                (*updates.values(), admin_id),
            )
            await cur.execute("SELECT * FROM admin_users WHERE id = %s", (admin_id,))
            row = await cur.fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Admin not found.")
    return AdminOut(**row)


@router.patch("/{admin_id}/status", response_model=AdminOut)
async def toggle_admin_status(
    admin_id: int, body: AdminStatusUpdate, current: dict = Depends(admin_only)
):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(
                "UPDATE admin_users SET is_active = %s WHERE id = %s",
                (body.is_active, admin_id),
            )
            await cur.execute("SELECT * FROM admin_users WHERE id = %s", (admin_id,))
            row = await cur.fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Admin not found.")
    return AdminOut(**row)


@router.delete("/{admin_id}", status_code=204)
async def delete_admin(admin_id: int, current: dict = Depends(admin_only)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor() as cur:
            affected = await cur.execute(
                "DELETE FROM admin_users WHERE id = %s", (admin_id,)
            )
    if not affected:
        raise HTTPException(status_code=404, detail="Admin not found.")
