import pytest
pytestmark = pytest.mark.asyncio

async def test_list_admins_as_admin(client, admin_token):
    r = await client.get("/admins", headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200
    assert isinstance(r.json(), list)
    assert len(r.json()) >= 3  # seeded 3 accounts

async def test_list_admins_forbidden_eu_admin(client, eu_admin_token):
    r = await client.get("/admins", headers={"Authorization": f"Bearer {eu_admin_token}"})
    assert r.status_code == 403

async def test_list_admins_forbidden_ml_user(client, ml_token):
    r = await client.get("/admins", headers={"Authorization": f"Bearer {ml_token}"})
    assert r.status_code == 403

async def test_create_admin_as_admin(client, admin_token):
    r = await client.post("/admins",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"username": "newadmin_t", "email": "newadmin_t@test.com",
              "password": "Test@1234", "role": "end_user_admin"})
    assert r.status_code == 201
    assert r.json()["role"] == "end_user_admin"

async def test_create_admin_duplicate_returns_409(client, admin_token):
    r = await client.post("/admins",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"username": "admin_test", "email": "admin@test.com",
              "password": "Test@1234", "role": "admin"})
    assert r.status_code == 409

async def test_create_admin_as_eu_admin_forbidden(client, eu_admin_token):
    r = await client.post("/admins",
        headers={"Authorization": f"Bearer {eu_admin_token}"},
        json={"username": "x", "email": "x@test.com", "password": "Test@1234", "role": "admin"})
    assert r.status_code == 403

async def test_get_admin_by_id(client, admin_token):
    admins = (await client.get("/admins", headers={"Authorization": f"Bearer {admin_token}"})).json()
    aid = admins[0]["id"]
    r = await client.get(f"/admins/{aid}", headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200
    assert r.json()["id"] == aid

async def test_update_admin(client, admin_token):
    create = await client.post("/admins",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"username": "update_target", "email": "update_t@test.com",
              "password": "Test@1234", "role": "ml_user"})
    aid = create.json()["id"]
    r = await client.patch(f"/admins/{aid}",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"username": "updated_name"})
    assert r.status_code == 200
    assert r.json()["username"] == "updated_name"

async def test_disable_admin_account(client, admin_token):
    create = await client.post("/admins",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"username": "to_disable", "email": "disable@test.com",
              "password": "Test@1234", "role": "ml_user"})
    aid = create.json()["id"]
    r = await client.patch(f"/admins/{aid}/status",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"is_active": False})
    assert r.status_code == 200
    assert r.json()["is_active"] is False

async def test_delete_admin(client, admin_token):
    create = await client.post("/admins",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"username": "to_delete_a", "email": "del_a@test.com",
              "password": "Test@1234", "role": "ml_user"})
    aid = create.json()["id"]
    r = await client.delete(f"/admins/{aid}", headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 204

async def test_delete_nonexistent_admin(client, admin_token):
    r = await client.delete("/admins/99999", headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 404
