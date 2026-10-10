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
import { STAFF_ROLES } from "../utils/validate.js";

const router = Router();

router.use(requireAuth);

router.get("/", asyncHandler(getCars));
router.get("/:id", asyncHandler(getCar));
router.post("/", requireRoles(...STAFF_ROLES), asyncHandler(postCar));
router.patch("/:id", requireRoles(...STAFF_ROLES), asyncHandler(patchCar));
router.delete("/:id", requireRoles("super_admin", "admin"), asyncHandler(removeCar));

export default router;
