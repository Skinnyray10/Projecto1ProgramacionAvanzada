<script>
	import { onMount } from 'svelte';
	import { createWorld } from '$lib/world.js';

	const modules = [
		{
			id: 'ingresos',
			tag: 'Ingresos',
			title: 'Cada peso que entra, a la vista',
			copy: 'Registra cobros, ventas y transferencias. Clasifícalos y entiende de dónde viene tu dinero.',
			tone: 'from-violet-900 to-indigo-500'
		},
		{
			id: 'gastos',
			tag: 'Gastos',
			title: 'Corta fugas antes de que duelan',
			copy: 'Categorías, proveedores y límites. Ves qué se va —y qué puedes recortar esta semana.',
			tone: 'from-zinc-900 to-violet-700'
		},
		{
			id: 'balance',
			tag: 'Balance',
			title: 'El neto, en una sola mirada',
			copy: 'Ingresos menos gastos, actualizado al instante. Sin hojas de cálculo, sin sorpresas a fin de mes.',
			tone: 'from-violet-950 to-fuchsia-700'
		},
		{
			id: 'reportes',
			tag: 'Reportes',
			title: 'Decisiones con tendencia, no con feeling',
			copy: 'Periodos, comparativas y exportables. El argumento que necesitas para gastar —o para esperar.',
			tone: 'from-indigo-950 to-violet-500'
		}
	];

	const filters = ['Todos', 'Ingresos', 'Gastos', 'Balance', 'Reportes'];
	let filter = $state('Todos');
	let menu = $state(false);
	/** @type {HTMLCanvasElement} */
	let canvas = $state();
	/** @type {ReturnType<typeof createWorld> | undefined} */
	let world;

	const visible = $derived(filter === 'Todos' ? modules : modules.filter((m) => m.tag === filter));

	onMount(() => {
		world = createWorld(canvas);
		const onScroll = () => {
			const max = document.documentElement.scrollHeight - innerHeight;
			world?.setProgress(max ? scrollY / max : 0);
		};
		addEventListener('scroll', onScroll, { passive: true });
		return () => {
			removeEventListener('scroll', onScroll);
			world?.destroy();
		};
	});
</script>

<canvas bind:this={canvas} class="pointer-events-none fixed inset-0 z-0 h-dvh w-full"></canvas>

<header class="fixed inset-x-0 top-0 z-20 flex items-center justify-between bg-[#f3efe6]/80 px-6 py-5 backdrop-blur-sm md:px-10">
	<a href="#top" class="text-[15px] tracking-tight">hmdp<span class="align-super text-[9px]">®</span></a>
	<nav class="hidden gap-8 text-sm md:flex">
		<a href="#top">Inicio</a>
		<a href="#modulos">Módulos</a>
		<a href="#contacto">Contacto</a>
	</nav>
	<button class="grid h-9 w-9 place-items-center rounded-full bg-black text-xs text-white md:hidden" onclick={() => (menu = !menu)}>
		••
	</button>
</header>

{#if menu}
	<nav class="fixed inset-0 z-30 grid place-items-center bg-[#f3efe6] text-3xl font-serif">
		<button class="absolute right-6 top-6 text-sm" onclick={() => (menu = false)}>Cerrar</button>
		<div class="grid gap-5 text-center">
			<a href="#top" onclick={() => (menu = false)}>Inicio</a>
			<a href="#modulos" onclick={() => (menu = false)}>Módulos</a>
			<a href="#contacto" onclick={() => (menu = false)}>Contacto</a>
		</div>
	</nav>
{/if}

<section id="top" class="relative z-10 mx-auto max-w-3xl px-6 pt-28 pb-10 text-center md:pt-36">
	<p class="text-sm text-zinc-600">Software para negocios y equipos que quieren ver el dinero con nitidez.</p>
	<h1 class="mt-4 font-serif text-5xl leading-[0.95] md:text-7xl">Controla gastos e ingresos. Vende con certeza.</h1>
	<p class="mx-auto mt-6 max-w-xl text-zinc-700">
		HMDP es el sistema web donde registras cada entrada y cada salida, ves el balance real y dejas de adivinar si el mes cierra en verde.
	</p>
	<a href="#contacto" class="mt-8 inline-block rounded-full bg-violet-800 px-6 py-3 text-sm text-white">Quiero ver mi flujo de caja</a>
</section>

<section id="modulos" class="relative z-10 mx-auto max-w-6xl px-6 pb-8 pt-24">
	<h2 class="text-center font-serif text-5xl md:text-6xl">Módulos que venden claridad</h2>
	<div class="mt-8 flex flex-wrap justify-center gap-2">
		{#each filters as f}
			<button
				class="rounded-full border px-3 py-1.5 text-xs {filter === f
					? 'border-black bg-black text-white'
					: 'border-zinc-300 bg-white/70'}"
				onclick={() => (filter = f)}
			>
				{f}
				{#if f === 'Todos'}
					{modules.length}
				{/if}
			</button>
		{/each}
	</div>

	<div class="mt-10 grid gap-8 md:grid-cols-2">
		{#each visible as item}
			<article class="group">
				<div class="relative aspect-16/10 overflow-hidden rounded-sm bg-linear-to-br {item.tone} p-6 text-white shadow-xl">
					<p class="text-[11px] tracking-[0.2em] opacity-70">{item.tag.toUpperCase()}</p>
					<p class="mt-10 font-serif text-4xl">$ {item.tag === 'Gastos' ? '−' : ''}48,320</p>
					<div class="mt-6 h-16 rounded bg-white/15">
						<div class="h-full w-2/3 rounded bg-white/40"></div>
					</div>
					<p class="absolute bottom-4 right-5 text-xs opacity-60">HMDP live preview</p>
				</div>
				<div class="mt-3 flex items-start justify-between gap-4">
					<div>
						<h3 class="font-medium">{item.title}</h3>
						<p class="mt-1 text-sm text-zinc-600">{item.copy}</p>
					</div>
					<span class="mt-1 text-zinc-400">↓</span>
				</div>
			</article>
		{/each}
	</div>
</section>

<section id="contacto" class="relative z-10 mx-auto max-w-3xl px-6 py-28 text-center">
	<p class="text-sm">¿Listo para dejar la hoja de cálculo?</p>
	<h2 class="mt-3 font-serif text-5xl md:text-6xl">Empieza a gestionar tu dinero hoy</h2>
	<p class="mx-auto mt-5 max-w-md text-zinc-600">
		Ingresos, gastos, balance y reportes en un solo producto. Hecho para quien necesita números claros antes de invertir, contratar o expandir.
	</p>
	<a href="mailto:hola@hmdp.local" class="mt-8 inline-block text-sm underline">hola@hmdp.local</a>
</section>
