# PrestaFácil API (FastAPI + MySQL/XAMPP)

API REST local para gestionar préstamos. La base de datos y las tablas se crean
automáticamente al iniciar el servidor.

## Requisitos

- Python 3.10 o superior.
- XAMPP con MySQL/MariaDB (puerto `3306`, usuario `root`, contraseña vacía por defecto).

## 1. Instalar dependencias

```powershell
cd C:\Users\IsaacPC\Documents\APPPRACTICA\API
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
```

## 2. Configurar variables de entorno

Ya existe un archivo `.env` con valores para XAMPP local. Puedes copiar
`.env.example` y editarlo:

```powershell
copy .env.example .env
```

| Variable | Descripción | Valor por defecto |
|---|---|---|
| `DB_HOST` | Host de MySQL | `localhost` |
| `DB_PORT` | Puerto | `3306` |
| `DB_USER` | Usuario | `root` |
| `DB_PASSWORD` | Contraseña | vacía |
| `DB_NAME` | Base de datos | `prestamos_db` |
| `SECRET_KEY` | Clave para firmar JWT | ver `.env` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Vigencia del token | `60` |
| `CORS_ORIGINS` | Orígenes permitidos | `*` |

## 3. Iniciar MySQL en XAMPP

Abre el **XAMPP Control Panel** y presiona **Start** en el módulo **MySQL**.
No hace falta crear la base de datos a mano: `init_db()` ejecuta
`CREATE DATABASE IF NOT EXISTS prestamos_db` y crea las tablas `usuario` y
`prestamo` con sus restricciones y clave foránea.

## 4. Levantar la API

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

- Documentación interactiva: <http://localhost:8000/docs>
- Estado: <http://localhost:8000/health>

## Endpoints

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| POST | `/auth/register` | No | Crea prestamista (bcrypt) y devuelve JWT |
| POST | `/auth/login` | No | Valida credenciales y devuelve JWT |
| GET | `/prestamos` | Sí | Lista solo los préstamos del usuario del token |
| GET | `/prestamos/{id}` | Sí | Obtiene un préstamo propio |
| POST | `/prestamos` | Sí | Registra préstamo (fecha actual automática) |
| PUT | `/prestamos/{id}` | Sí | Actualiza datos o marca `pagado` |
| DELETE | `/prestamos/{id}` | Sí | Elimina el préstamo |

Todas las respuestas de préstamo incluyen `total_a_cobrar = monto + interes`,
según la especificación.

## Prueba rápida desde PowerShell

```powershell
$base = 'http://localhost:8000'

$registro = @{
  nombre = 'Isaac'
  email = 'isaac@test.com'
  password = '123456'
} | ConvertTo-Json

$respuesta = Invoke-RestMethod -Uri "$base/auth/register" -Method Post -Body $registro -ContentType 'application/json'
$token = $respuesta.access_token
$headers = @{ Authorization = "Bearer $token" }

$nuevo = @{
  cliente = 'Maria Lopez'
  dni = '12345678'
  monto = 1500.00
  interes = 150.00
  fecha_vencimiento = '2026-12-31'
  pagado = $false
} | ConvertTo-Json

Invoke-RestMethod -Uri "$base/prestamos" -Method Post -Body $nuevo -Headers $headers -ContentType 'application/json'
Invoke-RestMethod -Uri "$base/prestamos" -Method Get -Headers $headers
```

## Desde Flutter

- Emulador Android: `http://10.0.2.2:8000`
- Dispositivo físico: la IP de tu PC en la red, por ejemplo `http://192.168.1.10:8000`
- Web/Windows: `http://localhost:8000`

Guarda el `access_token` y envíalo en cada petición como
`Authorization: Bearer <token>`.

## Estructura

```
API/
├── app/
│   ├── main.py          # FastAPI, lifespan, CORS, routers
│   ├── config.py        # Variables de entorno y URLs
│   ├── database.py      # Engine, sesiones, creación de BD/tablas
│   ├── models.py        # Usuario y Prestamo (SQLAlchemy)
│   ├── schemas.py       # Pydantic
│   ├── security.py      # bcrypt + JWT + get_current_user
│   └── routers/
│       ├── auth.py
│       └── prestamos.py
├── .env
├── .env.example
└── requirements.txt
```
