import aiomysql
from app.core.config import settings

_pool: aiomysql.Pool | None = None


async def get_pool() -> aiomysql.Pool:
    global _pool
    if _pool is None:
        _pool = await aiomysql.create_pool(
            host=settings.mysql_host,
            port=settings.mysql_port,
            db=settings.mysql_database,
            user=settings.mysql_user,
            password=settings.mysql_password,
            autocommit=True,
            minsize=1,
            maxsize=5,
        )
    return _pool


async def close_pool():
    global _pool
    if _pool:
        _pool.close()
        await _pool.wait_closed()
        _pool = None


async def get_device(device_id: str) -> dict | None:
    """Return device row from MySQL if it exists, else None."""
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(
                "SELECT * FROM user_devices WHERE device_id = %s", (device_id,)
            )
            return await cur.fetchone()
