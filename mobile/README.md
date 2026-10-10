# HMDP Zone — cliente móvil (Flutter)

App para clientes de la refaccionaria: iniciar sesión, crear cuenta y consultar el catálogo de piezas, con o sin internet.

## Requisitos previos

1. Ejecutar `sql/002_customer_role.sql` en Supabase (crea el rol `customer` que usan las cuentas creadas desde la app).
2. Desplegar el backend con el endpoint `POST /api/auth/register`.

## Ejecutar

```bash
cd mobile
flutter pub get
flutter run                                              # usa el backend en Render
flutter run --dart-define=API_URL=http://10.0.2.2:3000   # backend local desde el emulador Android
```

## Funcionamiento sin conexión

| Acción | Con internet | Sin internet |
| --- | --- | --- |
| Login | JWT del servidor; se guarda un hash salado de la contraseña | Solo cuentas ya usadas en el dispositivo; el JWT se pide al reconectar |
| Crear cuenta | `POST /api/auth/register` | Se encola en SQLite y se envía al reconectar |
| Catálogo | Se descarga y reemplaza la caché local | Búsqueda y filtros sobre la caché SQLite |

La sincronización (`lib/services/sync_service.dart`) se ejecuta al abrir la app, al recuperar la red, al volver a primer plano, cada 5 minutos y al deslizar hacia abajo en el catálogo. Primero envía las cuentas pendientes y después descarga las piezas.

Token, sesión y contraseñas pendientes se guardan en Keychain/Keystore (`flutter_secure_storage`); el catálogo y la cola de registros, en SQLite (`sqflite`).
