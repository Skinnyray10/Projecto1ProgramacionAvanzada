import { fail, success } from "../utils/http.js";
import { listLocations, saveLocation } from "../services/locationService.js";

function inRange(value, min, max) {
  return typeof value === "number" && Number.isFinite(value) && value >= min && value <= max;
}

export async function putMyLocation(req, res) {
  const { latitude, longitude, accuracy, recordedAt } = req.body ?? {};
  if (!inRange(latitude, -90, 90) || !inRange(longitude, -180, 180)) {
    return fail(res, "Coordenadas inválidas", 400);
  }

  const recorded = recordedAt ? new Date(recordedAt) : new Date();
  if (Number.isNaN(recorded.getTime())) return fail(res, "Fecha inválida", 400);

  const location = await saveLocation(req.user.id, {
    latitude,
    longitude,
    accuracy: inRange(accuracy, 0, 1e6) ? accuracy : null,
    recordedAt: recorded.toISOString(),
  });
  return success(res, { location });
}

export async function getLocations(_req, res) {
  const locations = await listLocations();
  return success(res, { locations });
}
