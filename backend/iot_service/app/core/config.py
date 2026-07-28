from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # MySQL
    mysql_host: str = "localhost"
    mysql_port: int = 3306
    mysql_database: str = "home_ideator"
    mysql_user: str = "homeuser"
    mysql_password: str = "homepass"

    # MongoDB
    mongo_uri: str = "mongodb://localhost:27017"
    mongo_database: str = "home_ideator"

    # Service
    iot_service_port: int = 8001

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()
