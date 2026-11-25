"""Motor de SQLAlchemy, sesiones y creación automática de BD/tablas."""

from sqlalchemy import create_engine, text
from sqlalchemy.orm import declarative_base, sessionmaker

from .config import settings

Base = declarative_base()

# Se conecta al servidor sin base de datos para poder crearla.
server_engine = create_engine(
    settings.server_database_url,
    pool_pre_ping=True,
    pool_recycle=3600,
)

engine = create_engine(
    settings.database_url,
    pool_pre_ping=True,
    pool_recycle=3600,
)

SessionLocal = sessionmaker(
    bind=engine,
    autocommit=False,
    autoflush=False,
    expire_on_commit=False,
)


def init_db() -> None:
    """Crea la base de datos y las tablas si todavía no existen."""
    nombre_bd = settings.DB_NAME.replace("`", "``")

    with server_engine.begin() as conexion:
        conexion.execute(
            text(
                f"CREATE DATABASE IF NOT EXISTS `{nombre_bd}` "
                "CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
            )
        )

    # Importar los modelos aquí evita ciclos y registra las tablas en Base.
    from . import models  # noqa: F401

    Base.metadata.create_all(bind=engine)


def get_db():
    """Dependencia que entrega una sesión por petición y la cierra al final."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
