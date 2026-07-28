import aiomysql
from motor.motor_asyncio import AsyncIOMotorClient
from app.core.config import settings

_pool = None
_mongo = None

async def get_pool():
    global _pool
    if _pool is None:
        _pool = await aiomysql.create_pool(
            host=settings.mysql_host, port=settings.mysql_port,
            db=settings.mysql_database, user=settings.mysql_user,
            password=settings.mysql_password, autocommit=True, minsize=1, maxsize=5)
    return _pool

async def get_mongo_db():
    global _mongo
    if _mongo is None:
        _mongo = AsyncIOMotorClient(settings.mongo_uri)
    return _mongo[settings.mongo_database]

async def close_all():
    global _pool, _mongo
    if _pool: _pool.close(); await _pool.wait_closed(); _pool = None
    if _mongo: _mongo.close(); _mongo = None
