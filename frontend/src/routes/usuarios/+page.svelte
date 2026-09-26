<script>
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { api } from '$lib/api.js';
	import { session } from '$lib/session.svelte.js';

	/** @type {any[]} */
	let users = $state([]);
	let error = $state('');
	let saving = $state(false);
	let form = $state({
		email: '',
		password: '',
		fullName: '',
		role: 'operator'
	});

	async function load() {
		const data = await api('/api/users', { token: session.token });
		users = data.users;
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
			error = err instanceof Error ? err.message : 'Error al cargar usuarios';
		}
	});

	async function add(/** @type {SubmitEvent} */ e) {
		e.preventDefault();
		if (!session.canManageUsers) {
			error = 'No tienes permiso para crear usuarios';
			return;
		}
		saving = true;
		error = '';
		try {
			await api('/api/users', {
				method: 'POST',
				token: session.token,
				body: {
					email: form.email,
					password: form.password,
					fullName: form.fullName,
					role: form.role
				}
			});
			form = { email: '', password: '', fullName: '', role: 'operator' };
			await load();
		} catch (err) {
			error = err instanceof Error ? err.message : 'No se pudo guardar';
		} finally {
			saving = false;
		}
	}
</script>

<section class="bg-az-black px-4 py-8 text-white">
	<div class="mx-auto max-w-5xl">
		<p class="text-xs font-semibold uppercase tracking-[0.2em] text-az-orange">Equipo</p>
		<h1 class="mt-2 font-display text-4xl font-bold uppercase">Usuarios</h1>
		<div class="mt-3 h-1.5 w-20 bg-az-orange"></div>
	</div>
</section>

<main class="mx-auto max-w-5xl px-4 py-8">
	{#if error}
		<p class="mb-4 border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>
	{/if}

	{#if session.canManageUsers}
		<form class="grid gap-3 border border-zinc-200 bg-white p-5 dark:border-zinc-800 dark:bg-zinc-900 sm:grid-cols-2" onsubmit={add}>
			<label class="text-xs font-bold uppercase">Nombre<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" bind:value={form.fullName} required /></label>
			<label class="text-xs font-bold uppercase">Correo<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" type="email" bind:value={form.email} required /></label>
			<label class="text-xs font-bold uppercase">Contraseña<input class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" type="password" minlength="8" bind:value={form.password} required /></label>
			<label class="text-xs font-bold uppercase">Rol
				<select class="mt-1 w-full border border-zinc-300 bg-az-gray px-3 py-2 dark:border-zinc-700 dark:bg-zinc-950" bind:value={form.role}>
					<option value="operator">Operador</option>
					<option value="admin">Admin</option>
					{#if session.user?.role === 'super_admin'}
						<option value="super_admin">Super admin</option>
					{/if}
				</select>
			</label>
			<button class="bg-az-red px-4 py-3 text-sm font-bold uppercase text-white sm:col-span-2" disabled={saving}>
				{saving ? 'Guardando…' : 'Crear usuario'}
			</button>
		</form>
	{/if}

	<ul class="mt-6 space-y-2">
		{#each users as user}
			<li class="border border-zinc-200 bg-white px-4 py-3 text-sm dark:border-zinc-800 dark:bg-zinc-900">
				<p class="font-bold uppercase">{user.full_name}</p>
				<p class="text-xs text-zinc-500">{user.email} · {user.role} · {user.is_active ? 'activo' : 'inactivo'}</p>
			</li>
		{:else}
			<li class="text-sm text-zinc-500">Aún no hay usuarios.</li>
		{/each}
	</ul>
</main>
