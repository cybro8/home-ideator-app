import aiomysql
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from app.core.config import settings

# ── MySQL ──────────────────────────────────────────────────────────────────
_mysql_pool: aiomysql.Pool | None = None


async def get_pool() -> aiomysql.Pool:
    global _mysql_pool
    if _mysql_pool is None:
        _mysql_pool = await aiomysql.create_pool(
            host=settings.mysql_host,
            port=settings.mysql_port,
            db=settings.mysql_database,
            user=settings.mysql_user,
            password=settings.mysql_password,
            autocommit=True,
            minsize=2,
            maxsize=10,
        )
    return _mysql_pool


async def close_mysql():
    global _mysql_pool
    if _mysql_pool:
        _mysql_pool.close()
        await _mysql_pool.wait_closed()
        _mysql_pool = None


# ── MongoDB ────────────────────────────────────────────────────────────────
_mongo_client: AsyncIOMotorClient | None = None


def get_mongo_client() -> AsyncIOMotorClient:
    global _mongo_client
    if _mongo_client is None:
        _mongo_client = AsyncIOMotorClient(settings.mongo_uri)
    return _mongo_client


async def get_mongo_db() -> AsyncIOMotorDatabase:
    return get_mongo_client()[settings.mongo_database]


async def close_mongo():
    global _mongo_client
    if _mongo_client:
        _mongo_client.close()
        _mongo_client = None
