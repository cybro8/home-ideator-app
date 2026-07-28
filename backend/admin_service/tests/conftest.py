"""
Shared pytest fixtures for admin_service tests.
Seeds MySQL and MongoDB from the project CSV files.
"""
import csv
import os
import pathlib

import aiomysql
import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from motor.motor_asyncio import AsyncIOMotorClient

from app.main import app
from app.core.config import settings
from app.core.security import hash_password

DATA_DIR = pathlib.Path(__file__).parents[3] / "data"
SENSOR_CSV = DATA_DIR / "home_ideator_sensor_data.csv"
SHOP_CSV = DATA_DIR / "home_ideator_shop_data.csv"

os.environ["MYSQL_DATABASE"] = "home_ideator_test"
os.environ["MONGO_DATABASE"] = "home_ideator_test"
TEST_PASSWORD = "Test@1234"


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
    seen: dict = {}
    for r in sensor_rows:
        if r["user_uid"] not in seen:
            seen[r["user_uid"]] = r["user_name"]
    return [{"uid": k, "name": v} for k, v in seen.items()]


@pytest.fixture(scope="session")
def unique_devices(sensor_rows):
    seen: dict = {}
    for r in sensor_rows:
        if r["firebase_key"] not in seen:
            seen[r["firebase_key"]] = r
    return list(seen.values())


@pytest_asyncio.fixture(scope="session", autouse=True)
async def seed_all(unique_users, unique_devices, shop_rows, sensor_rows):
    """Seed MySQL + MongoDB test databases once per test session."""
    pool = await aiomysql.create_pool(
        host=settings.mysql_host, port=settings.mysql_port,
        db="home_ideator_test", user=settings.mysql_user,
        password=settings.mysql_password, autocommit=True,
    )
    hashed_pw = hash_password(TEST_PASSWORD)
    async with pool.acquire() as conn:
        async with conn.cursor() as cur:
            # Seed admin accounts for each role
            for uname, email, role in [
                ("admin_test",   "admin@test.com",   "admin"),
                ("euadmin_test", "euadmin@test.com", "end_user_admin"),
                ("mluser_test",  "mluser@test.com",  "ml_user"),
            ]:
                await cur.execute(
                    "INSERT IGNORE INTO admin_users (username, email, password_hash, role) "
                    "VALUES (%s, %s, %s, %s)", (uname, email, hashed_pw, role)
                )
            # Seed end_users from CSV
            for u in unique_users:
                uname = u["name"].replace(" ", "_").lower()
                await cur.execute(
                    "INSERT IGNORE INTO end_users (uid, username, email, password_hash) "
                    "VALUES (%s, %s, %s, %s)",
                    (u["uid"], uname, f"{u['uid']}@test.com", hashed_pw),
                )
            # Seed products from CSV
            for p in shop_rows:
                await cur.execute(
                    "INSERT IGNORE INTO products "
                    "(name, category, cost, rating, website_url, in_stock) "
                    "VALUES (%s, %s, %s, %s, %s, %s)",
                    (p["Name"], p["Category"], float(p["Cost"]),
                     float(p["Rating"]), p["Website"], p["In_Stock"] == "True"),
                )
            # Seed user_devices from CSV
            for d in unique_devices:
                await cur.execute(
                    "INSERT IGNORE INTO user_devices "
                    "(device_id, user_uid, device_name, device_type) "
                    "VALUES (%s, %s, %s, %s)",
                    (d["firebase_key"], d["user_uid"], d["device_name"], d["device_type"]),
                )
    pool.close()
    await pool.wait_closed()

    # Seed MongoDB
    mongo = AsyncIOMotorClient(settings.mongo_uri)
    db = mongo["home_ideator_test"]
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
    mongo.close()


@pytest_asyncio.fixture
async def client():
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as ac:
        yield ac


async def _get_token(client: AsyncClient, email: str) -> str:
    r = await client.post("/auth/login", json={"email": email, "password": TEST_PASSWORD})
    return r.json()["access_token"]


@pytest_asyncio.fixture
async def admin_token(client):
    return await _get_token(client, "admin@test.com")


@pytest_asyncio.fixture
async def eu_admin_token(client):
    return await _get_token(client, "euadmin@test.com")


@pytest_asyncio.fixture
async def ml_token(client):
    return await _get_token(client, "mluser@test.com")
