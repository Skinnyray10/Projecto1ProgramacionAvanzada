<script>
	import { onMount } from 'svelte';
	import { createWorld } from '$lib/world.js';
	import { theme } from '$lib/theme.svelte.js';

	const modules = [
		{
			tag: 'Ingresos',
			title: 'Cada peso que entra, a la vista',
			copy: 'Registra cobros, ventas y transferencias. Clasifícalos y entiende de dónde viene tu dinero.',
			tone: 'from-violet-900 to-indigo-500'
		},
		{
			tag: 'Gastos',
			title: 'Corta fugas antes de que duelan',
			copy: 'Categorías, proveedores y límites. Ves qué se va —y qué puedes recortar esta semana.',
			tone: 'from-zinc-900 to-violet-700'
		},
		{
			tag: 'Balance',
			title: 'El neto, en una sola mirada',
			copy: 'Ingresos menos gastos, actualizado al instante. Sin hojas de cálculo, sin sorpresas a fin de mes.',
			tone: 'from-violet-950 to-fuchsia-700'
		},
		{
			tag: 'Reportes',
			title: 'Decisiones con tendencia, no con feeling',
			copy: 'Periodos, comparativas y exportables. El argumento que necesitas para gastar —o para esperar.',
			tone: 'from-indigo-950 to-violet-500'
		}
	];

	const filters = ['Todos', 'Ingresos', 'Gastos', 'Balance', 'Reportes'];
	let filter = $state('Todos');
	/** @type {HTMLCanvasElement | undefined} */
	let canvas = $state();
	/** @type {ReturnType<typeof createWorld> | undefined} */
	let world;
	const visible = $derived(filter === 'Todos' ? modules : modules.filter((m) => m.tag === filter));

	onMount(() => {
		if (!canvas) return;
		world = createWorld(canvas, () => theme.dark);
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

<canvas bind:this={canvas} class="scene"></canvas>

<section id="top" class="relative z-10 mx-auto max-w-3xl px-6 pt-28 pb-10 text-center md:pt-36">
	<p class="text-sm text-zinc-600 dark:text-violet-200/70">Software para negocios y equipos que quieren ver el dinero con nitidez.</p>
	<h1 class="mt-4 font-serif text-5xl leading-[0.95] md:text-7xl">Controla gastos e ingresos. Vende con certeza.</h1>
	<p class="mx-auto mt-6 max-w-xl text-zinc-700 dark:text-violet-100/80">
		HMDP es el sistema web donde registras cada entrada y cada salida, ves el balance real y dejas de adivinar si el mes cierra en verde.
	</p>
	<a href="/movimientos" class="mt-8 inline-block rounded-full bg-violet-800 px-6 py-3 text-sm text-white">Registrar gasto o ingreso</a>
</section>

<section id="modulos" class="relative z-10 mx-auto max-w-6xl px-6 pb-8 pt-24">
	<h2 class="text-center font-serif text-5xl md:text-6xl">Módulos que venden claridad</h2>
	<div class="mt-8 flex flex-wrap justify-center gap-2">
		{#each filters as f}
			<button
				class="rounded-full border px-3 py-1.5 text-xs {filter === f
					? 'border-black bg-black text-white dark:border-violet-200 dark:bg-violet-200 dark:text-black'
					: 'border-zinc-300 bg-white/70 dark:border-violet-400/30 dark:bg-white/5'}"
				onclick={() => (filter = f)}
			>
				{f}{f === 'Todos' ? ` ${modules.length}` : ''}
			</button>
		{/each}
	</div>

	<div class="mt-10 grid gap-8 md:grid-cols-2">
		{#each visible as item}
			<article>
				<div class="relative aspect-16/10 overflow-hidden rounded-sm bg-linear-to-br {item.tone} p-6 text-white shadow-xl">
					<p class="text-[11px] tracking-[0.2em] opacity-70">{item.tag.toUpperCase()}</p>
					<p class="mt-10 font-serif text-4xl">$ {item.tag === 'Gastos' ? '−' : ''}48,320</p>
					<div class="mt-6 h-16 rounded bg-white/15">
						<div class="h-full w-2/3 rounded bg-white/40"></div>
					</div>
				</div>
				<h3 class="mt-3 font-medium">{item.title}</h3>
				<p class="mt-1 text-sm text-zinc-600 dark:text-violet-200/70">{item.copy}</p>
			</article>
		{/each}
	</div>
</section>

<section id="contacto" class="relative z-10 mx-auto max-w-3xl px-6 py-28 text-center">
	<h2 class="font-serif text-5xl md:text-6xl">Empieza a gestionar tu dinero hoy</h2>
	<a href="/movimientos" class="mt-8 inline-block rounded-full bg-violet-800 px-6 py-3 text-sm text-white">Ir a movimientos</a>
</section>
