import { fail, success } from "../utils/http.js";
import { requireFields } from "../utils/validate.js";
import {
  createCar,
  deleteCar,
  findCarById,
  listCars,
  updateCar,
} from "../services/carService.js";

function toCustomerCar({ id, brand, model, year, color, is_active, updated_at }) {
  return { id, brand, model, year, color, is_active, updated_at };
}

export async function getCars(req, res) {
  const cars = await listCars();
  if (req.user.role !== "customer") return success(res, { cars });
  return success(res, { cars: cars.filter((c) => c.is_active).map(toCustomerCar) });
}

export async function getCar(req, res) {
  const car = await findCarById(req.params.id);
  const isCustomer = req.user.role === "customer";
  if (!car || (isCustomer && !car.is_active)) return fail(res, "Auto no encontrado", 404);
  return success(res, { car: isCustomer ? toCustomerCar(car) : car });
}

export async function postCar(req, res) {
  const missing = requireFields(req.body, ["brand", "model", "year", "plates"]);
  if (missing.length) return fail(res, `Faltan campos: ${missing.join(", ")}`, 400);

  const year = Number(req.body.year);
  if (!Number.isInteger(year) || year < 1950 || year > 2100) {
    return fail(res, "Año inválido", 400);
  }

  const car = await createCar({
    brand: req.body.brand,
    model: req.body.model,
    year,
    plates: req.body.plates,
    color: req.body.color,
    ownerName: req.body.ownerName,
    vin: req.body.vin,
    notes: req.body.notes,
  });
  return success(res, { car }, 201);
}

export async function patchCar(req, res) {
  if (req.body.year !== undefined) {
    const year = Number(req.body.year);
    if (!Number.isInteger(year) || year < 1950 || year > 2100) {
      return fail(res, "Año inválido", 400);
    }
  }

  const car = await updateCar(req.params.id, {
    brand: req.body.brand,
    model: req.body.model,
    year: req.body.year,
    plates: req.body.plates,
    color: req.body.color,
    ownerName: req.body.ownerName,
    vin: req.body.vin,
    notes: req.body.notes,
    isActive: req.body.isActive,
  });
  return success(res, { car });
}

export async function removeCar(req, res) {
  await deleteCar(req.params.id);
  return success(res, { deleted: true });
}
