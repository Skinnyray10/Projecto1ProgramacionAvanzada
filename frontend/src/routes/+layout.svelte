<script>
	import './layout.css';
	import { onMount } from 'svelte';
	import { theme } from '$lib/theme.svelte.js';
	import { session } from '$lib/session.svelte.js';

	let { children } = $props();
	let open = $state(false);

	onMount(() => {
		theme.apply();
		session.hydrate();
	});
</script>

<svelte:head>
	<title>HMDP Refaccionaria</title>
</svelte:head>

<div class="bg-zinc-200 px-4 py-2 text-center text-[11px] font-semibold uppercase tracking-wide text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200">
	Grandes promociones en refacciones · Inventario, autos y usuarios en un solo sistema
</div>

<header class="sticky top-0 z-20 border-b border-zinc-200 bg-white dark:border-zinc-800 dark:bg-zinc-950">
	<div class="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-3">
		<a href="/" class="flex items-center gap-2">
			<span class="grid h-10 w-10 place-items-center rounded bg-az-red font-display text-lg font-bold text-white">H</span>
			<span class="font-display text-2xl font-bold uppercase tracking-wide">
				HMDP<span class="text-az-orange">Zone</span>
			</span>
		</a>

		<nav class="hidden items-center gap-5 text-sm font-semibold uppercase tracking-wide md:flex">
			<a href="/" class="hover:text-az-red">Inicio</a>
			<a href="/piezas" class="hover:text-az-red">Piezas</a>
			<a href="/autos" class="hover:text-az-red">Autos</a>
			{#if session.user}
				<a href="/usuarios" class="hover:text-az-red">Usuarios</a>
				<button class="text-zinc-500 hover:text-az-red" type="button" onclick={() => session.logout()}>Salir</button>
			{:else}
				<a href="/login" class="hover:text-az-red">Ingresar</a>
			{/if}
			<button
				class="rounded border border-zinc-300 px-3 py-1 text-xs normal-case tracking-normal dark:border-zinc-600"
				onclick={() => theme.toggle()}
				type="button"
			>
				{theme.dark ? 'Claro' : 'Oscuro'}
			</button>
		</nav>

		<button
			class="grid h-10 w-10 place-items-center rounded border border-zinc-300 text-xs font-bold md:hidden dark:border-zinc-700"
			onclick={() => (open = !open)}
			type="button"
		>
			Menú
		</button>
	</div>

	<div class="border-t border-zinc-100 bg-az-gray px-4 py-3 dark:border-zinc-800 dark:bg-zinc-900">
		<div class="mx-auto flex max-w-6xl flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
			<p class="text-sm text-zinc-700 dark:text-zinc-300">Encuentra refacciones, registra autos y gestiona tu equipo</p>
			<div class="flex gap-4 text-sm font-semibold">
				<a href="/autos" class="text-az-red hover:underline">+ Agregar vehículo</a>
				<a href="/piezas" class="text-az-red hover:underline">Ver inventario</a>
			</div>
		</div>
	</div>
</header>

{#if open}
	<nav class="fixed inset-0 z-30 grid place-items-center bg-white text-2xl font-display uppercase dark:bg-zinc-950">
		<button class="absolute right-6 top-6 text-sm font-sans normal-case" onclick={() => (open = false)}>Cerrar</button>
		<div class="grid gap-5 text-center">
			<a href="/" onclick={() => (open = false)}>Inicio</a>
			<a href="/piezas" onclick={() => (open = false)}>Piezas</a>
			<a href="/autos" onclick={() => (open = false)}>Autos</a>
			{#if session.user}
				<a href="/usuarios" onclick={() => (open = false)}>Usuarios</a>
			{:else}
				<a href="/login" onclick={() => (open = false)}>Ingresar</a>
			{/if}
		</div>
	</nav>
{/if}

<div class="min-h-[70vh]">
	{@render children()}
</div>

<footer class="border-t-4 border-az-orange bg-az-black px-6 py-8 text-center text-sm text-zinc-300">
	<p class="font-display text-lg uppercase tracking-wide text-white">Ryan Rolando Garcia Galvan</p>
	<p class="mt-1 font-display text-lg uppercase tracking-wide text-white">Jean Sebastian De La Rosa Escobedo</p>
	<p class="mt-2 text-xs text-zinc-400">HMDP Refaccionaria · Sistema de piezas, autos y usuarios</p>
</footer>
