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
			await goto('/app');
		} catch (err) {
			error = err instanceof Error ? err.message : 'No se pudo iniciar sesión';
		} finally {
			submitting = false;
		}
	}
</script>

<main class="relative grid min-h-screen overflow-hidden lg:grid-cols-[1.1fr_0.9fr]">
	<section class="relative hidden flex-col justify-between p-12 lg:flex">
		<div>
			<p class="text-xs font-semibold tracking-[0.28em] text-glow/80">SISTEMA DE ADMINISTRACIÓN</p>
			<h1 class="mt-4 max-w-md text-5xl font-extrabold leading-tight text-ice">
				HMDP
				<span class="block text-accent-soft">control central</span>
			</h1>
			<p class="mt-6 max-w-sm text-sm leading-6 text-muted">
				Acceso seguro al panel. Las contraseñas viajan cifradas con bcrypt y cada sesión se firma con JWT.
			</p>
		</div>
		<div class="grid max-w-md grid-cols-3 gap-3 text-xs text-muted">
			<div class="rounded-2xl border border-white/10 bg-white/5 p-4">
				<p class="text-2xl font-bold text-ice">REST</p>
				<p class="mt-1">API Node.js</p>
			</div>
			<div class="rounded-2xl border border-white/10 bg-white/5 p-4">
				<p class="text-2xl font-bold text-ice">BCRYPT</p>
				<p class="mt-1">12 rondas</p>
			</div>
			<div class="rounded-2xl border border-white/10 bg-white/5 p-4">
				<p class="text-2xl font-bold text-ice">SB</p>
				<p class="mt-1">Supabase</p>
			</div>
		</div>
	</section>

	<section class="flex items-center justify-center p-6 sm:p-10">
		<form
			onsubmit={onSubmit}
			class="w-full max-w-md rounded-3xl border border-cyan-400/15 bg-navy-900/80 p-8 shadow-[0_0_80px_rgba(37,99,235,0.18)] backdrop-blur-xl"
		>
			<div class="mb-8">
				<div class="mb-5 inline-flex h-11 w-11 items-center justify-center rounded-2xl bg-blue-500/20 text-lg font-extrabold text-glow ring-1 ring-cyan-400/30">
					H
				</div>
				<h2 class="text-2xl font-bold">Iniciar sesión</h2>
				<p class="mt-1 text-sm text-muted">Usa una cuenta activa del sistema.</p>
			</div>

			<label class="mb-4 block text-sm font-medium">
				Correo
				<input
					class="mt-2 w-full rounded-xl border border-white/10 bg-navy-950 px-4 py-3 text-ice outline-none ring-accent/0 transition focus:border-accent-soft/50 focus:ring-4"
					type="email"
					autocomplete="username"
					bind:value={email}
					required
				/>
			</label>

			<label class="mb-6 block text-sm font-medium">
				Contraseña
				<input
					class="mt-2 w-full rounded-xl border border-white/10 bg-navy-950 px-4 py-3 text-ice outline-none ring-accent/0 transition focus:border-accent-soft/50 focus:ring-4"
					type="password"
					autocomplete="current-password"
					bind:value={password}
					required
				/>
			</label>

			{#if error}
				<p class="mb-4 rounded-xl border border-red-400/20 bg-red-500/10 px-3 py-2 text-sm text-red-200">
					{error}
				</p>
			{/if}

			<button
				class="w-full rounded-xl bg-linear-to-r from-blue-600 to-cyan-500 px-4 py-3 font-semibold text-white shadow-lg shadow-blue-900/40 transition hover:brightness-110 disabled:opacity-60"
				disabled={submitting}
			>
				{submitting ? 'Entrando…' : 'Entrar al panel'}
			</button>
		</form>
	</section>
</main>
