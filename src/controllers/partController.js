import { fail, success } from "../utils/http.js";
import { requireFields } from "../utils/validate.js";
import {
  createPart,
  deletePart,
  findPartById,
  listParts,
  updatePart,
} from "../services/partService.js";

export async function getParts(_req, res) {
  const parts = await listParts();
  return success(res, { parts });
}

export async function getPart(req, res) {
  const part = await findPartById(req.params.id);
  if (!part) return fail(res, "Pieza no encontrada", 404);
  return success(res, { part });
}

export async function postPart(req, res) {
  const missing = requireFields(req.body, ["sku", "name"]);
  if (missing.length) return fail(res, `Faltan campos: ${missing.join(", ")}`, 400);

  if (req.body.stock !== undefined && Number(req.body.stock) < 0) {
    return fail(res, "El stock no puede ser negativo", 400);
  }
  if (req.body.unitPrice !== undefined && Number(req.body.unitPrice) < 0) {
    return fail(res, "El precio no puede ser negativo", 400);
  }

  const part = await createPart({
    sku: req.body.sku,
    name: req.body.name,
    brand: req.body.brand,
    category: req.body.category,
    stock: req.body.stock,
    unitPrice: req.body.unitPrice,
    description: req.body.description,
  });
  return success(res, { part }, 201);
}

export async function patchPart(req, res) {
  if (req.body.stock !== undefined && Number(req.body.stock) < 0) {
    return fail(res, "El stock no puede ser negativo", 400);
  }
  if (req.body.unitPrice !== undefined && Number(req.body.unitPrice) < 0) {
    return fail(res, "El precio no puede ser negativo", 400);
  }

  const part = await updatePart(req.params.id, {
    sku: req.body.sku,
    name: req.body.name,
    brand: req.body.brand,
    category: req.body.category,
    stock: req.body.stock,
    unitPrice: req.body.unitPrice,
    description: req.body.description,
    isActive: req.body.isActive,
  });
  return success(res, { part });
}

export async function removePart(req, res) {
  await deletePart(req.params.id);
  return success(res, { deleted: true });
}
