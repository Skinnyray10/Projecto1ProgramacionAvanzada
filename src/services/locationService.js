import { supabase } from "../config/supabase.js";

function missingTableError(error) {
  if (error.code !== "PGRST205") return error;
  const missing = new Error(
    "La tabla user_locations no existe. Ejecuta sql/003_user_locations.sql en Supabase",
  );
  missing.status = 503;
  return missing;
}

export async function saveLocation(userId, { latitude, longitude, accuracy, recordedAt }) {
  const { data, error } = await supabase
    .from("user_locations")
    .upsert({
      user_id: userId,
      latitude,
      longitude,
      accuracy,
      recorded_at: recordedAt,
      updated_at: new Date().toISOString(),
    })
    .select("user_id, latitude, longitude, accuracy, recorded_at")
    .single();
  if (error) throw missingTableError(error);
  return data;
}

export async function listLocations() {
  const { data, error } = await supabase
    .from("user_locations")
    .select("user_id, latitude, longitude, accuracy, recorded_at, users(full_name, email, role)")
    .order("recorded_at", { ascending: false });
  if (error) throw missingTableError(error);
  return data;
}
