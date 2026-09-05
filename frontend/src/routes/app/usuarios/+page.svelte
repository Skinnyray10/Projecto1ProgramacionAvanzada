<script>
	import { onMount } from 'svelte';
	import { session } from '$lib/session.svelte.js';
	import { api } from '$lib/api.js';
	import { formatDate, ROLE_STYLES, roleLabel } from '$lib/roles.js';

	/** @typedef {{ id: string, email: string, full_name: string, role: string, is_active: boolean, last_login_at: string | null, created_at: string }} User */

	let users = $state(/** @type {User[]} */ ([]));
	let loading = $state(true);
	let error = $state('');
	let query = $state('');
	let modalOpen = $state(false);
	let saving = $state(false);
	/** @type {User | null} */
	let editing = $state(null);

	let form = $state({
		fullName: '',
		email: '',
		password: '',
		role: 'operator',
		isActive: true
	});

	const filtered = $derived(
		users.filter((user) => {
			const q = query.trim().toLowerCase();
			if (!q) return true;
			return (
				user.full_name.toLowerCase().includes(q) ||
				user.email.toLowerCase().includes(q) ||
				user.role.toLowerCase().includes(q)
			);
		})
	);

	async function loadUsers() {
		loading = true;
		error = '';
		try {
			const data = await api('/api/users', { token: session.token });
			users = data.users;
		} catch (err) {
			error = err instanceof Error ? err.message : 'No se pudieron cargar los usuarios';
		} finally {
			loading = false;
		}
	}

	onMount(loadUsers);

	function openCreate() {
		editing = null;
		form = { fullName: '', email: '', password: '', role: 'operator', isActive: true };
		modalOpen = true;
	}

	/** @param {User} user */
	function openEdit(user) {
		editing = user;
		form = {
			fullName: user.full_name,
			email: user.email,
			password: '',
			role: user.role,
			isActive: user.is_active
		};
		modalOpen = true;
	}

	async function saveUser(/** @type {SubmitEvent} */ event) {
		event.preventDefault();
		saving = true;
		error = '';
		try {
			if (editing) {
				/** @type {Record<string, unknown>} */
				const body = {
					fullName: form.fullName,
					email: form.email,
					role: form.role,
					isActive: form.isActive
				};
				if (form.password) body.password = form.password;
				await api(`/api/users/${editing.id}`, {
					method: 'PATCH',
					token: session.token,
					body
				});
			} else {
				await api('/api/users', {
					method: 'POST',
					token: session.token,
					body: {
						fullName: form.fullName,
						email: form.email,
						password: form.password,
						role: form.role
					}
				});
			}
			modalOpen = false;
			await loadUsers();
		} catch (err) {
			error = err instanceof Error ? err.message : 'No se pudo guardar el usuario';
		} finally {
			saving = false;
		}
	}

	/** @param {User} user */
	async function removeUser(user) {
		if (!confirm(`¿Eliminar a ${user.full_name}?`)) return;
		error = '';
		try {
			await api(`/api/users/${user.id}`, { method: 'DELETE', token: session.token });
			await loadUsers();
		} catch (err) {
			error = err instanceof Error ? err.message : 'No se pudo eliminar';
		}
	}
</script>

