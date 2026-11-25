"""Lectura de configuración desde variables de entorno / archivo .env."""

import os
from urllib.parse import quote_plus

from dotenv import load_dotenv

load_dotenv()


class Settings:
    DB_HOST: str = os.getenv("DB_HOST", "localhost")
    DB_PORT: str = os.getenv("DB_PORT", "3306")
    DB_USER: str = os.getenv("DB_USER", "root")
    DB_PASSWORD: str = os.getenv("DB_PASSWORD", "")
    DB_NAME: str = os.getenv("DB_NAME", "prestamos_db")

    SECRET_KEY: str = os.getenv(
        "SECRET_KEY", "cambia-esta-clave-por-una-larga-y-aleatoria"
    )
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(
        os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60")
    )
    CORS_ORIGINS: str = os.getenv("CORS_ORIGINS", "*")

    def _credenciales(self) -> str:
        usuario = quote_plus(self.DB_USER)
        password = quote_plus(self.DB_PASSWORD)
        return f"{usuario}:{password}@{self.DB_HOST}:{self.DB_PORT}"

    @property
    def server_database_url(self) -> str:
        """URL sin base de datos, usada para crearla si no existe."""
        return f"mysql+pymysql://{self._credenciales()}/?charset=utf8mb4"

    @property
    def database_url(self) -> str:
        """URL de la base de datos de la aplicación."""
        return (
            f"mysql+pymysql://{self._credenciales()}/{self.DB_NAME}"
            "?charset=utf8mb4"
        )


settings = Settings()
