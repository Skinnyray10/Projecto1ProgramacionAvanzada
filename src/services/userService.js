import { supabase } from "../config/supabase.js";
import { hashPassword } from "../utils/password.js";

const PUBLIC_COLUMNS =
  "id, email, full_name, role, is_active, last_login_at, created_at, updated_at";

export function toPublicUser(user) {
  if (!user) return null;
  const { password_hash: _passwordHash, ...safeUser } = user;
  return safeUser;
}

export async function findUserByEmail(email) {
  const { data, error } = await supabase
    .from("users")
    .select("*")
    .eq("email", email.toLowerCase())
    .maybeSingle();

  if (error) throw error;
  return data;
}

export async function findUserById(id) {
  const { data, error } = await supabase
    .from("users")
    .select("*")
    .eq("id", id)
    .maybeSingle();

  if (error) throw error;
  return data;
}

export async function listUsers() {
  const { data, error } = await supabase
    .from("users")
    .select(PUBLIC_COLUMNS)
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data;
}

export async function countUsers() {
  const { count, error } = await supabase
    .from("users")
    .select("id", { count: "exact", head: true });

  if (error) throw error;
  return count || 0;
}

export async function createUser({ email, password, fullName, role = "operator" }) {
  const passwordHash = await hashPassword(password);
  const { data, error } = await supabase
    .from("users")
    .insert({
      email: email.toLowerCase().trim(),
      password_hash: passwordHash,
      full_name: fullName.trim(),
      role,
    })
    .select(PUBLIC_COLUMNS)
    .single();

  if (error) {
    if (error.code === "23505") {
      const conflict = new Error("El correo ya está registrado");
      conflict.status = 409;
      throw conflict;
    }
    throw error;
  }

  return data;
}

export async function updateUser(id, fields) {
  const payload = {};
  if (fields.email) payload.email = fields.email.toLowerCase().trim();
  if (fields.fullName) payload.full_name = fields.fullName.trim();
  if (fields.role) payload.role = fields.role;
  if (typeof fields.isActive === "boolean") payload.is_active = fields.isActive;
  if (fields.password) payload.password_hash = await hashPassword(fields.password);

  if (Object.keys(payload).length === 0) {
    const invalid = new Error("No hay campos para actualizar");
    invalid.status = 400;
    throw invalid;
  }

  const { data, error } = await supabase
    .from("users")
    .update(payload)
    .eq("id", id)
    .select(PUBLIC_COLUMNS)
    .maybeSingle();

  if (error) {
    if (error.code === "23505") {
      const conflict = new Error("El correo ya está registrado");
      conflict.status = 409;
      throw conflict;
    }
    throw error;
  }

  if (!data) {
    const notFound = new Error("Usuario no encontrado");
    notFound.status = 404;
    throw notFound;
  }

  return data;
}

export async function deleteUser(id) {
  const { data, error } = await supabase
    .from("users")
    .delete()
    .eq("id", id)
    .select("id")
    .maybeSingle();

  if (error) throw error;

  if (!data) {
    const notFound = new Error("Usuario no encontrado");
    notFound.status = 404;
    throw notFound;
  }

  return data;
}

export async function markLastLogin(id) {
  const { error } = await supabase
    .from("users")
    .update({ last_login_at: new Date().toISOString() })
    .eq("id", id);

  if (error) throw error;
}
