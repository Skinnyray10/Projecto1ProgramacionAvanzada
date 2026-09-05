<script>
	import { onMount } from 'svelte';
	import { session } from '$lib/session.svelte.js';
	import { api } from '$lib/api.js';
	import { roleLabel } from '$lib/roles.js';

	let users = $state(/** @type {any[]} */ ([]));
	let error = $state('');

	const stats = $derived({
		total: users.length,
		active: users.filter((u) => u.is_active).length,
		admins: users.filter((u) => u.role === 'admin' || u.role === 'super_admin').length,
		operators: users.filter((u) => u.role === 'operator').length
	});

	onMount(async () => {
		try {
			const data = await api('/api/users', { token: session.token });
			users = data.users;
		} catch (err) {
			error = err instanceof Error ? err.message : 'No se pudieron cargar los datos';
		}
	});
</script>

<section>
	<div class="mb-8">
		<p class="text-xs font-semibold tracking-[0.24em] text-glow/80">PANEL</p>
		<h1 class="mt-2 text-3xl font-extrabold">Hola, {session.user?.full_name?.split(' ')[0]}</h1>
		<p class="mt-1 text-sm text-muted">Resumen operativo de cuentas y roles.</p>
	</div>

	{#if error}
		<p class="mb-6 rounded-xl border border-red-400/20 bg-red-500/10 px-4 py-3 text-sm text-red-200">{error}</p>
	{/if}

	<div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
		<div class="rounded-2xl border border-white/10 bg-navy-900/70 p-5">
			<p class="text-xs uppercase tracking-wider text-muted">Usuarios</p>
			<p class="mt-3 text-3xl font-extrabold">{stats.total}</p>
		</div>
		<div class="rounded-2xl border border-white/10 bg-navy-900/70 p-5">
			<p class="text-xs uppercase tracking-wider text-muted">Activos</p>
			<p class="mt-3 text-3xl font-extrabold text-cyan-300">{stats.active}</p>
		</div>
		<div class="rounded-2xl border border-white/10 bg-navy-900/70 p-5">
			<p class="text-xs uppercase tracking-wider text-muted">Administradores</p>
			<p class="mt-3 text-3xl font-extrabold text-blue-300">{stats.admins}</p>
		</div>
		<div class="rounded-2xl border border-white/10 bg-navy-900/70 p-5">
			<p class="text-xs uppercase tracking-wider text-muted">Operadores</p>
			<p class="mt-3 text-3xl font-extrabold">{stats.operators}</p>
		</div>
	</div>

	<div class="mt-8 rounded-2xl border border-white/10 bg-navy-900/60 p-5">
		<div class="mb-4 flex items-center justify-between">
			<h2 class="font-semibold">Tu cuenta</h2>
			<a class="text-sm text-accent-soft hover:underline" href="/app/usuarios">Ver usuarios</a>
		</div>
		<dl class="grid gap-4 text-sm sm:grid-cols-3">
			<div>
				<dt class="text-muted">Rol</dt>
				<dd class="mt-1 font-medium">{roleLabel(session.user?.role ?? '')}</dd>
			</div>
			<div>
				<dt class="text-muted">Correo</dt>
				<dd class="mt-1 font-medium">{session.user?.email}</dd>
			</div>
			<div>
				<dt class="text-muted">Estado</dt>
				<dd class="mt-1 font-medium">{session.user?.is_active ? 'Activa' : 'Inactiva'}</dd>
			</div>
		</dl>
	</div>
</section>
