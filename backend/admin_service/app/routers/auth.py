import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from app.core.security import (
    verify_password, hash_password, create_access_token, get_current_admin,
)
from app.core.rbac import any_admin
from app.db.connections import get_pool
from app.models.admin import LoginRequest, TokenResponse, AdminOut, PasswordChange
import aiomysql

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(
                "SELECT * FROM admin_users WHERE email = %s AND is_active = TRUE",
                (body.email,),
            )
            admin = await cur.fetchone()

    if not admin or not verify_password(body.password, admin["password_hash"]):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Invalid credentials.")

    token = create_access_token({"sub": str(admin["id"]), "role": admin["role"]})
    return TokenResponse(access_token=token, role=admin["role"])


@router.get("/me", response_model=AdminOut)
async def get_me(current: dict = Depends(any_admin)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute("SELECT * FROM admin_users WHERE id = %s", (current["sub"],))
            admin = await cur.fetchone()
    if not admin:
        raise HTTPException(status_code=404, detail="Admin not found.")
    return AdminOut(**admin)


@router.patch("/me", response_model=AdminOut)
async def update_me(body: dict, current: dict = Depends(any_admin)):
    """Any role can update their own non-role fields (username, email)."""
    allowed_fields = {"username", "email"}
    updates = {k: v for k, v in body.items() if k in allowed_fields and v is not None}
    if not updates:
        raise HTTPException(status_code=400, detail="No valid fields to update.")

    set_clause = ", ".join(f"{k} = %s" for k in updates)
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(
                f"UPDATE admin_users SET {set_clause} WHERE id = %s",
                (*updates.values(), current["sub"]),
            )
            await cur.execute("SELECT * FROM admin_users WHERE id = %s", (current["sub"],))
            return AdminOut(**await cur.fetchone())


@router.patch("/me/password")
async def change_password(body: PasswordChange, current: dict = Depends(any_admin)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute("SELECT password_hash FROM admin_users WHERE id = %s",
                              (current["sub"],))
            row = await cur.fetchone()
    if not row or not verify_password(body.current_password, row["password_hash"]):
        raise HTTPException(status_code=401, detail="Current password is incorrect.")

    new_hash = hash_password(body.new_password)
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor() as cur:
            await cur.execute("UPDATE admin_users SET password_hash = %s WHERE id = %s",
                              (new_hash, current["sub"]))
    return {"message": "Password updated successfully."}
