import { Router } from "express";
import { getLocations, putMyLocation } from "../controllers/locationController.js";
import { requireAuth, requireRoles } from "../middleware/auth.js";
import { asyncHandler } from "../utils/http.js";

const router = Router();

router.use(requireAuth);

router.put("/me", asyncHandler(putMyLocation));
router.get("/", requireRoles("super_admin", "admin"), asyncHandler(getLocations));

export default router;
