import pytest
pytestmark = pytest.mark.asyncio

async def test_list_devices(client, user_token):
    r = await client.get("/my/devices", headers={"Authorization": f"Bearer {user_token}"})
    assert r.status_code == 200
    assert isinstance(r.json(), list)

async def test_get_device_readings(client, user_token, unique_devices):
    did = unique_devices[0]["firebase_key"]
    r = await client.get(f"/my/devices/{did}/data?limit=10",
        headers={"Authorization": f"Bearer {user_token}"})
    assert r.status_code == 200
    assert len(r.json()) <= 10

async def test_device_readings_have_correct_fields(client, user_token, unique_devices):
    did = unique_devices[0]["firebase_key"]
    r = await client.get(f"/my/devices/{did}/data?limit=1",
        headers={"Authorization": f"Bearer {user_token}"})
    assert r.status_code == 200
    if r.json():
        row = r.json()[0]
        assert "Voltage" in row or "timestamp" in row
