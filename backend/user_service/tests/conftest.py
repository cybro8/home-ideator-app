import csv, os, pathlib, pytest, pytest_asyncio
from httpx import AsyncClient, ASGITransport
from motor.motor_asyncio import AsyncIOMotorClient
import aiomysql
from app.main import app
from app.core.config import settings
from app.core.security import hash_password

DATA_DIR = pathlib.Path(__file__).parents[3] / "data"
SENSOR_CSV = DATA_DIR / "home_ideator_sensor_data.csv"
SHOP_CSV   = DATA_DIR / "home_ideator_shop_data.csv"

os.environ["MYSQL_DATABASE"]   = "home_ideator_test"
os.environ["MONGO_DATABASE"]   = "home_ideator_test"
TEST_EMAIL    = "testuser@test.com"
TEST_PASSWORD = "Test@1234"

@pytest.fixture(scope="session")
def sensor_rows():
    with open(SENSOR_CSV) as f: return list(csv.DictReader(f))

@pytest.fixture(scope="session")
def shop_rows():
    with open(SHOP_CSV) as f: return list(csv.DictReader(f))

@pytest.fixture(scope="session")
def unique_devices(sensor_rows):
    seen={}
    for r in sensor_rows:
        if r["firebase_key"] not in seen: seen[r["firebase_key"]]=r
    return list(seen.values())

@pytest_asyncio.fixture(scope="session", autouse=True)
async def seed_all(sensor_rows, shop_rows, unique_devices):
    pool = await aiomysql.create_pool(
        host=settings.mysql_host, port=settings.mysql_port,
        db="home_ideator_test", user=settings.mysql_user,
        password=settings.mysql_password, autocommit=True)
    hashed = hash_password(TEST_PASSWORD)
    async with pool.acquire() as conn:
        async with conn.cursor() as cur:
            await cur.execute(
                "INSERT IGNORE INTO end_users (uid,username,email,password_hash) "
                "VALUES ('test-uid-001','testuser',%s,%s)", (TEST_EMAIL, hashed))
            for p in shop_rows:
                await cur.execute(
                    "INSERT IGNORE INTO products (name,category,cost,rating,website_url,in_stock) "
                    "VALUES (%s,%s,%s,%s,%s,%s)",
                    (p["Name"],p["Category"],float(p["Cost"]),float(p["Rating"]),p["Website"],p["In_Stock"]=="True"))
            await cur.execute(
                "INSERT IGNORE INTO user_devices (device_id,user_uid,device_name,device_type) "
                "VALUES (%s,'test-uid-001',%s,%s)",
                (unique_devices[0]["firebase_key"], unique_devices[0]["device_name"], unique_devices[0]["device_type"]))
    pool.close(); await pool.wait_closed()
    mongo = AsyncIOMotorClient(settings.mongo_uri)
    db = mongo["home_ideator_test"]
    await db.device_readings.delete_many({})
    docs=[{"device_id":r["firebase_key"],"user_uid":r["user_uid"],"device_name":r["device_name"],
           "device_type":r["device_type"],"timestamp":r["timestamp"],
           "readings":{"Voltage":float(r["Voltage"]),"Current":float(r["Current"]),
                       "Power":float(r["Power"]),"temperature_C":float(r["temperature_C"])},
           "status":r["status"],"anomaly_type":r["anomaly_type"],
           "is_anomaly":int(r["is_anomaly"]),"fault_score":float(r["fault_score"])} for r in sensor_rows]
    await db.device_readings.insert_many(docs)
    mongo.close()

@pytest_asyncio.fixture
async def client():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        yield ac

@pytest_asyncio.fixture
async def user_token(client):
    r = await client.post("/auth/login", json={"email": TEST_EMAIL, "password": TEST_PASSWORD})
    return r.json()["access_token"]
