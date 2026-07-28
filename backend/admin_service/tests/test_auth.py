import pytest
pytestmark = pytest.mark.asyncio

async def test_health(client):
    r = await client.get("/health")
    assert r.status_code == 200

async def test_login_admin_success(client):
    r = await client.post("/auth/login", json={"email": "admin@test.com", "password": "Test@1234"})
    assert r.status_code == 200
    assert "access_token" in r.json()
    assert r.json()["role"] == "admin"

async def test_login_end_user_admin(client):
    r = await client.post("/auth/login", json={"email": "euadmin@test.com", "password": "Test@1234"})
    assert r.status_code == 200
    assert r.json()["role"] == "end_user_admin"

async def test_login_ml_user(client):
    r = await client.post("/auth/login", json={"email": "mluser@test.com", "password": "Test@1234"})
    assert r.status_code == 200
    assert r.json()["role"] == "ml_user"

async def test_login_wrong_password(client):
    r = await client.post("/auth/login", json={"email": "admin@test.com", "password": "wrong"})
    assert r.status_code == 401

async def test_login_unknown_email(client):
    r = await client.post("/auth/login", json={"email": "ghost@test.com", "password": "Test@1234"})
    assert r.status_code == 401

async def test_get_me_all_roles(client, admin_token, eu_admin_token, ml_token):
    for token in [admin_token, eu_admin_token, ml_token]:
        r = await client.get("/auth/me", headers={"Authorization": f"Bearer {token}"})
        assert r.status_code == 200
        assert "email" in r.json()

async def test_get_me_no_token(client):
    r = await client.get("/auth/me")
    assert r.status_code == 401

async def test_change_own_password(client, ml_token):
    r = await client.patch("/auth/me/password",
        headers={"Authorization": f"Bearer {ml_token}"},
        json={"current_password": "Test@1234", "new_password": "NewPass@5678"})
    assert r.status_code == 200

async def test_change_password_wrong_current(client, eu_admin_token):
    r = await client.patch("/auth/me/password",
        headers={"Authorization": f"Bearer {eu_admin_token}"},
        json={"current_password": "wrongpass", "new_password": "NewPass@5678"})
    assert r.status_code == 401
