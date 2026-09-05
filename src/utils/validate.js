const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const ROLES = new Set(["super_admin", "admin", "operator"]);

export function requireFields(body, fields) {
  return fields.filter((field) => {
    const value = body?.[field];
    return value === undefined || value === null || String(value).trim() === "";
  });
}

export function isValidEmail(email) {
  return EMAIL_RE.test(String(email).trim());
}

export function isValidRole(role) {
  return ROLES.has(role);
}

export function isStrongPassword(password) {
  return typeof password === "string" && password.length >= 8;
}
