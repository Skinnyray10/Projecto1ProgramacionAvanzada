import { supabase } from "../config/supabase.js";

const COLUMNS =
  "id, sku, name, brand, category, stock, unit_price, description, is_active, created_at, updated_at";

export async function listParts() {
  const { data, error } = await supabase
    .from("parts")
    .select(COLUMNS)
    .order("created_at", { ascending: false });
  if (error) throw error;
  return data;
}

export async function findPartById(id) {
  const { data, error } = await supabase
    .from("parts")
    .select(COLUMNS)
    .eq("id", id)
    .maybeSingle();
  if (error) throw error;
  return data;
}

export async function createPart(fields) {
  const { data, error } = await supabase
    .from("parts")
    .insert({
      sku: String(fields.sku).trim().toUpperCase(),
      name: String(fields.name).trim(),
      brand: String(fields.brand || "").trim(),
      category: String(fields.category || "General").trim(),
      stock: Number(fields.stock) || 0,
      unit_price: Number(fields.unitPrice) || 0,
      description: String(fields.description || "").trim(),
    })
    .select(COLUMNS)
    .single();

  if (error) {
    if (error.code === "23505") {
      const conflict = new Error("El SKU ya está registrado");
      conflict.status = 409;
      throw conflict;
    }
    throw error;
  }
  return data;
}

export async function updatePart(id, fields) {
  const payload = {};
  if (fields.sku !== undefined) payload.sku = String(fields.sku).trim().toUpperCase();
  if (fields.name !== undefined) payload.name = String(fields.name).trim();
  if (fields.brand !== undefined) payload.brand = String(fields.brand).trim();
  if (fields.category !== undefined) payload.category = String(fields.category).trim();
  if (fields.stock !== undefined) payload.stock = Number(fields.stock);
  if (fields.unitPrice !== undefined) payload.unit_price = Number(fields.unitPrice);
  if (fields.description !== undefined) payload.description = String(fields.description).trim();
  if (typeof fields.isActive === "boolean") payload.is_active = fields.isActive;

  if (Object.keys(payload).length === 0) {
    const invalid = new Error("No hay campos para actualizar");
    invalid.status = 400;
    throw invalid;
  }

  const { data, error } = await supabase
    .from("parts")
    .update(payload)
    .eq("id", id)
    .select(COLUMNS)
    .maybeSingle();

  if (error) {
    if (error.code === "23505") {
      const conflict = new Error("El SKU ya está registrado");
      conflict.status = 409;
      throw conflict;
    }
    throw error;
  }
  if (!data) {
    const notFound = new Error("Pieza no encontrada");
    notFound.status = 404;
    throw notFound;
  }
  return data;
}

export async function deletePart(id) {
  const { data, error } = await supabase
    .from("parts")
    .delete()
    .eq("id", id)
    .select("id")
    .maybeSingle();
  if (error) throw error;
  if (!data) {
    const notFound = new Error("Pieza no encontrada");
    notFound.status = 404;
    throw notFound;
  }
  return data;
}
