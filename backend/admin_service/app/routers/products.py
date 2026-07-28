from fastapi import APIRouter, Depends, HTTPException
from app.core.rbac import admin_only
from app.db.connections import get_pool
from app.models.product import ProductCreate, ProductUpdate, ProductOut
import aiomysql

router = APIRouter(prefix="/products", tags=["products"])


@router.get("", response_model=list[ProductOut])
async def list_products(current: dict = Depends(admin_only)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute("SELECT * FROM products ORDER BY id DESC")
            return [ProductOut(**r) for r in await cur.fetchall()]


@router.post("", response_model=ProductOut, status_code=201)
async def create_product(body: ProductCreate, current: dict = Depends(admin_only)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(
                "INSERT INTO products (name, category, cost, discount_pct, rating, "
                "ecom, ecom_logo, image_url, website_url, in_stock) "
                "VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
                (body.name, body.category, body.cost, body.discount_pct, body.rating,
                 body.ecom, body.ecom_logo, body.image_url, body.website_url, body.in_stock),
            )
            pid = cur.lastrowid
            await cur.execute("SELECT * FROM products WHERE id = %s", (pid,))
            return ProductOut(**await cur.fetchone())


@router.get("/{product_id}", response_model=ProductOut)
async def get_product(product_id: int, current: dict = Depends(admin_only)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute("SELECT * FROM products WHERE id = %s", (product_id,))
            row = await cur.fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Product not found.")
    return ProductOut(**row)


@router.patch("/{product_id}", response_model=ProductOut)
async def update_product(product_id: int, body: ProductUpdate, current: dict = Depends(admin_only)):
    updates = {k: v for k, v in body.model_dump().items() if v is not None}
    if not updates:
        raise HTTPException(status_code=400, detail="No fields to update.")
    set_clause = ", ".join(f"{k} = %s" for k in updates)
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(
                f"UPDATE products SET {set_clause} WHERE id = %s",
                (*updates.values(), product_id),
            )
            await cur.execute("SELECT * FROM products WHERE id = %s", (product_id,))
            row = await cur.fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Product not found.")
    return ProductOut(**row)


@router.delete("/{product_id}", status_code=204)
async def delete_product(product_id: int, current: dict = Depends(admin_only)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor() as cur:
            affected = await cur.execute("DELETE FROM products WHERE id = %s", (product_id,))
    if not affected:
        raise HTTPException(status_code=404, detail="Product not found.")
