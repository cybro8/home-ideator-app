import pytest
pytestmark = pytest.mark.asyncio

async def test_list_users_as_admin(client, admin_token, unique_users):
    r = await client.get("/users", headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200
    assert len(r.json()) >= len(unique_users)

async def test_list_users_as_eu_admin(client, eu_admin_token):
    r = await client.get("/users", headers={"Authorization": f"Bearer {eu_admin_token}"})
    assert r.status_code == 200

async def test_list_users_ml_user_forbidden(client, ml_token):
    r = await client.get("/users", headers={"Authorization": f"Bearer {ml_token}"})
    assert r.status_code == 403

async def test_search_users(client, admin_token):
    r = await client.get("/users?search=ravi", headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200

async def test_get_user_detail(client, admin_token, unique_users):
    uid = unique_users[0]["uid"]
    r = await client.get(f"/users/{uid}", headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200
    assert r.json()["uid"] == uid

async def test_get_nonexistent_user(client, admin_token):
    r = await client.get("/users/no-such-uid", headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 404

async def test_create_user(client, admin_token):
    r = await client.post("/users",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"username": "brand_new_user", "email": "brand@test.com", "password": "Test@1234"})
    assert r.status_code == 201
    assert r.json()["username"] == "brand_new_user"

async def test_create_user_duplicate_email(client, eu_admin_token, unique_users):
    uid = unique_users[0]["uid"]
    email = f"{uid}@test.com"
    r = await client.post("/users",
        headers={"Authorization": f"Bearer {eu_admin_token}"},
        json={"username": "dup_user", "email": email, "password": "Test@1234"})
    assert r.status_code == 409

async def test_update_user(client, admin_token, unique_users):
    uid = unique_users[0]["uid"]
    r = await client.patch(f"/users/{uid}",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"username": "updated_ravi"})
    assert r.status_code == 200

async def test_disable_user(client, eu_admin_token, unique_users):
    uid = unique_users[1]["uid"]
    r = await client.patch(f"/users/{uid}/status",
        headers={"Authorization": f"Bearer {eu_admin_token}"},
        json={"is_active": False})
    assert r.status_code == 200
    assert r.json()["is_active"] is False

async def test_enable_user(client, eu_admin_token, unique_users):
    uid = unique_users[1]["uid"]
    r = await client.patch(f"/users/{uid}/status",
        headers={"Authorization": f"Bearer {eu_admin_token}"},
        json={"is_active": True})
    assert r.status_code == 200
    assert r.json()["is_active"] is True

async def test_get_user_devices(client, admin_token, unique_users):
    uid = unique_users[0]["uid"]
    r = await client.get(f"/users/{uid}/devices",
        headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200
    assert isinstance(r.json(), list)

async def test_get_user_products(client, admin_token, unique_users):
    uid = unique_users[0]["uid"]
    r = await client.get(f"/users/{uid}/products",
        headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200

async def test_get_live_data(client, admin_token, unique_users):
    uid = unique_users[0]["uid"]
    r = await client.get(f"/users/{uid}/data/live",
        headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200
    assert isinstance(r.json(), list)

async def test_delete_user(client, admin_token):
    create = await client.post("/users",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"username": "to_del_user", "email": "del_user@test.com", "password": "Test@1234"})
    uid = create.json()["uid"]
    r = await client.delete(f"/users/{uid}", headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 204
