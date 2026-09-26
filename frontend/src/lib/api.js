import { env } from '$env/dynamic/public';

function apiBase() {
	const base = (env.PUBLIC_API_URL || '').replace(/\/$/, '');
	return base;
}

/**
 * @param {string} path
 * @param {{ method?: string, body?: Record<string, unknown>, token?: string | null }} [options]
 */
export async function api(path, options = {}) {
	const { method = 'GET', body, token } = options;
	/** @type {Record<string, string>} */
	const headers = { Accept: 'application/json' };
	if (body) headers['Content-Type'] = 'application/json';
	if (token) headers.Authorization = `Bearer ${token}`;

	const url = `${apiBase()}${path}`;

	let response;
	try {
		response = await fetch(url, {
			method,
			headers,
			body: body ? JSON.stringify(body) : undefined
		});
	} catch {
		throw new Error(
			apiBase()
				? `No se pudo conectar con el API (${apiBase()}). Revisa que el servicio backend en Render esté activo.`
				: 'No se pudo conectar con el API. En local: npm run dev en la raíz (puerto 3000). En Render: configura PUBLIC_API_URL.'
		);
	}

	const raw = await response.text();
	let json;
	try {
		json = raw ? JSON.parse(raw) : null;
	} catch {
		throw new Error(
			apiBase()
				? `El API en ${apiBase()} no devolvió JSON. ¿El backend está desplegado y corriendo?`
				: 'El API no está disponible o no devolvió JSON. En local confirma el backend en :3000. En Render define PUBLIC_API_URL hacia tu Web Service del API.'
		);
	}

	if (!response.ok || !json?.ok) {
		throw new Error(json?.error || `Error del servidor (${response.status})`);
	}

	return json.data;
}
