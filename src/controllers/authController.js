import { isStrongPassword, isValidEmail, requireFields } from "../utils/validate.js";
import { fail, success } from "../utils/http.js";
import { verifyPassword } from "../utils/password.js";
import { signToken } from "../middleware/auth.js";
import {
  countUsers,
  createUser,
  findUserByEmail,
  markLastLogin,
  toPublicUser,
} from "../services/userService.js";

export async function bootstrap(req, res) {
  const missing = requireFields(req.body, ["email", "password", "fullName"]);
  if (missing.length) {
    return fail(res, `Faltan campos: ${missing.join(", ")}`, 400);
  }

  if (!isValidEmail(req.body.email)) {
    return fail(res, "Correo inválido", 400);
  }

  if (!isStrongPassword(req.body.password)) {
    return fail(res, "La contraseña debe tener al menos 8 caracteres", 400);
  }

  const existing = await countUsers();
  if (existing > 0) {
    return fail(res, "El sistema ya tiene un administrador. Usa /api/auth/login", 409);
  }

  const user = await createUser({
    email: req.body.email,
    password: req.body.password,
    fullName: req.body.fullName,
    role: "super_admin",
  });

  const token = signToken(user);
  return success(res, { token, user }, 201);
}

export async function login(req, res) {
  const missing = requireFields(req.body, ["email", "password"]);
  if (missing.length) {
    return fail(res, `Faltan campos: ${missing.join(", ")}`, 400);
  }

  const user = await findUserByEmail(req.body.email);
  if (!user) {
    return fail(res, "Credenciales inválidas", 401);
  }

  const valid = await verifyPassword(req.body.password, user.password_hash);
  if (!valid) {
    return fail(res, "Credenciales inválidas", 401);
  }

  if (!user.is_active) {
    return fail(res, "La cuenta está desactivada", 403);
  }

  await markLastLogin(user.id);
  const token = signToken(user);
  return success(res, { token, user: toPublicUser(user) });
}

export async function me(req, res) {
  return success(res, { user: toPublicUser(req.user) });
}
