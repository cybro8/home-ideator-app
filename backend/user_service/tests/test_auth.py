import pytest
pytestmark = pytest.mark.asyncio

async def test_health(client):
    r = await client.get("/health")
    assert r.status_code == 200

async def test_register_new_user(client):
    r = await client.post("/auth/register",
        json={"username":"brandnew","email":"brandnew@test.com","password":"Test@1234"})
    assert r.status_code == 201
    assert "uid" in r.json()

async def test_register_duplicate_email(client):
    r = await client.post("/auth/register",
        json={"username":"dup2","email":"testuser@test.com","password":"Test@1234"})
    assert r.status_code == 409

async def test_login_success(client):
    r = await client.post("/auth/login",
        json={"email":"testuser@test.com","password":"Test@1234"})
    assert r.status_code == 200
    assert "access_token" in r.json()

async def test_login_wrong_password(client):
    r = await client.post("/auth/login",
        json={"email":"testuser@test.com","password":"wrong"})
    assert r.status_code == 401

async def test_admin_jwt_rejected_on_user_service(client):
    """A fake admin-audience token must NOT work on user_service."""
    from jose import jwt as jose_jwt
    fake = jose_jwt.encode({"sub":"1","role":"admin","aud":"admin"},
                           "admin_super_secret_change_me", algorithm="HS256")
    r = await client.get("/me", headers={"Authorization": f"Bearer {fake}"})
    assert r.status_code == 401
