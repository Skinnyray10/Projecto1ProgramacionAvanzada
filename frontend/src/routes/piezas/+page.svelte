<script>
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { api } from '$lib/api.js';
	import { session } from '$lib/session.svelte.js';

	/** @type {any[]} */
	let parts = $state([]);
	let error = $state('');
	let saving = $state(false);
	let form = $state({
		sku: '',
		name: '',
		brand: '',
		category: 'General',
		stock: '0',
		unitPrice: '0',
		description: ''
	});

	async function load() {
		const data = await api('/api/parts', { token: session.token });
		parts = data.parts;
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
			error = err instanceof Error ? err.message : 'Error al cargar piezas';
		}
	});

	async function add(/** @type {SubmitEvent} */ e) {
		e.preventDefault();
		saving = true;
		error = '';
		try {
			await api('/api/parts', {
				method: 'POST',
				token: session.token,
				body: {
					sku: form.sku,
					name: form.name,
					brand: form.brand,
					category: form.category,
					stock: Number(form.stock),
					unitPrice: Number(form.unitPrice),
					description: form.description
				}
			});
			form = { sku: '', name: '', brand: '', category: 'General', stock: '0', unitPrice: '0', description: '' };
			await load();
		} catch (err) {
			error = err instanceof Error ? err.message : 'No se pudo guardar';
		} finally {
			saving = false;
		}
	}

	async function remove(/** @type {string} */ id) {
		if (!confirm('¿Eliminar esta pieza?')) return;
		try {
			await api(`/api/parts/${id}`, { method: 'DELETE', token: session.token });
			await load();
		} catch (err) {
			error = err instanceof Error ? err.message : 'No se pudo eliminar';
		}
	}
</script>

<section class="bg-az-black px-4 py-8 text-white">
	<div class="mx-auto max-w-5xl">
		<p class="text-xs font-semibold uppercase tracking-[0.2em] text-az-orange">Inventario</p>
		<h1 class="mt-2 font-display text-4xl font-bold uppercase">Piezas</h1>
		<div class="mt-3 h-1.5 w-20 bg-az-orange"></div>
	</div>
</section>

<main class="mx-auto max-w-5xl px-4 py-8">
	{#if error}
		<p class="mb-4 border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>
	{/if}

	<form class="grid gap-3 border border-zinc-200 bg-white p-5 dark:border-zinc-800 dark:bg-zinc-900 sm:grid-cols-2" onsubmit={add}>
		<label class="text-xs font-bold uppercase">SKU<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" bind:value={form.sku} required /></label>
		<label class="text-xs font-bold uppercase">Nombre<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" bind:value={form.name} required /></label>
		<label class="text-xs font-bold uppercase">Marca<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" bind:value={form.brand} /></label>
		<label class="text-xs font-bold uppercase">Categoría<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" bind:value={form.category} /></label>
		<label class="text-xs font-bold uppercase">Stock<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" type="number" min="0" bind:value={form.stock} /></label>
		<label class="text-xs font-bold uppercase">Precio<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" type="number" min="0" step="0.01" bind:value={form.unitPrice} /></label>
		<label class="text-xs font-bold uppercase sm:col-span-2">Descripción<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" bind:value={form.description} /></label>
		<button class="bg-az-red px-4 py-3 text-sm font-bold uppercase text-white sm:col-span-2" disabled={saving}>
			{saving ? 'Guardando…' : 'Agregar pieza'}
		</button>
	</form>

	<ul class="mt-6 space-y-2">
		{#each parts as part}
			<li class="flex items-center justify-between gap-3 border border-zinc-200 bg-white px-4 py-3 text-sm dark:border-zinc-800 dark:bg-zinc-900">
				<div>
					<p class="font-bold uppercase">{part.sku} · {part.name}</p>
					<p class="text-xs text-zinc-500">{part.brand || 'Sin marca'} · {part.category} · stock {part.stock} · ${Number(part.unit_price).toFixed(2)}</p>
				</div>
				{#if session.canManageUsers}
					<button class="text-xs font-bold uppercase text-az-red" type="button" onclick={() => remove(part.id)}>Eliminar</button>
				{/if}
			</li>
		{:else}
			<li class="text-sm text-zinc-500">Aún no hay piezas.</li>
		{/each}
	</ul>
</main>
