import { Router } from "express";
import {
  getPart,
  getParts,
  patchPart,
  postPart,
  removePart,
} from "../controllers/partController.js";
import { requireAuth, requireRoles } from "../middleware/auth.js";
import { asyncHandler } from "../utils/http.js";

const router = Router();

router.use(requireAuth);

router.get("/", asyncHandler(getParts));
router.get("/:id", asyncHandler(getPart));
router.post("/", requireRoles("super_admin", "admin", "operator"), asyncHandler(postPart));
router.patch("/:id", requireRoles("super_admin", "admin", "operator"), asyncHandler(patchPart));
router.delete("/:id", requireRoles("super_admin", "admin"), asyncHandler(removePart));

export default router;
