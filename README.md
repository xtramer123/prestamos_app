# PrestaFácil

App Flutter (Android) para gestionar préstamos, conectada a una API REST local hecha con FastAPI + MySQL (XAMPP).

Incluye login, registro, listado/búsqueda/filtros, detalle, registro, edición y eliminación de préstamos. Interfaz verde/blanco con tipografía Poppins.

## Credenciales de prueba

- Correo: `admin@prestafacil.com`
- Contraseña: `123456`

El botón **Usar demo** de la pantalla de login rellena automáticamente estos datos. Los préstamos de ejemplo se cargan con `API/seed_datos.py`.

## Estructura

```
├── lib/                 # App Flutter (screens, providers, models, services, widgets)
├── API/app/             # API FastAPI (config, database, models, schemas, security, routers)
├── API/seed_datos.py    # Usuario demo + 6 préstamos de prueba
├── API/smoke_test.ps1   # Prueba de extremo a extremo de la API
├── assets/fonts/        # Fuentes Poppins (sin dependencia de red)
└── test/                # Pruebas unitarias del modelo
```

## 1. Levantar la API

Requiere Python 3.10+ y XAMPP con MySQL/MariaDB en el puerto 3306 (usuario `root`, contraseña vacía por defecto).

```powershell
cd API
python -m pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

La base de datos `prestamos_db` y las tablas `usuario` y `prestamo` se crean automáticamente al iniciar. En otra terminal:

```powershell
cd API
python seed_datos.py
```

- Documentación interactiva: <http://localhost:8000/docs>
- Estado: <http://localhost:8000/health>

## 2. Ejecutar la app Flutter

```powershell
flutter pub get
flutter devices
flutter run -d <id-del-emulador>
```

La URL base por defecto es `http://10.0.2.2:8000` (localhost desde el emulador Android). Para otra IP:

```powershell
flutter run -d <id> --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

APK de depuración:

```powershell
flutter build apk --debug
```

El paquete Android es `com.apppractica.prestamos_app`. Se requiere `INTERNET` y `usesCleartextTraffic="true"` para HTTP local.

## Endpoints principales

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| POST | `/auth/register` | No | Crea prestamista y devuelve JWT |
| POST | `/auth/login` | No | Inicia sesión y devuelve JWT |
| GET | `/prestamos` | Sí | Lista los préstamos del usuario |
| GET | `/prestamos/{id}` | Sí | Obtiene un préstamo |
| POST | `/prestamos` | Sí | Registra un préstamo |
| PUT | `/prestamos/{id}` | Sí | Actualiza o marca como pagado |
| DELETE | `/prestamos/{id}` | Sí | Elimina un préstamo |

Cada préstamo incluye `total_a_cobrar = monto + interes`.

## Verificación

```powershell
flutter analyze
flutter test
cd API
powershell -ExecutionPolicy Bypass -File smoke_test.ps1
```

> Nota: este repositorio no incluye archivos `.gitignore` por solicitud expresa. Los artefactos generados (`build/`, `.dart_tool/`, cachés) no se subieron porque superan el límite de 100 MB por archivo de GitHub; el código fuente y la configuración sí están completos. `API/.env` contiene una clave de desarrollo de ejemplo: cámbiala en producción.
