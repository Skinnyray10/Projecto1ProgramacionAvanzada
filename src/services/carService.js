import { supabase } from "../config/supabase.js";

const COLUMNS =
  "id, brand, model, year, plates, color, owner_name, vin, notes, is_active, created_at, updated_at";

export async function listCars() {
  const { data, error } = await supabase
    .from("cars")
    .select(COLUMNS)
    .order("created_at", { ascending: false });
  if (error) throw error;
  return data;
}

export async function findCarById(id) {
  const { data, error } = await supabase
    .from("cars")
    .select(COLUMNS)
    .eq("id", id)
    .maybeSingle();
  if (error) throw error;
  return data;
}

export async function createCar(fields) {
  const { data, error } = await supabase
    .from("cars")
    .insert({
      brand: String(fields.brand).trim(),
      model: String(fields.model).trim(),
      year: Number(fields.year),
      plates: String(fields.plates).trim().toUpperCase(),
      color: String(fields.color || "").trim(),
      owner_name: String(fields.ownerName || "").trim(),
      vin: String(fields.vin || "").trim().toUpperCase(),
      notes: String(fields.notes || "").trim(),
    })
    .select(COLUMNS)
    .single();

  if (error) {
    if (error.code === "23505") {
      const conflict = new Error("Las placas ya están registradas");
      conflict.status = 409;
      throw conflict;
    }
    throw error;
  }
  return data;
}

export async function updateCar(id, fields) {
  const payload = {};
  if (fields.brand !== undefined) payload.brand = String(fields.brand).trim();
  if (fields.model !== undefined) payload.model = String(fields.model).trim();
  if (fields.year !== undefined) payload.year = Number(fields.year);
  if (fields.plates !== undefined) payload.plates = String(fields.plates).trim().toUpperCase();
  if (fields.color !== undefined) payload.color = String(fields.color).trim();
  if (fields.ownerName !== undefined) payload.owner_name = String(fields.ownerName).trim();
  if (fields.vin !== undefined) payload.vin = String(fields.vin).trim().toUpperCase();
  if (fields.notes !== undefined) payload.notes = String(fields.notes).trim();
  if (typeof fields.isActive === "boolean") payload.is_active = fields.isActive;

  if (Object.keys(payload).length === 0) {
    const invalid = new Error("No hay campos para actualizar");
    invalid.status = 400;
    throw invalid;
  }

  const { data, error } = await supabase
    .from("cars")
    .update(payload)
    .eq("id", id)
    .select(COLUMNS)
    .maybeSingle();

  if (error) {
    if (error.code === "23505") {
      const conflict = new Error("Las placas ya están registradas");
      conflict.status = 409;
      throw conflict;
    }
    throw error;
  }
  if (!data) {
    const notFound = new Error("Auto no encontrado");
    notFound.status = 404;
    throw notFound;
  }
  return data;
}

export async function deleteCar(id) {
  const { data, error } = await supabase
    .from("cars")
    .delete()
    .eq("id", id)
    .select("id")
    .maybeSingle();
  if (error) throw error;
  if (!data) {
    const notFound = new Error("Auto no encontrado");
    notFound.status = 404;
    throw notFound;
  }
  return data;
}
