"""
Shared pytest fixtures for iot_service tests.

Seed data is loaded from the project data/ CSV files so tests
run against realistic data without any manual setup.
"""
import csv
import os
import pathlib

import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport

from app.main import app
from app.core.config import settings

# ── Path to shared CSV seed files ────────────────────────────────────────
DATA_DIR = pathlib.Path(__file__).parents[3] / "data"
SENSOR_CSV = DATA_DIR / "home_ideator_sensor_data.csv"
SHOP_CSV = DATA_DIR / "home_ideator_shop_data.csv"

# ── Override DBs to use test databases ───────────────────────────────────
os.environ["MYSQL_DATABASE"] = "home_ideator_test"
os.environ["MONGO_DATABASE"] = "home_ideator_test"


@pytest.fixture(scope="session")
def sensor_rows():
    with open(SENSOR_CSV, encoding="utf-8") as f:
        return list(csv.DictReader(f))


@pytest.fixture(scope="session")
def shop_rows():
    with open(SHOP_CSV, encoding="utf-8") as f:
        return list(csv.DictReader(f))


@pytest.fixture(scope="session")
def unique_users(sensor_rows):
    seen: dict[str, str] = {}
    for r in sensor_rows:
        if r["user_uid"] not in seen:
            seen[r["user_uid"]] = r["user_name"]
    return [{"uid": uid, "name": name} for uid, name in seen.items()]


@pytest.fixture(scope="session")
def unique_devices(sensor_rows):
    seen: dict[str, dict] = {}
    for r in sensor_rows:
        if r["firebase_key"] not in seen:
            seen[r["firebase_key"]] = r
    return list(seen.values())


@pytest_asyncio.fixture(scope="module", autouse=True)
async def seed_mysql(unique_users, unique_devices):
    """Insert test users and devices into MySQL test DB."""
    import aiomysql

    pool = await aiomysql.create_pool(
        host=settings.mysql_host,
        port=settings.mysql_port,
        db="home_ideator_test",
        user=settings.mysql_user,
        password=settings.mysql_password,
        autocommit=True,
    )
    async with pool.acquire() as conn:
        async with conn.cursor() as cur:
            # end_users
            for u in unique_users:
                uname = u["name"].replace(" ", "_").lower()
                await cur.execute(
                    "INSERT IGNORE INTO end_users (uid, username, email, password_hash) "
                    "VALUES (%s, %s, %s, %s)",
                    (u["uid"], uname, f"{u['uid']}@test.com", "hashed"),
                )
            # user_devices
            for d in unique_devices:
                await cur.execute(
                    "INSERT IGNORE INTO user_devices "
                    "(device_id, user_uid, device_name, device_type) "
                    "VALUES (%s, %s, %s, %s)",
                    (d["firebase_key"], d["user_uid"],
                     d["device_name"], d["device_type"]),
                )
    pool.close()
    await pool.wait_closed()


@pytest_asyncio.fixture(scope="module", autouse=True)
async def seed_mongo(sensor_rows):
    """Bulk-insert all 5 000 sensor CSV rows into MongoDB test collection."""
    from motor.motor_asyncio import AsyncIOMotorClient

    client = AsyncIOMotorClient(settings.mongo_uri)
    db = client["home_ideator_test"]
    await db.device_readings.delete_many({})
    docs = [
        {
            "device_id":   r["firebase_key"],
            "user_uid":    r["user_uid"],
            "device_name": r["device_name"],
            "device_type": r["device_type"],
            "timestamp":   r["timestamp"],
            "readings": {
                "Voltage":       float(r["Voltage"]),
                "Current":       float(r["Current"]),
                "Power":         float(r["Power"]),
                "temperature_C": float(r["temperature_C"]),
            },
            "status":       r["status"],
            "anomaly_type": r["anomaly_type"],
            "is_anomaly":   int(r["is_anomaly"]),
            "fault_score":  float(r["fault_score"]),
        }
        for r in sensor_rows
    ]
    await db.device_readings.insert_many(docs)
    client.close()


@pytest_asyncio.fixture
async def client():
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as ac:
        yield ac
