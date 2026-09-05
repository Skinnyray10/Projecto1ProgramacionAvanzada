import { Router } from "express";
import {
  getUser,
  getUsers,
  patchUser,
  postUser,
  removeUser,
} from "../controllers/userController.js";
import { requireAuth, requireRoles } from "../middleware/auth.js";
import { asyncHandler } from "../utils/http.js";

const router = Router();

router.use(requireAuth);

router.get("/", asyncHandler(getUsers));
router.get("/:id", asyncHandler(getUser));
router.post("/", requireRoles("super_admin", "admin"), asyncHandler(postUser));
router.patch("/:id", requireRoles("super_admin", "admin"), asyncHandler(patchUser));
router.delete("/:id", requireRoles("super_admin"), asyncHandler(removeUser));

export default router;
