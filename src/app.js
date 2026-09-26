import express from "express";
import cors from "cors";
import helmet from "helmet";
import authRoutes from "./routes/auth.js";
import userRoutes from "./routes/users.js";
import partRoutes from "./routes/parts.js";
import carRoutes from "./routes/cars.js";

const app = express();

app.use(
  helmet({
    crossOriginResourcePolicy: { policy: "cross-origin" },
    contentSecurityPolicy: false,
  })
);
app.use(cors({ origin: true, credentials: false }));
app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "hmdp-refaccionaria-api" });
});

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/parts", partRoutes);
app.use("/api/cars", carRoutes);

export default app;
