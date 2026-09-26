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

	let response;
	try {
		response = await fetch(path, {
			method,
			headers,
			body: body ? JSON.stringify(body) : undefined
		});
	} catch {
		throw new Error(
			'No se pudo conectar con el API. En la raíz del proyecto ejecuta: npm run dev (puerto 3000).'
		);
	}

	const raw = await response.text();
	let json;
	try {
		json = raw ? JSON.parse(raw) : null;
	} catch {
		if (!response.ok) {
			throw new Error(
				'El API no está disponible o no devolvió JSON. Confirma que el backend corre en el puerto 3000.'
			);
		}
		throw new Error('Respuesta inválida del servidor');
	}

	if (!response.ok || !json?.ok) {
		throw new Error(json?.error || `Error del servidor (${response.status})`);
	}

	return json.data;
}
