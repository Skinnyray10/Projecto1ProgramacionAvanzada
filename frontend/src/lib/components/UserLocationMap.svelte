<script>
	import { onMount } from 'svelte';
	import 'leaflet/dist/leaflet.css';
	import markerIcon from 'leaflet/dist/images/marker-icon.png';
	import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png';
	import markerShadow from 'leaflet/dist/images/marker-shadow.png';

	/** @type {{ name?: string }} */
	let { name = 'Tú' } = $props();

	/** Chihuahua, Chih. — vista inicial mientras se obtiene la ubicación. */
	const DEFAULT_CENTER = /** @type {[number, number]} */ ([28.6353, -106.0889]);

	/** @type {HTMLDivElement} */
	let container;
	let status = $state('Obteniendo tu ubicación…');
	/** @type {{ lat: number, lng: number, accuracy: number } | null} */
	let position = $state(null);

	onMount(() => {
		/** @type {import('leaflet').Map | undefined} */
		let map;
		let destroyed = false;

		(async () => {
			// Leaflet usa `window` al importarse; solo puede cargarse en el navegador.
			const L = (await import('leaflet')).default;
			if (destroyed) return;

			map = L.map(container).setView(DEFAULT_CENTER, 12);
			L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
				maxZoom: 19,
				attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
			}).addTo(map);

			if (!('geolocation' in navigator)) {
				status = 'Tu navegador no soporta geolocalización.';
				return;
			}

			navigator.geolocation.getCurrentPosition(
				({ coords }) => {
					if (!map) return;
					const latlng = /** @type {[number, number]} */ ([coords.latitude, coords.longitude]);
					const icon = L.icon({
						iconUrl: markerIcon,
						iconRetinaUrl: markerIcon2x,
						shadowUrl: markerShadow,
						iconSize: [25, 41],
						iconAnchor: [12, 41],
						popupAnchor: [1, -34],
						shadowSize: [41, 41]
					});

					const popup = document.createElement('div');
					popup.innerHTML = '<strong></strong><br>Estás aquí';
					/** @type {HTMLElement} */ (popup.firstChild).textContent = name;

					L.circle(latlng, { radius: coords.accuracy, color: '#ff6a00', weight: 1 }).addTo(map);
					L.marker(latlng, { icon }).addTo(map).bindPopup(popup).openPopup();
					map.setView(latlng, 16);

					position = { lat: coords.latitude, lng: coords.longitude, accuracy: coords.accuracy };
					status = '';
				},
				(err) => {
					status =
						err.code === err.PERMISSION_DENIED
							? 'Permiso de ubicación denegado. Actívalo en el navegador para ver tu posición.'
							: 'No se pudo obtener tu ubicación.';
				},
				{ enableHighAccuracy: true, timeout: 15000 }
			);
		})();

		return () => {
			destroyed = true;
			map?.remove();
		};
	});
</script>

<section class="border border-zinc-200 bg-white dark:border-zinc-800 dark:bg-zinc-900">
	<header class="flex flex-wrap items-center justify-between gap-2 border-b-4 border-az-orange px-5 py-3">
		<h2 class="font-display text-xl font-bold uppercase">Tu ubicación</h2>
		{#if position}
			<p class="text-xs text-zinc-500">
				{position.lat.toFixed(5)}, {position.lng.toFixed(5)} · ±{Math.round(position.accuracy)} m
			</p>
		{/if}
	</header>
	{#if status}
		<p class="px-5 py-2 text-sm text-zinc-600 dark:text-zinc-400">{status}</p>
	{/if}
	<div bind:this={container} class="relative z-0 h-80 w-full"></div>
</section>
