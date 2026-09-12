<script>
	import { onMount } from 'svelte';
	import { loadMoves, money, saveMoves } from '$lib/money.js';

	const cats = {
		ingreso: ['Ventas', 'Servicios', 'Transferencia', 'Otro'],
		gasto: ['Renta', 'Nómina', 'Proveedores', 'Operación', 'Otro']
	};

	/** @type {{ id: string, type: 'ingreso' | 'gasto', amount: number, category: string, note: string, date: string }[]} */
	let items = $state([]);
	let type = $state(/** @type {'ingreso' | 'gasto'} */ ('gasto'));
	let amount = $state('');
	let category = $state('Operación');
	let note = $state('');
	let date = $state(new Date().toISOString().slice(0, 10));
	let error = $state('');

	const income = $derived(items.filter((i) => i.type === 'ingreso').reduce((a, b) => a + b.amount, 0));
	const spend = $derived(items.filter((i) => i.type === 'gasto').reduce((a, b) => a + b.amount, 0));
	const net = $derived(income - spend);

	onMount(() => {
		items = loadMoves();
	});

	/** @param {'ingreso' | 'gasto'} next */
	function setType(next) {
		type = next;
		category = cats[next][0];
	}

	function add(/** @type {SubmitEvent} */ e) {
		e.preventDefault();
		const n = Number(amount);
		if (!Number.isFinite(n) || n <= 0) {
			error = 'Ingresa un monto mayor a 0';
			return;
		}
		error = '';
		items = [
			{
				id: crypto.randomUUID(),
				type,
				amount: n,
				category,
				note: note.trim(),
				date
			},
			...items
		];
		saveMoves(items);
		amount = '';
		note = '';
	}

	function remove(/** @type {string} */ id) {
		items = items.filter((i) => i.id !== id);
		saveMoves(items);
	}
</script>

<main class="relative z-10 mx-auto max-w-3xl px-6 pt-28 pb-20">
	<p class="text-xs tracking-[0.25em] text-zinc-500 dark:text-violet-300/70">LIBRO</p>
	<h1 class="mt-2 font-serif text-5xl">Gastos e ingresos</h1>
	<p class="mt-3 text-sm text-zinc-600 dark:text-violet-200/70">Registra cada movimiento. El balance se actualiza al instante en este dispositivo.</p>

	<div class="mt-8 grid gap-3 sm:grid-cols-3">
		<div class="rounded-2xl border border-zinc-200 bg-white/70 p-4 dark:border-violet-400/20 dark:bg-white/5">
			<p class="text-xs text-zinc-500">Ingresos</p>
			<p class="mt-1 text-xl font-medium text-emerald-700 dark:text-emerald-300">{money(income)}</p>
		</div>
		<div class="rounded-2xl border border-zinc-200 bg-white/70 p-4 dark:border-violet-400/20 dark:bg-white/5">
			<p class="text-xs text-zinc-500">Gastos</p>
			<p class="mt-1 text-xl font-medium text-rose-700 dark:text-rose-300">{money(spend)}</p>
		</div>
		<div class="rounded-2xl border border-zinc-200 bg-white/70 p-4 dark:border-violet-400/20 dark:bg-white/5">
			<p class="text-xs text-zinc-500">Balance</p>
			<p class="mt-1 text-xl font-medium">{money(net)}</p>
		</div>
	</div>

	<form class="mt-10 grid gap-4 rounded-2xl border border-zinc-200 bg-white/80 p-5 dark:border-violet-400/20 dark:bg-[#1a0f28]/80" onsubmit={add}>
		<div class="flex gap-2">
			<button class="rounded-full px-4 py-2 text-sm {type === 'gasto' ? 'bg-black text-white dark:bg-violet-200 dark:text-black' : 'border border-zinc-300 dark:border-violet-400/30'}" type="button" onclick={() => setType('gasto')}>Gasto</button>
			<button class="rounded-full px-4 py-2 text-sm {type === 'ingreso' ? 'bg-black text-white dark:bg-violet-200 dark:text-black' : 'border border-zinc-300 dark:border-violet-400/30'}" type="button" onclick={() => setType('ingreso')}>Ingreso</button>
		</div>
		<label class="text-sm">Monto
			<input class="mt-1 w-full rounded-xl border border-zinc-300 bg-transparent px-3 py-2 dark:border-violet-400/30" type="number" min="0.01" step="0.01" bind:value={amount} required />
		</label>
		<label class="text-sm">Categoría
			<select class="mt-1 w-full rounded-xl border border-zinc-300 bg-transparent px-3 py-2 dark:border-violet-400/30 dark:bg-[#1a0f28]" bind:value={category}>
				{#each cats[type] as c}
					<option>{c}</option>
				{/each}
			</select>
		</label>
		<label class="text-sm">Fecha
			<input class="mt-1 w-full rounded-xl border border-zinc-300 bg-transparent px-3 py-2 dark:border-violet-400/30" type="date" bind:value={date} required />
		</label>
		<label class="text-sm">Nota
			<input class="mt-1 w-full rounded-xl border border-zinc-300 bg-transparent px-3 py-2 dark:border-violet-400/30" bind:value={note} placeholder="Opcional" />
		</label>
		{#if error}
			<p class="text-sm text-rose-600">{error}</p>
		{/if}
		<button class="rounded-full bg-violet-800 px-4 py-3 text-sm text-white">Agregar {type}</button>
	</form>

	<ul class="mt-8 space-y-2">
		{#each items as row}
			<li class="flex items-center justify-between gap-3 rounded-xl border border-zinc-200 bg-white/70 px-4 py-3 text-sm dark:border-violet-400/20 dark:bg-white/5">
				<div>
					<p class="font-medium">{row.category} · {row.type}</p>
					<p class="text-xs text-zinc-500">{row.date}{row.note ? ` · ${row.note}` : ''}</p>
				</div>
				<div class="flex items-center gap-3">
					<span class={row.type === 'ingreso' ? 'text-emerald-700 dark:text-emerald-300' : 'text-rose-700 dark:text-rose-300'}>
						{row.type === 'ingreso' ? '+' : '−'}{money(row.amount)}
					</span>
					<button class="text-xs text-zinc-400 hover:text-rose-500" type="button" onclick={() => remove(row.id)}>Quitar</button>
				</div>
			</li>
		{:else}
			<li class="text-sm text-zinc-500">Aún no hay movimientos.</li>
		{/each}
	</ul>
</main>
