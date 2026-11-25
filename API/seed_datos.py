"""Carga datos de prueba en la API (usuario demo + 6 préstamos)."""

import json
import urllib.error
import urllib.request
from datetime import date, timedelta

BASE = "http://127.0.0.1:8000"
EMAIL = "admin@prestafacil.com"
PASSWORD = "123456"


def pedir(method, path, body=None, token=None):
    datos = json.dumps(body).encode("utf-8") if body is not None else None
    cabeceras = {"Content-Type": "application/json"}
    if token:
        cabeceras["Authorization"] = f"Bearer {token}"

    peticion = urllib.request.Request(
        BASE + path, data=datos, headers=cabeceras, method=method
    )
    try:
        with urllib.request.urlopen(peticion) as respuesta:
            contenido = respuesta.read()
            return json.loads(contenido) if contenido else None
    except urllib.error.HTTPError as error:
        raise RuntimeError(
            f"{method} {path} -> {error.code}: {error.read().decode('utf-8')}"
        ) from error


def main():
    try:
        token = pedir(
            "POST", "/auth/login", {"email": EMAIL, "password": PASSWORD}
        )["access_token"]
        print("Sesión demo reutilizada.")
    except RuntimeError:
        token = pedir(
            "POST",
            "/auth/register",
            {
                "nombre": "Isaac Administrador",
                "email": EMAIL,
                "password": PASSWORD,
            },
        )["access_token"]
        print("Usuario demo creado.")

    existentes = pedir("GET", "/prestamos", token=token)
    if existentes:
        print(f"Ya existen {len(existentes)} préstamos; no se duplican los datos.")
        return

    hoy = date.today()
    prestamos = [
        ("María Fernanda López", "12345678", 15000, 150, 300, False),
        ("Carlos Ramírez", "87654321", 8500, 68, -45, False),
        ("Ana Sofía Torres", "45678912", 25000, 375, 500, False),
        ("Jorge Mendoza", "11223344", 5000, 40, -20, True),
        ("Lucía Herrera", "22334455", 12000, 108, 210, False),
        ("Pedro Castillo", "55667788", 30000, 450, -10, False),
    ]

    for cliente, dni, monto, interes, dias, pagado in prestamos:
        pedir(
            "POST",
            "/prestamos",
            {
                "cliente": cliente,
                "dni": dni,
                "monto": monto,
                "interes": interes,
                "fecha_vencimiento": (hoy + timedelta(days=dias)).isoformat(),
                "pagado": pagado,
            },
            token=token,
        )

    print(f"{len(prestamos)} préstamos de prueba creados correctamente.")
    print(f"Login: {EMAIL} / {PASSWORD}")


if __name__ == "__main__":
    main()
