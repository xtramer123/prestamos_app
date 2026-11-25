"""Punto de entrada de la API REST de PrestaFácil."""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .database import init_db
from .routers import auth, prestamos


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Crea la base de datos y las tablas automáticamente al iniciar.
    init_db()
    yield


app = FastAPI(
    title="PrestaFácil API",
    description="API REST para gestionar préstamos con FastAPI y MySQL (XAMPP).",
    version="1.0.0",
    lifespan=lifespan,
)

origenes = [
    origen.strip() for origen in settings.CORS_ORIGINS.split(",") if origen.strip()
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origenes,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(prestamos.router)


@app.get("/", tags=["Salud"], summary="Mensaje de bienvenida")
def raiz():
    return {"mensaje": "PrestaFácil API funcionando", "docs": "/docs"}


@app.get("/health", tags=["Salud"], summary="Estado del servicio")
def health():
    return {"status": "ok"}
