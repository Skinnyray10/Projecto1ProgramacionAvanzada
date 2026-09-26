import fs from 'fs';
import path from 'path';
import { fileURLToPath, pathToFileURL } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const unifiedServer = path.resolve(__dirname, '../src/server.js');
const svelteIndex = path.resolve(__dirname, 'build/index.js');

if (fs.existsSync(unifiedServer)) {
	await import(pathToFileURL(unifiedServer).href);
} else if (fs.existsSync(svelteIndex)) {
	console.warn('No se encontró el API en ../src. Solo se sirve el frontend.');
	await import(pathToFileURL(svelteIndex).href);
} else {
	console.error('No hay build de frontend ni servidor unificado.');
	process.exit(1);
}
