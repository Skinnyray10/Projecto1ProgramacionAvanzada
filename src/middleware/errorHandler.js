import { env } from "../config/env.js";
import { fail } from "../utils/http.js";

export function notFound(_req, res) {
  return fail(res, "Ruta no encontrada", 404);
}

export function errorHandler(err, _req, res, _next) {
  console.error(err);
  const status = err.status || 500;
  const message =
    status === 500 && env.nodeEnv === "production"
      ? "Error interno del servidor"
      : err.message || "Error interno del servidor";
  return fail(res, message, status);
}
