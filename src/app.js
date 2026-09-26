import express from "express";
import cors from "cors";
import helmet from "helmet";
import authRoutes from "./routes/auth.js";
import userRoutes from "./routes/users.js";
import partRoutes from "./routes/parts.js";
import carRoutes from "./routes/cars.js";
import { errorHandler, notFound } from "./middleware/errorHandler.js";

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "hmdp-refaccionaria-api" });
});

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/parts", partRoutes);
app.use("/api/cars", carRoutes);

app.use(notFound);
app.use(errorHandler);

export default app;
