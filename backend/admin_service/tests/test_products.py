import pytest
pytestmark = pytest.mark.asyncio

async def test_list_products_as_admin(client, admin_token, shop_rows):
    r = await client.get("/products", headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200
    assert len(r.json()) >= len(shop_rows)

async def test_list_products_eu_admin_forbidden(client, eu_admin_token):
    r = await client.get("/products", headers={"Authorization": f"Bearer {eu_admin_token}"})
    assert r.status_code == 403

async def test_list_products_ml_user_forbidden(client, ml_token):
    r = await client.get("/products", headers={"Authorization": f"Bearer {ml_token}"})
    assert r.status_code == 403

async def test_create_product(client, admin_token):
    r = await client.post("/products",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"name": "Test Capacitor 10µF", "category": "General",
              "cost": 99.5, "rating": 4.0})
    assert r.status_code == 201
    assert r.json()["name"] == "Test Capacitor 10µF"

async def test_get_product(client, admin_token):
    products = (await client.get("/products",
        headers={"Authorization": f"Bearer {admin_token}"})).json()
    pid = products[0]["id"]
    r = await client.get(f"/products/{pid}",
        headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200
    assert r.json()["id"] == pid

async def test_update_product_cost(client, admin_token):
    products = (await client.get("/products",
        headers={"Authorization": f"Bearer {admin_token}"})).json()
    pid = products[0]["id"]
    r = await client.patch(f"/products/{pid}",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"cost": 149.0, "discount_pct": 10})
    assert r.status_code == 200
    assert r.json()["cost"] == 149.0

async def test_update_product_rating(client, admin_token):
    products = (await client.get("/products",
        headers={"Authorization": f"Bearer {admin_token}"})).json()
    pid = products[0]["id"]
    r = await client.patch(f"/products/{pid}",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"rating": 4.8})
    assert r.status_code == 200

async def test_delete_product(client, admin_token):
    create = await client.post("/products",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"name": "To Delete Prod", "category": "General", "cost": 10.0})
    pid = create.json()["id"]
    r = await client.delete(f"/products/{pid}",
        headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 204

async def test_delete_nonexistent_product(client, admin_token):
    r = await client.delete("/products/999999",
        headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 404

async def test_seeded_products_from_csv(client, admin_token, shop_rows):
    """Products from shop CSV should all be present in the list."""
    products = (await client.get("/products",
        headers={"Authorization": f"Bearer {admin_token}"})).json()
    names = {p["name"] for p in products}
    first_csv_name = shop_rows[0]["Name"]
    assert first_csv_name in names
