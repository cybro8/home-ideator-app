import pytest
pytestmark = pytest.mark.asyncio

async def test_browse_products(client, user_token, shop_rows):
    r = await client.get("/shop/products",
        headers={"Authorization": f"Bearer {user_token}"})
    assert r.status_code == 200
    assert len(r.json()) >= len(shop_rows)

async def test_get_product_detail(client, user_token):
    products = (await client.get("/shop/products",
        headers={"Authorization": f"Bearer {user_token}"})).json()
    pid = products[0]["id"]
    r = await client.get(f"/shop/products/{pid}",
        headers={"Authorization": f"Bearer {user_token}"})
    assert r.status_code == 200
    assert "rating" in r.json()

async def test_get_nonexistent_product(client, user_token):
    r = await client.get("/shop/products/999999",
        headers={"Authorization": f"Bearer {user_token}"})
    assert r.status_code == 404

async def test_seeded_products_from_csv(client, user_token, shop_rows):
    products = (await client.get("/shop/products",
        headers={"Authorization": f"Bearer {user_token}"})).json()
    names = {p["name"] for p in products}
    assert shop_rows[0]["Name"] in names
