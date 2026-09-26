# Deploy en Render — un solo Web Service

## Configuración (recomendada)

Deja **Root Directory vacío** (borra `frontend` si estaba).

| Campo | Valor |
|---|---|
| Root Directory | *(vacío)* |
| Build Command | `npm run build:render` |
| Start Command | `npm run start:render` |

## Variables de entorno

Copia de tu `.env` local (Environment en Render):

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `JWT_SECRET`
- `JWT_EXPIRES_IN=8h`
- `BCRYPT_SALT_ROUNDS=12`

No uses `PUBLIC_API_URL`.

## Después de guardar

**Manual Deploy → Clear build cache & deploy**

En los logs debe aparecer:
`Sirviendo frontend SvelteKit + API REST`

Prueba: `https://TU-SERVICIO.onrender.com/health`
