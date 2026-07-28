import aiomysql
from fastapi import APIRouter, Depends, HTTPException
from app.core.security import get_current_user
from app.db.connections import get_pool
from pydantic import BaseModel, EmailStr

router = APIRouter(prefix="/me", tags=["profile"])

class ProfileUpdate(BaseModel):
    username: str | None = None
    email: EmailStr | None = None

@router.get("")
async def get_profile(current: dict = Depends(get_current_user)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute("SELECT uid,username,email,is_active,created_at FROM end_users WHERE uid=%s", (current["sub"],))
            row = await cur.fetchone()
    if not row: raise HTTPException(404, "User not found.")
    return row

@router.patch("")
async def update_profile(body: ProfileUpdate, current: dict = Depends(get_current_user)):
    updates = {k: v for k, v in body.model_dump().items() if v is not None}
    if not updates: raise HTTPException(400, "No fields to update.")
    set_clause = ", ".join(f"{k} = %s" for k in updates)
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(f"UPDATE end_users SET {set_clause} WHERE uid=%s", (*updates.values(), current["sub"]))
            await cur.execute("SELECT uid,username,email,is_active,created_at FROM end_users WHERE uid=%s", (current["sub"],))
            return await cur.fetchone()

@router.delete("", status_code=204)
async def delete_account(current: dict = Depends(get_current_user)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor() as cur:
            await cur.execute("DELETE FROM end_users WHERE uid=%s", (current["sub"],))
