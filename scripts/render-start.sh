#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ ! -d node_modules/express ]; then
  echo "ERROR: falta express. El Build Command debe instalar dependencias de la raíz."
  echo "Usa: npm run build:render   (o scripts/render-build.sh)"
  exit 1
fi

if [ ! -f frontend/build/handler.js ]; then
  echo "ERROR: falta frontend/build. Corre el build del frontend antes de start."
  exit 1
fi

exec node src/server.js
