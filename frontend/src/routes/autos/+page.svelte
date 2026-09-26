<script>
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { api } from '$lib/api.js';
	import { session } from '$lib/session.svelte.js';

	/** @type {any[]} */
	let cars = $state([]);
	let error = $state('');
	let saving = $state(false);
	let form = $state({
		brand: '',
		model: '',
		year: String(new Date().getFullYear()),
		plates: '',
		color: '',
		ownerName: '',
		vin: '',
		notes: ''
	});

	async function load() {
		const data = await api('/api/cars', { token: session.token });
		cars = data.cars;
	}

	onMount(async () => {
		const ok = await session.hydrate();
		if (!ok) {
			await goto('/login');
			return;
		}
		try {
			await load();
		} catch (err) {
			error = err instanceof Error ? err.message : 'Error al cargar autos';
		}
	});

	async function add(/** @type {SubmitEvent} */ e) {
		e.preventDefault();
		saving = true;
		error = '';
		try {
			await api('/api/cars', {
				method: 'POST',
				token: session.token,
				body: {
					brand: form.brand,
					model: form.model,
					year: Number(form.year),
					plates: form.plates,
					color: form.color,
					ownerName: form.ownerName,
					vin: form.vin,
					notes: form.notes
				}
			});
			form = {
				brand: '',
				model: '',
				year: String(new Date().getFullYear()),
				plates: '',
				color: '',
				ownerName: '',
				vin: '',
				notes: ''
			};
			await load();
		} catch (err) {
			error = err instanceof Error ? err.message : 'No se pudo guardar';
		} finally {
			saving = false;
		}
	}

	async function remove(/** @type {string} */ id) {
		if (!confirm('¿Eliminar este auto?')) return;
		try {
			await api(`/api/cars/${id}`, { method: 'DELETE', token: session.token });
			await load();
		} catch (err) {
			error = err instanceof Error ? err.message : 'No se pudo eliminar';
		}
	}
</script>

<section class="bg-az-black px-4 py-8 text-white">
	<div class="mx-auto max-w-5xl">
		<p class="text-xs font-semibold uppercase tracking-[0.2em] text-az-orange">Taller</p>
		<h1 class="mt-2 font-display text-4xl font-bold uppercase">Autos</h1>
		<div class="mt-3 h-1.5 w-20 bg-az-orange"></div>
	</div>
</section>

<main class="mx-auto max-w-5xl px-4 py-8">
	{#if error}
		<p class="mb-4 border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>
	{/if}

	<form class="grid gap-3 border border-zinc-200 bg-white p-5 dark:border-zinc-800 dark:bg-zinc-900 sm:grid-cols-2" onsubmit={add}>
		<label class="text-xs font-bold uppercase">Marca<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" bind:value={form.brand} required /></label>
		<label class="text-xs font-bold uppercase">Modelo<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" bind:value={form.model} required /></label>
		<label class="text-xs font-bold uppercase">Año<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" type="number" min="1950" max="2100" bind:value={form.year} required /></label>
		<label class="text-xs font-bold uppercase">Placas<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" bind:value={form.plates} required /></label>
		<label class="text-xs font-bold uppercase">Color<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" bind:value={form.color} /></label>
		<label class="text-xs font-bold uppercase">Propietario<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" bind:value={form.ownerName} /></label>
		<label class="text-xs font-bold uppercase">VIN<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" bind:value={form.vin} /></label>
		<label class="text-xs font-bold uppercase">Notas<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" bind:value={form.notes} /></label>
		<button class="bg-az-red px-4 py-3 text-sm font-bold uppercase text-white sm:col-span-2" disabled={saving}>
			{saving ? 'Guardando…' : 'Registrar auto'}
		</button>
	</form>

	<ul class="mt-6 space-y-2">
		{#each cars as car}
			<li class="flex items-center justify-between gap-3 border border-zinc-200 bg-white px-4 py-3 text-sm dark:border-zinc-800 dark:bg-zinc-900">
				<div>
					<p class="font-bold uppercase">{car.brand} {car.model} ({car.year})</p>
					<p class="text-xs text-zinc-500">{car.plates} · {car.color || 'Sin color'} · {car.owner_name || 'Sin propietario'}</p>
				</div>
				{#if session.canManageUsers}
					<button class="text-xs font-bold uppercase text-az-red" type="button" onclick={() => remove(car.id)}>Eliminar</button>
				{/if}
			</li>
		{:else}
			<li class="text-sm text-zinc-500">Aún no hay autos.</li>
		{/each}
	</ul>
</main>
