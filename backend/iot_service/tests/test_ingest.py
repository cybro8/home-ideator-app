"""Tests for the IoT ingest endpoint."""
import pytest
from httpx import AsyncClient

pytestmark = pytest.mark.asyncio


async def test_health(client: AsyncClient):
    r = await client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


async def test_ingest_valid_reading(client: AsyncClient, unique_devices):
    device_id = unique_devices[0]["firebase_key"]
    payload = {"Voltage": 231.5, "Current": 0.37, "Power": 85.6, "temperature_C": 43.2}
    r = await client.post(f"/ingest/{device_id}", json=payload)
    assert r.status_code == 201
    body = r.json()
    assert body["device_id"] == device_id
    assert "inserted_id" in body


async def test_ingest_without_temperature(client: AsyncClient, unique_devices):
    """temperature_C is optional — should still succeed."""
    device_id = unique_devices[1]["firebase_key"]
    payload = {"Voltage": 228.0, "Current": 1.2, "Power": 273.6}
    r = await client.post(f"/ingest/{device_id}", json=payload)
    assert r.status_code == 201


async def test_ingest_missing_required_field_returns_422(client: AsyncClient, unique_devices):
    """Pydantic must reject payloads missing Voltage/Current/Power."""
    r = await client.post(
        f"/ingest/{unique_devices[0]['firebase_key']}",
        json={"Voltage": 230},  # missing Current + Power
    )
    assert r.status_code == 422


async def test_ingest_voltage_out_of_range_returns_422(client: AsyncClient, unique_devices):
    """Voltage > 500 must be rejected by Pydantic field validator."""
    r = await client.post(
        f"/ingest/{unique_devices[0]['firebase_key']}",
        json={"Voltage": 999, "Current": 1.0, "Power": 999},
    )
    assert r.status_code == 422


async def test_ingest_unknown_device_returns_404(client: AsyncClient):
    r = await client.post(
        "/ingest/nonexistent_device_xyz",
        json={"Voltage": 230, "Current": 1.0, "Power": 230, "temperature_C": 40},
    )
    assert r.status_code == 404


async def test_mongo_document_written(client: AsyncClient, unique_devices):
    """After a successful ingest the document must appear in MongoDB."""
    from motor.motor_asyncio import AsyncIOMotorClient
    from app.core.config import settings

    device_id = unique_devices[2]["firebase_key"]
    payload = {"Voltage": 230.0, "Current": 0.5, "Power": 115.0, "temperature_C": 38.0}
    await client.post(f"/ingest/{device_id}", json=payload)

    mongo = AsyncIOMotorClient(settings.mongo_uri)
    db = mongo["home_ideator_test"]
    count = await db.device_readings.count_documents({"device_id": device_id})
    mongo.close()
    assert count > 0


async def test_ingest_bulk_from_csv(client: AsyncClient, sensor_rows, unique_devices):
    """Simulate ingesting the first 20 CSV rows — all must return 201."""
    for row in sensor_rows[:20]:
        payload = {
            "Voltage": float(row["Voltage"]),
            "Current": float(row["Current"]),
            "Power":   float(row["Power"]),
            "temperature_C": float(row["temperature_C"]),
        }
        r = await client.post(f"/ingest/{row['firebase_key']}", json=payload)
        assert r.status_code == 201, f"Failed for device {row['firebase_key']}: {r.text}"


async def test_ingest_all_device_types_from_csv(client: AsyncClient, unique_devices, sensor_rows):
    """Each unique device in the CSV must successfully ingest a reading."""
    for device in unique_devices:
        # Pick one row from this device
        row = next(r for r in sensor_rows if r["firebase_key"] == device["firebase_key"])
        payload = {
            "Voltage": float(row["Voltage"]),
            "Current": float(row["Current"]),
            "Power":   float(row["Power"]),
        }
        r = await client.post(f"/ingest/{device['firebase_key']}", json=payload)
        assert r.status_code == 201
