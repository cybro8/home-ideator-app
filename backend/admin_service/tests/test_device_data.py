import pytest
pytestmark = pytest.mark.asyncio

async def test_get_device_data_admin(client, admin_token, unique_devices):
    did = unique_devices[0]["firebase_key"]
    r = await client.get(f"/devices/{did}/data?limit=10",
        headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200
    assert len(r.json()) <= 10

async def test_get_device_data_ml_user(client, ml_token, unique_devices):
    did = unique_devices[0]["firebase_key"]
    r = await client.get(f"/devices/{did}/data?limit=5",
        headers={"Authorization": f"Bearer {ml_token}"})
    assert r.status_code == 200

async def test_get_device_data_eu_admin_forbidden(client, eu_admin_token, unique_devices):
    did = unique_devices[0]["firebase_key"]
    r = await client.get(f"/devices/{did}/data",
        headers={"Authorization": f"Bearer {eu_admin_token}"})
    assert r.status_code == 403

async def test_device_data_has_correct_fields(client, admin_token, unique_devices):
    did = unique_devices[0]["firebase_key"]
    r = await client.get(f"/devices/{did}/data?limit=1",
        headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200
    row = r.json()[0]
    assert "Voltage" in row
    assert "Current" in row
    assert "Power" in row

async def test_device_data_date_filter(client, admin_token, unique_devices):
    did = unique_devices[0]["firebase_key"]
    r = await client.get(
        f"/devices/{did}/data?from=2025-01-01T00:00:00&to=2025-01-02T00:00:00",
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert r.status_code == 200

async def test_download_csv(client, admin_token, unique_devices):
    did = unique_devices[0]["firebase_key"]
    r = await client.get(f"/devices/{did}/data/csv",
        headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200
    assert "text/csv" in r.headers["content-type"]
    assert "Voltage" in r.text
    assert "Current" in r.text
    assert "Power" in r.text

async def test_download_csv_ml_user(client, ml_token, unique_devices):
    did = unique_devices[0]["firebase_key"]
    r = await client.get(f"/devices/{did}/data/csv",
        headers={"Authorization": f"Bearer {ml_token}"})
    assert r.status_code == 200

async def test_download_csv_eu_admin_forbidden(client, eu_admin_token, unique_devices):
    did = unique_devices[0]["firebase_key"]
    r = await client.get(f"/devices/{did}/data/csv",
        headers={"Authorization": f"Bearer {eu_admin_token}"})
    assert r.status_code == 403

async def test_download_excel(client, admin_token, unique_devices):
    did = unique_devices[0]["firebase_key"]
    r = await client.get(f"/devices/{did}/data/excel",
        headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200
    assert "spreadsheet" in r.headers["content-type"]
    assert len(r.content) > 0

async def test_csv_columns_match_sensor_csv(client, admin_token, unique_devices):
    """CSV download columns must include the same fields as home_ideator_sensor_data.csv."""
    did = unique_devices[0]["firebase_key"]
    r = await client.get(f"/devices/{did}/data/csv",
        headers={"Authorization": f"Bearer {admin_token}"})
    assert r.status_code == 200
    header_line = r.text.split("\n")[0]
    for expected_col in ["Voltage", "Current", "Power", "temperature_C", "timestamp"]:
        assert expected_col in header_line
