import aiomysql
from fastapi import APIRouter, Depends, HTTPException
from app.core.security import get_current_user
from app.db.connections import get_pool

router = APIRouter(prefix="/shop", tags=["shop"])

@router.get("/products")
async def list_products(current: dict = Depends(get_current_user)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute("SELECT * FROM products ORDER BY id DESC")
            return await cur.fetchall()

@router.get("/products/{product_id}")
async def get_product(product_id: int, current: dict = Depends(get_current_user)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute("SELECT * FROM products WHERE id=%s", (product_id,))
            row = await cur.fetchone()
    if not row: raise HTTPException(404, "Product not found.")
    return row
