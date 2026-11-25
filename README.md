# PrestaFácil — app Flutter + API FastAPI/MySQL

Proyecto para compartir: **estructura completa de la app Flutter + API REST**. Los artefactos generados (`build/`, `.dart_tool/`, APKs) **no están incluidos**: compílalos tú con los pasos de abajo. Hay un `.gitignore` que excluye únicamente generados, cachés, rutas locales del SDK y archivos de IDE; todo lo necesario para compilar y ejecutar está versionado.

## Credenciales de prueba

- Correo: `admin@prestafacil.com`
- Contraseña: `123456`

El botón **Usar demo** rellena los campos automáticamente. Los 6 préstamos de ejemplo los crea `API/seed_datos.py`.

---

## 1. Iniciar la API (FastAPI + MySQL de XAMPP)

**Requisitos:** Python 3.10+, XAMPP con MySQL/MariaDB en el puerto `3306` (usuario `root`, contraseña vacía por defecto).

1. Abre el **XAMPP Control Panel** y dale **Start** a **MySQL**.
2. Desde la raíz del proyecto, instala dependencias:

```powershell
cd API
python -m pip install -r requirements.txt
```

3. Levanta el servidor:

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

La base de datos `prestamos_db` y las tablas `usuario` y `prestamo` se crean **automáticamente** al iniciar (no hay que crearlas a mano).

4. En otra terminal, carga los datos de prueba:

```powershell
cd API
python seed_datos.py
```

Comprobaciones:

- Documentación interactiva: <http://localhost:8000/docs>
- Estado: <http://localhost:8000/health> → `{"status":"ok"}`

> Deja la API encendida mientras usas la app. Si se apaga, la app mostrará un error de conexión.

---

## 2. Iniciar la app Flutter (Android)

**Requisitos:** Flutter SDK y emulador Android iniciado (o celular con depuración USB).

1. Verifica el emulador:

```powershell
flutter devices
```

2. Desde la raíz del proyecto:

```powershell
flutter pub get
flutter run -d emulator-5554
```

La URL base por defecto es `http://10.0.2.2:8000` (equivale a `localhost` desde el emulador). Para un dispositivo físico usa la IP de tu PC:

```powershell
flutter run -d <id-del-dispositivo> --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

### Compilar el APK

```powershell
flutter build apk --debug
```

El resultado queda en:

- `build/app/outputs/flutter-apk/app-debug.apk`
- `build/app/outputs/apk/debug/app-debug.apk`

Instalación manual con ADB:

```powershell
adb install -r build\app\outputs\flutter-apk\app-debug.apk
adb shell monkey -p com.apppractica.prestamos_app -c android.intent.category.LAUNCHER 1
```

Paquete Android: `com.apppractica.prestamos_app`. El manifest tiene `INTERNET` y `usesCleartextTraffic="true"` para HTTP local.

---

## 3. Verificar que todo funciona

```powershell
flutter analyze
flutter test
cd API
powershell -ExecutionPolicy Bypass -File smoke_test.ps1
```

El smoke test cubre registro, login, 401 sin token, alta, total calculado, listado, obtención, actualización y eliminación.

## Endpoints

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| POST | `/auth/register` | No | Crea prestamista (bcrypt) y devuelve JWT |
| POST | `/auth/login` | No | Inicia sesión y devuelve JWT |
| GET | `/prestamos` | Sí | Lista los préstamos del usuario del token |
| GET | `/prestamos/{id}` | Sí | Obtiene un préstamo |
| POST | `/prestamos` | Sí | Registra un préstamo |
| PUT | `/prestamos/{id}` | Sí | Actualiza datos o marca `pagado` |
| DELETE | `/prestamos/{id}` | Sí | Elimina el préstamo |

Cada préstamo incluye `total_a_cobrar = monto + interes`.

## Estructura incluida

```
├── lib/                  # App Flutter (screens, providers, models, services, widgets, theme)
├── API/app/              # API FastAPI (config, database, models, schemas, security, routers)
├── API/seed_datos.py     # Usuario demo + 6 préstamos
├── API/smoke_test.ps1    # Prueba end-to-end de la API
├── assets/fonts/         # Poppins (sin depender de red en runtime)
├── android/              # Proyecto Android (con Gradle wrapper; sin carpeta windows)
├── test/                 # Pruebas unitarias
├── .gitignore            # Solo generados/cachés/rutas locales/IDE
└── pubspec.yaml          # Dependencias Flutter
```

> `API/.env` y `pubspec.lock` **sí están incluidos** porque se necesitan para ejecutar la API y fijar versiones. El `.gitignore` no los toca: solo excluye `build/`, `.dart_tool/`, cachés de Gradle/Python, `local.properties`, registrantes de plugins generados y archivos de IDE, que se regeneran solos.

> `API/.env` contiene una `SECRET_KEY` de desarrollo: cámbiala si sales de local.
