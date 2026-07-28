from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    mysql_host: str = "localhost"
    mysql_port: int = 3306
    mysql_database: str = "home_ideator"
    mysql_user: str = "homeuser"
    mysql_password: str = "homepass"
    mongo_uri: str = "mongodb://localhost:27017"
    mongo_database: str = "home_ideator"
    user_jwt_secret: str = "user_super_secret_change_me"
    jwt_algorithm: str = "HS256"
    user_token_expire_hours: int = 24

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()
