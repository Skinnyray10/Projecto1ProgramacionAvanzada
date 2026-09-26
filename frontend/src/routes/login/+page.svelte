<script>
	import { goto } from '$app/navigation';
	import { session } from '$lib/session.svelte.js';

	let email = $state('admin@hmdp.local');
	let password = $state('');
	let error = $state('');
	let submitting = $state(false);

	async function onSubmit(/** @type {SubmitEvent} */ event) {
		event.preventDefault();
		error = '';
		submitting = true;
		try {
			await session.login(email, password);
			await goto('/piezas');
		} catch (err) {
			error = err instanceof Error ? err.message : 'No se pudo iniciar sesión';
		} finally {
			submitting = false;
		}
	}
</script>

<section class="bg-az-black px-4 py-10 text-white">
	<div class="mx-auto max-w-xl">
		<p class="text-xs font-semibold uppercase tracking-[0.2em] text-az-orange">Acceso al sistema</p>
		<h1 class="mt-2 font-display text-4xl font-bold uppercase">Ingresar</h1>
		<div class="mt-3 h-1.5 w-20 bg-az-orange"></div>
		<p class="mt-4 text-sm text-zinc-300">Usa tu cuenta de la refaccionaria para operar inventario y autos.</p>
	</div>
</section>

<main class="mx-auto max-w-xl px-4 py-10">
	<form class="border border-zinc-200 bg-white p-6 shadow-sm dark:border-zinc-800 dark:bg-zinc-900" onsubmit={onSubmit}>
		<label class="block text-xs font-bold uppercase tracking-wide"
			>Correo
			<input
				class="mt-2 w-full border border-zinc-300 bg-az-gray px-3 py-3 text-sm outline-none focus:border-az-orange dark:border-zinc-700 dark:bg-zinc-950"
				type="email"
				autocomplete="username"
				bind:value={email}
				required
			/>
		</label>
		<label class="mt-4 block text-xs font-bold uppercase tracking-wide"
			>Contraseña
			<input
				class="mt-2 w-full border border-zinc-300 bg-az-gray px-3 py-3 text-sm outline-none focus:border-az-orange dark:border-zinc-700 dark:bg-zinc-950"
				type="password"
				autocomplete="current-password"
				bind:value={password}
				required
			/>
		</label>
		{#if error}
			<p class="mt-4 border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700 dark:border-red-900 dark:bg-red-950/40 dark:text-red-300">
				{error}
			</p>
		{/if}
		<button
			class="mt-6 w-full bg-az-red px-4 py-3 text-sm font-bold uppercase tracking-wide text-white hover:bg-red-700 disabled:opacity-60"
			disabled={submitting}
		>
			{submitting ? 'Entrando…' : 'Ingresar'}
		</button>
	</form>
</main>