<section>
	<div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
		<div>
			<p class="text-xs font-semibold tracking-[0.24em] text-glow/80">DIRECTORIO</p>
			<h1 class="mt-2 text-3xl font-extrabold">Usuarios</h1>
			<p class="mt-1 text-sm text-muted">Cuentas del sistema con acceso al panel.</p>
		</div>
		{#if session.canManageUsers}
			<button
				class="rounded-xl bg-linear-to-r from-blue-600 to-cyan-500 px-4 py-2.5 text-sm font-semibold shadow-lg shadow-blue-900/40 hover:brightness-110"
				onclick={openCreate}
			>
				Nuevo usuario
			</button>
		{/if}
	</div>

	<div class="mb-5">
		<input
			class="w-full max-w-md rounded-xl border border-white/10 bg-navy-900/80 px-4 py-2.5 text-sm outline-none focus:border-accent-soft/50"
			placeholder="Buscar por nombre, correo o rol"
			bind:value={query}
		/>
	</div>

	{#if error}
		<p class="mb-4 rounded-xl border border-red-400/20 bg-red-500/10 px-4 py-3 text-sm text-red-200">{error}</p>
	{/if}

	<div class="overflow-hidden rounded-2xl border border-white/10 bg-navy-900/60">
		<div class="overflow-x-auto">
			<table class="min-w-full text-left text-sm">
				<thead class="bg-white/5 text-xs uppercase tracking-wider text-muted">
					<tr>
						<th class="px-4 py-3 font-medium">Nombre</th>
						<th class="px-4 py-3 font-medium">Rol</th>
						<th class="px-4 py-3 font-medium">Estado</th>
						<th class="px-4 py-3 font-medium">Último acceso</th>
						<th class="px-4 py-3 font-medium"></th>
					</tr>
				</thead>
				<tbody>
					{#if loading}
						<tr>
							<td class="px-4 py-8 text-muted" colspan="5">Cargando…</td>
						</tr>
					{:else if filtered.length === 0}
						<tr>
							<td class="px-4 py-8 text-muted" colspan="5">No hay usuarios para mostrar.</td>
						</tr>
					{:else}
						{#each filtered as user}
							<tr class="border-t border-white/5">
								<td class="px-4 py-3">
									<p class="font-medium">{user.full_name}</p>
									<p class="text-xs text-muted">{user.email}</p>
								</td>
								<td class="px-4 py-3">
									<span
										class="inline-flex rounded-full px-2.5 py-1 text-xs font-semibold ring-1 {ROLE_STYLES[user.role]
											?.class ?? ''}"
									>
										{roleLabel(user.role)}
									</span>
								</td>
								<td class="px-4 py-3">
									<span class={user.is_active ? 'text-cyan-300' : 'text-red-300'}>
										{user.is_active ? 'Activo' : 'Inactivo'}
									</span>
								</td>
								<td class="px-4 py-3 text-muted">{formatDate(user.last_login_at ?? '')}</td>
								<td class="px-4 py-3 text-right">
									{#if session.canManageUsers}
										<button class="mr-2 text-xs font-semibold text-accent-soft hover:underline" onclick={() => openEdit(user)}>
											Editar
										</button>
									{/if}
									{#if session.canDeleteUsers && user.id !== session.user?.id}
										<button class="text-xs font-semibold text-red-300 hover:underline" onclick={() => removeUser(user)}>
											Eliminar
										</button>
									{/if}
								</td>
							</tr>
						{/each}
					{/if}
				</tbody>
			</table>
		</div>
	</div>
</section>

{#if modalOpen}
	<div class="fixed inset-0 z-50 grid place-items-center bg-navy-950/70 p-4 backdrop-blur-sm">
		<form
			class="w-full max-w-lg rounded-3xl border border-cyan-400/15 bg-navy-900 p-6 shadow-2xl"
			onsubmit={saveUser}
		>
			<h2 class="text-xl font-bold">{editing ? 'Editar usuario' : 'Nuevo usuario'}</h2>
			<p class="mt-1 mb-5 text-sm text-muted">
				{editing ? 'La contraseña es opcional si no quieres cambiarla.' : 'La contraseña se cifra con bcrypt antes de guardarse.'}
			</p>

			<div class="grid gap-4 sm:grid-cols-2">
				<label class="text-sm font-medium sm:col-span-2">
					Nombre completo
					<input class="mt-2 w-full rounded-xl border border-white/10 bg-navy-950 px-3 py-2.5 outline-none focus:border-accent-soft/50" bind:value={form.fullName} required />
				</label>
				<label class="text-sm font-medium sm:col-span-2">
					Correo
					<input class="mt-2 w-full rounded-xl border border-white/10 bg-navy-950 px-3 py-2.5 outline-none focus:border-accent-soft/50" type="email" bind:value={form.email} required />
				</label>
				<label class="text-sm font-medium">
					Contraseña
					<input class="mt-2 w-full rounded-xl border border-white/10 bg-navy-950 px-3 py-2.5 outline-none focus:border-accent-soft/50" type="password" bind:value={form.password} minlength={editing ? 0 : 8} required={!editing} />
				</label>
				<label class="text-sm font-medium">
					Rol
					<select class="mt-2 w-full rounded-xl border border-white/10 bg-navy-950 px-3 py-2.5 outline-none focus:border-accent-soft/50" bind:value={form.role}>
						<option value="operator">Operador</option>
						<option value="admin">Admin</option>
						{#if session.user?.role === 'super_admin'}
							<option value="super_admin">Super admin</option>
						{/if}
					</select>
				</label>
				{#if editing}
					<label class="flex items-center gap-2 text-sm font-medium sm:col-span-2">
						<input type="checkbox" bind:checked={form.isActive} />
						Cuenta activa
					</label>
				{/if}
			</div>

			<div class="mt-6 flex justify-end gap-2">
				<button class="rounded-xl px-4 py-2 text-sm text-muted hover:text-ice" type="button" onclick={() => (modalOpen = false)}>
					Cancelar
				</button>
				<button class="rounded-xl bg-blue-600 px-4 py-2 text-sm font-semibold hover:bg-blue-500 disabled:opacity-60" disabled={saving}>
					{saving ? 'Guardando…' : 'Guardar'}
				</button>
			</div>
		</form>
	</div>
{/if}
