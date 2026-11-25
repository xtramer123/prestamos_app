"""Endpoints protegidos de préstamos (el usuario se obtiene del JWT)."""

from datetime import date
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Prestamo, Usuario
from ..schemas import PrestamoCreate, PrestamoOut, PrestamoUpdate
from ..security import get_current_user

router = APIRouter(prefix="/prestamos", tags=["Préstamos"])


def _propio(
    db: Session, prestamo_id: int, usuario: Usuario
) -> Prestamo:
    """Busca un préstamo solo dentro de la cartera del usuario autenticado."""
    prestamo = (
        db.query(Prestamo)
        .filter(
            Prestamo.id == prestamo_id,
            Prestamo.usuario_id == usuario.id,
        )
        .first()
    )
    if prestamo is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Préstamo no encontrado",
        )
    return prestamo


def _a_salida(prestamo: Prestamo) -> PrestamoOut:
    salida = PrestamoOut.model_validate(prestamo)
    salida.total_a_cobrar = (prestamo.monto or Decimal("0")) + (
        prestamo.interes or Decimal("0")
    )
    return salida


@router.get("", response_model=list[PrestamoOut], summary="Listar préstamos")
def listar(
    db: Session = Depends(get_db),
    usuario: Usuario = Depends(get_current_user),
):
    prestamos = (
        db.query(Prestamo)
        .filter(Prestamo.usuario_id == usuario.id)
        .order_by(Prestamo.fecha_prestamo.desc(), Prestamo.id.desc())
        .all()
    )
    return [_a_salida(prestamo) for prestamo in prestamos]


@router.get(
    "/{prestamo_id}",
    response_model=PrestamoOut,
    summary="Obtener un préstamo por id",
)
def obtener(
    prestamo_id: int,
    db: Session = Depends(get_db),
    usuario: Usuario = Depends(get_current_user),
):
    return _a_salida(_propio(db, prestamo_id, usuario))


@router.post(
    "",
    response_model=PrestamoOut,
    status_code=status.HTTP_201_CREATED,
    summary="Registrar un préstamo",
)
def registrar(
    datos: PrestamoCreate,
    db: Session = Depends(get_db),
    usuario: Usuario = Depends(get_current_user),
):
    prestamo = Prestamo(
        cliente=datos.cliente.strip(),
        dni=datos.dni,
        monto=datos.monto,
        interes=datos.interes,
        fecha_prestamo=date.today(),
        fecha_vencimiento=datos.fecha_vencimiento,
        pagado=datos.pagado,
        usuario_id=usuario.id,
    )
    db.add(prestamo)
    db.commit()
    db.refresh(prestamo)
    return _a_salida(prestamo)


@router.put(
    "/{prestamo_id}",
    response_model=PrestamoOut,
    summary="Actualizar un préstamo (o marcarlo pagado)",
)
def actualizar(
    prestamo_id: int,
    datos: PrestamoUpdate,
    db: Session = Depends(get_db),
    usuario: Usuario = Depends(get_current_user),
):
    prestamo = _propio(db, prestamo_id, usuario)
    cambios = datos.model_dump(exclude_unset=True)

    for campo, valor in cambios.items():
        if isinstance(valor, str) and campo == "cliente":
            valor = valor.strip()
        setattr(prestamo, campo, valor)

    db.commit()
    db.refresh(prestamo)
    return _a_salida(prestamo)


@router.delete(
    "/{prestamo_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Eliminar un préstamo",
)
def eliminar(
    prestamo_id: int,
    db: Session = Depends(get_db),
    usuario: Usuario = Depends(get_current_user),
):
    prestamo = _propio(db, prestamo_id, usuario)
    db.delete(prestamo)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
