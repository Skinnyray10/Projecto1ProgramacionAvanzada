<script>
	import { onMount } from 'svelte';
	import 'leaflet/dist/leaflet.css';
	import markerIcon from 'leaflet/dist/images/marker-icon.png';
	import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png';
	import markerShadow from 'leaflet/dist/images/marker-shadow.png';
	import { api } from '$lib/api.js';

	/** @type {{ token: string }} */
	let { token } = $props();

	const REFRESH_MS = 60_000;
	/** Chihuahua, Chih. — vista inicial mientras no haya ubicaciones. */
	const DEFAULT_CENTER = /** @type {[number, number]} */ ([28.6353, -106.0889]);

	/**
	 * @typedef {{ user_id: string, latitude: number, longitude: number, accuracy: number | null,
	 *   recorded_at: string, users: { full_name: string, email: string, role: string } | null }} UserLocation
	 */

	/** @type {HTMLDivElement} */
	let container;
	/** @type {UserLocation[]} */
	let locations = $state([]);
	let status = $state('Cargando ubicaciones…');
	/** @type {Date | null} */
	let updatedAt = $state(null);

	/** @param {string} iso */
	function ago(iso) {
		const minutes = Math.round((Date.now() - new Date(iso).getTime()) / 60_000);
		if (minutes < 1) return 'hace un momento';
		if (minutes < 60) return `hace ${minutes} min`;
		const hours = Math.round(minutes / 60);
		return hours < 24 ? `hace ${hours} h` : `hace ${Math.round(hours / 24)} d`;
	}

	/** @param {UserLocation} loc */
	function popupContent(loc) {
		const el = document.createElement('div');
		const name = document.createElement('strong');
		name.textContent = loc.users?.full_name ?? 'Usuario';
		const detail = document.createElement('div');
		detail.textContent = `${loc.users?.email ?? ''} · ${ago(loc.recorded_at)}`;
		el.append(name, detail);
		return el;
	}

	onMount(() => {
		/** @type {import('leaflet').Map | undefined} */
		let map;
		/** @type {Map<string, import('leaflet').Marker>} */
		const markers = new Map();
		/** @type {ReturnType<typeof setInterval> | undefined} */
		let timer;
		let destroyed = false;
		let fitted = false;

		/** @param {typeof import('leaflet')} L */
		async function refresh(L) {
			try {
				const data = await api('/api/locations', { token });
				if (destroyed || !map) return;
				locations = data.locations;
				updatedAt = new Date();
				status = locations.length ? '' : 'Ningún usuario ha compartido su ubicación desde la app móvil.';
			} catch (err) {
				status = err instanceof Error ? err.message : 'No se pudieron cargar las ubicaciones';
				return;
			}

			const icon = L.icon({
				iconUrl: markerIcon,
				iconRetinaUrl: markerIcon2x,
				shadowUrl: markerShadow,
				iconSize: [25, 41],
				iconAnchor: [12, 41],
				popupAnchor: [1, -34],
				shadowSize: [41, 41]
			});

			const seen = new Set();
			for (const loc of locations) {
				seen.add(loc.user_id);
				const latlng = /** @type {[number, number]} */ ([loc.latitude, loc.longitude]);
				const marker = markers.get(loc.user_id);
				if (marker) {
					marker.setLatLng(latlng).setPopupContent(popupContent(loc));
				} else {
					markers.set(loc.user_id, L.marker(latlng, { icon }).addTo(map).bindPopup(popupContent(loc)));
				}
			}
			for (const [id, marker] of markers) {
				if (!seen.has(id)) {
					marker.remove();
					markers.delete(id);
				}
			}

			if (!fitted && locations.length) {
				fitted = true;
				const bounds = L.latLngBounds(locations.map((l) => [l.latitude, l.longitude]));
				map.fitBounds(bounds, { maxZoom: 16, padding: [40, 40] });
				if (locations.length === 1) markers.get(locations[0].user_id)?.openPopup();
			}
		}

		(async () => {
			// Leaflet usa `window` al importarse; solo puede cargarse en el navegador.
			const L = (await import('leaflet')).default;
			if (destroyed) return;

			map = L.map(container).setView(DEFAULT_CENTER, 12);
			L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
				maxZoom: 19,
				attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
			}).addTo(map);

			await refresh(L);
			timer = setInterval(() => refresh(L), REFRESH_MS);
		})();

		return () => {
			destroyed = true;
			clearInterval(timer);
			map?.remove();
		};
	});
</script>

<section class="border border-zinc-200 bg-white dark:border-zinc-800 dark:bg-zinc-900">
	<header class="flex flex-wrap items-center justify-between gap-2 border-b-4 border-az-orange px-5 py-3">
		<h2 class="font-display text-xl font-bold uppercase">Ubicación de la app móvil</h2>
		{#if updatedAt}
			<p class="text-xs text-zinc-500">
				{locations.length} usuario(s) · actualizado {updatedAt.toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' })} · cada minuto
			</p>
		{/if}
	</header>
	{#if status}
		<p class="px-5 py-2 text-sm text-zinc-600 dark:text-zinc-400">{status}</p>
	{/if}
	<div bind:this={container} class="relative z-0 h-80 w-full"></div>
</section>
