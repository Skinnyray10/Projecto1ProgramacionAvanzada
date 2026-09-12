<script>
	import './layout.css';
	import { onMount } from 'svelte';
	import { theme } from '$lib/theme.svelte.js';

	let { children } = $props();
	let open = $state(false);

	onMount(() => theme.apply());
</script>

<svelte:head>
	<title>Ryan Rolando Garcia Galvan</title>
</svelte:head>

<header class="fixed inset-x-0 top-0 z-20 flex items-center justify-between bg-[#f3efe6]/85 px-5 py-4 backdrop-blur-md dark:bg-[#12081c]/85 md:px-10">
	<a href="/" class="text-[15px] tracking-tight">hmdp<span class="align-super text-[9px]">®</span></a>
	<nav class="hidden items-center gap-7 text-sm md:flex">
		<a href="/">Inicio</a>
		<a href="/#modulos">Módulos</a>
		<a href="/movimientos">Movimientos</a>
		<button
			class="rounded-full border border-zinc-300 px-3 py-1.5 text-xs dark:border-violet-400/40"
			onclick={() => theme.toggle()}
			type="button"
		>
			{theme.dark ? 'Modo claro' : 'Modo oscuro'}
		</button>
	</nav>
	<div class="flex items-center gap-2 md:hidden">
		<button class="rounded-full border border-zinc-300 px-3 py-1.5 text-xs dark:border-violet-400/40" onclick={() => theme.toggle()} type="button">
			{theme.dark ? 'Claro' : 'Oscuro'}
		</button>
		<button class="grid h-9 w-9 place-items-center rounded-full bg-black text-xs text-white dark:bg-violet-300 dark:text-black" onclick={() => (open = !open)}>
			••
		</button>
	</div>
</header>

{#if open}
	<nav class="fixed inset-0 z-30 grid place-items-center bg-[#f3efe6] text-3xl font-serif dark:bg-[#12081c]">
		<button class="absolute right-6 top-6 text-sm" onclick={() => (open = false)}>Cerrar</button>
		<div class="grid gap-5 text-center">
			<a href="/" onclick={() => (open = false)}>Inicio</a>
			<a href="/#modulos" onclick={() => (open = false)}>Módulos</a>
			<a href="/movimientos" onclick={() => (open = false)}>Movimientos</a>
		</div>
	</nav>
{/if}

{@render children()}
