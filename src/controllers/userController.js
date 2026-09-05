import { fail, success } from "../utils/http.js";
import { isStrongPassword, isValidEmail, isValidRole, requireFields } from "../utils/validate.js";
import {
  createUser,
  deleteUser,
  findUserById,
  listUsers,
  toPublicUser,
  updateUser,
} from "../services/userService.js";

export async function getUsers(_req, res) {
  const users = await listUsers();
  return success(res, { users });
}

export async function getUser(req, res) {
  const user = await findUserById(req.params.id);
  if (!user) {
    return fail(res, "Usuario no encontrado", 404);
  }
  return success(res, { user: toPublicUser(user) });
}

export async function postUser(req, res) {
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

  const role = req.body.role || "operator";
  if (!isValidRole(role)) {
    return fail(res, "Rol inválido", 400);
  }

  if (role === "super_admin" && req.user.role !== "super_admin") {
    return fail(res, "Solo un super_admin puede crear otro super_admin", 403);
  }

  const user = await createUser({
    email: req.body.email,
    password: req.body.password,
    fullName: req.body.fullName,
    role,
  });

  return success(res, { user }, 201);
}

export async function patchUser(req, res) {
  if (req.body.email && !isValidEmail(req.body.email)) {
    return fail(res, "Correo inválido", 400);
  }

  if (req.body.password && !isStrongPassword(req.body.password)) {
    return fail(res, "La contraseña debe tener al menos 8 caracteres", 400);
  }

  if (req.body.role) {
    if (!isValidRole(req.body.role)) {
      return fail(res, "Rol inválido", 400);
    }
    if (req.body.role === "super_admin" && req.user.role !== "super_admin") {
      return fail(res, "Solo un super_admin puede asignar ese rol", 403);
    }
  }

  const user = await updateUser(req.params.id, {
    email: req.body.email,
    fullName: req.body.fullName,
    role: req.body.role,
    isActive: req.body.isActive,
    password: req.body.password,
  });

  return success(res, { user });
}

export async function removeUser(req, res) {
  if (req.params.id === req.user.id) {
    return fail(res, "No puedes eliminar tu propia cuenta", 400);
  }

  await deleteUser(req.params.id);
  return success(res, { deleted: true });
}
