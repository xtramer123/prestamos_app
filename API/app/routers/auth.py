"""Endpoints públicos de registro e inicio de sesión."""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..config import settings
from ..database import get_db
from ..models import Usuario
from ..schemas import Token, UsuarioCreate, UsuarioLogin, UsuarioOut
from ..security import crear_token, hash_password, verificar_password

router = APIRouter(prefix="/auth", tags=["Autenticación"])


@router.post(
    "/register",
    response_model=Token,
    status_code=status.HTTP_201_CREATED,
    summary="Crear prestamista y devolver JWT",
)
def register(datos: UsuarioCreate, db: Session = Depends(get_db)):
    email = str(datos.email).strip().lower()

    if db.query(Usuario).filter(Usuario.email == email).first():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El correo ya está registrado",
        )

    usuario = Usuario(
        nombre=datos.nombre.strip(),
        email=email,
        password=hash_password(datos.password),
        rol="USER",
    )
    db.add(usuario)
    db.commit()
    db.refresh(usuario)

    return Token(
        access_token=crear_token(usuario.email),
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        usuario=UsuarioOut.model_validate(usuario),
    )


@router.post(
    "/login",
    response_model=Token,
    summary="Iniciar sesión y devolver JWT",
)
def login(datos: UsuarioLogin, db: Session = Depends(get_db)):
    email = str(datos.email).strip().lower()
    usuario = db.query(Usuario).filter(Usuario.email == email).first()

    if usuario is None or not verificar_password(
        datos.password, usuario.password
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Correo o contraseña incorrectos",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return Token(
        access_token=crear_token(usuario.email),
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        usuario=UsuarioOut.model_validate(usuario),
    )
