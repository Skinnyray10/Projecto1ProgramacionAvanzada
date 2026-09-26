import { Router } from "express";
import {
  getCar,
  getCars,
  patchCar,
  postCar,
  removeCar,
} from "../controllers/carController.js";
import { requireAuth, requireRoles } from "../middleware/auth.js";
import { asyncHandler } from "../utils/http.js";

const router = Router();

router.use(requireAuth);

router.get("/", asyncHandler(getCars));
router.get("/:id", asyncHandler(getCar));
router.post("/", requireRoles("super_admin", "admin", "operator"), asyncHandler(postCar));
router.patch("/:id", requireRoles("super_admin", "admin", "operator"), asyncHandler(patchCar));
router.delete("/:id", requireRoles("super_admin", "admin"), asyncHandler(removeCar));

export default router;
