import jwt from "jsonwebtoken";
import { env } from "../config/env.js";
import { fail } from "../utils/http.js";
import { findUserById } from "../services/userService.js";

export function signToken(user) {
  return jwt.sign(
    {
      sub: user.id,
      email: user.email,
      role: user.role,
    },
    env.jwtSecret,
    { expiresIn: env.jwtExpiresIn }
  );
}

export async function requireAuth(req, res, next) {
  const header = req.headers.authorization || "";
  const [scheme, token] = header.split(" ");

  if (scheme !== "Bearer" || !token) {
    return fail(res, "Token de autenticación requerido", 401);
  }

  try {
    const payload = jwt.verify(token, env.jwtSecret);
    const user = await findUserById(payload.sub);

    if (!user || !user.is_active) {
      return fail(res, "Usuario no autorizado", 401);
    }

    req.user = user;
    next();
  } catch {
    return fail(res, "Token inválido o expirado", 401);
  }
}

export function requireRoles(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return fail(res, "No tienes permisos para esta acción", 403);
    }
    next();
  };
}
