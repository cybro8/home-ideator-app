import pytest
pytestmark = pytest.mark.asyncio

async def test_get_profile(client, user_token):
    r = await client.get("/me", headers={"Authorization": f"Bearer {user_token}"})
    assert r.status_code == 200
    assert "email" in r.json()

async def test_update_profile(client, user_token):
    r = await client.patch("/me",
        headers={"Authorization": f"Bearer {user_token}"},
        json={"username": "updated_testuser"})
    assert r.status_code == 200

async def test_no_token_returns_401(client):
    r = await client.get("/me")
    assert r.status_code == 401
