/**
 * @param {string} path
 * @param {{ method?: string, body?: Record<string, unknown>, token?: string | null }} [options]
 */
export async function api(path, options = {}) {
	const { method = 'GET', body, token } = options;
	/** @type {Record<string, string>} */
	const headers = {};
	if (body) headers['Content-Type'] = 'application/json';
	if (token) headers.Authorization = `Bearer ${token}`;

	let response;
	try {
		response = await fetch(path, {
			method,
			headers,
			body: body ? JSON.stringify(body) : undefined
		});
	} catch {
		throw new Error(
			'No se pudo conectar con el API. Arranca el backend con npm run dev en la raíz del proyecto (puerto 3000).'
		);
	}

	const json = await response.json().catch(() => ({
		ok: false,
		error: 'No se pudo leer la respuesta del servidor'
	}));

	if (!response.ok || !json.ok) {
		throw new Error(json.error || 'Error de conexión con el servidor');
	}

	return json.data;
}
