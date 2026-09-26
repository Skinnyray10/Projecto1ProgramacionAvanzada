#!/usr/bin/env bash
set -euo pipefail

# Siempre instala API (raíz) + frontend y genera el build de SvelteKit.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Instalando dependencias del API (raíz)"
npm install

echo "==> Instalando y construyendo frontend"
npm install --prefix frontend
npm run build --prefix frontend

echo "==> Build Render listo"
