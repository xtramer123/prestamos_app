"""Esquemas Pydantic de entrada y salida."""

from datetime import date
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, EmailStr, Field, condecimal


class UsuarioCreate(BaseModel):
    nombre: str = Field(..., min_length=2, max_length=100)
    email: EmailStr = Field(..., max_length=120)
    password: str = Field(..., min_length=6, max_length=100)


class UsuarioLogin(BaseModel):
    email: EmailStr
    password: str


class UsuarioOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    nombre: str
    email: EmailStr
    rol: str


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int
    usuario: UsuarioOut


class PrestamoCreate(BaseModel):
    cliente: str = Field(..., min_length=2, max_length=100)
    dni: str = Field(..., pattern=r"^\d{8}$", description="DNI de 8 dígitos")
    monto: condecimal(gt=0, max_digits=10, decimal_places=2)
    interes: condecimal(ge=0, max_digits=5, decimal_places=2)
    fecha_vencimiento: date
    pagado: bool = False


class PrestamoUpdate(BaseModel):
    cliente: str | None = Field(default=None, min_length=2, max_length=100)
    dni: str | None = Field(default=None, pattern=r"^\d{8}$")
    monto: condecimal(gt=0, max_digits=10, decimal_places=2) | None = None
    interes: condecimal(ge=0, max_digits=5, decimal_places=2) | None = None
    fecha_vencimiento: date | None = None
    pagado: bool | None = None


class PrestamoOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    cliente: str
    dni: str
    monto: Decimal
    interes: Decimal
    fecha_prestamo: date
    fecha_vencimiento: date
    pagado: bool
    usuario_id: int
    total_a_cobrar: Decimal = Decimal("0")
