import fs from "fs";
import path from "path";
import { fileURLToPath, pathToFileURL } from "url";
import app from "./app.js";
import { env } from "./config/env.js";
import { errorHandler, notFound } from "./middleware/errorHandler.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const frontendHandler = path.resolve(__dirname, "../frontend/build/handler.js");

async function start() {
  if (fs.existsSync(frontendHandler)) {
    const { handler } = await import(pathToFileURL(frontendHandler).href);
    app.use(handler);
    console.log("Sirviendo frontend SvelteKit + API REST");
  } else {
    app.use(notFound);
    console.log("Solo API (sin build de frontend)");
  }

  app.use(errorHandler);

  app.listen(env.port, "0.0.0.0", () => {
    console.log(`HMDP escuchando en http://0.0.0.0:${env.port}`);
  });
}

start().catch((err) => {
  console.error(err);
  process.exit(1);
});
