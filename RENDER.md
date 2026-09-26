# Deploy en Render (un solo Web Service)

## Opción recomendada (Root Directory vacío)

- Root Directory: (vacío)
- Build Command: `npm run build:render`
- Start Command: `npm start`

## Si Root Directory = `frontend`

- Build Command: `npm install && npm run build && cd .. && npm install`
- Start Command: `npm start`

Eso ejecuta `prod-server.js`, que levanta API + frontend.

## Variables de entorno

Copia desde tu `.env` local:

- SUPABASE_URL
- SUPABASE_SERVICE_ROLE_KEY
- JWT_SECRET
- JWT_EXPIRES_IN=8h
- BCRYPT_SALT_ROUNDS=12

No uses PUBLIC_API_URL en el deploy unificado.

Tras cambiar settings: Manual Deploy → Clear build cache & deploy.
