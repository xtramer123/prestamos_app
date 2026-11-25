"""Modelos SQLAlchemy: un prestamista tiene muchos préstamos."""

from datetime import date

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    Column,
    Date,
    ForeignKey,
    Numeric,
    String,
    BigInteger,
    func,
    text,
)
from sqlalchemy.orm import relationship

from .database import Base


class Usuario(Base):
    __tablename__ = "usuario"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    nombre = Column(String(100), nullable=False)
    email = Column(String(120), nullable=False, unique=True, index=True)
    password = Column(String(100), nullable=False)
    rol = Column(
        String(20), nullable=False, default="USER", server_default="USER"
    )

    prestamos = relationship(
        "Prestamo",
        back_populates="usuario",
        cascade="all, delete-orphan",
        passive_deletes=True,
    )


class Prestamo(Base):
    __tablename__ = "prestamo"
    __table_args__ = (
        CheckConstraint("monto > 0", name="ck_prestamo_monto_positivo"),
        CheckConstraint("interes >= 0", name="ck_prestamo_interes_no_negativo"),
    )

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    cliente = Column(String(100), nullable=False)
    dni = Column(String(8), nullable=False)
    monto = Column(Numeric(10, 2), nullable=False)
    interes = Column(Numeric(5, 2), nullable=False)
    fecha_prestamo = Column(
        Date,
        nullable=False,
        default=date.today,
        server_default=func.curdate(),
    )
    fecha_vencimiento = Column(Date, nullable=False)
    pagado = Column(
        Boolean, nullable=False, default=False, server_default=text("false")
    )
    usuario_id = Column(
        BigInteger,
        ForeignKey("usuario.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    usuario = relationship("Usuario", back_populates="prestamos")
