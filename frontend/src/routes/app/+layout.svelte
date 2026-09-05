<script>
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import { session } from '$lib/session.svelte.js';

	let { children } = $props();
	let ready = $state(false);

	const links = [
		{ href: '/app', label: 'Panel', match: (/** @type {string} */ path) => path === '/app' },
		{
			href: '/app/usuarios',
			label: 'Usuarios',
			match: (/** @type {string} */ path) => path.startsWith('/app/usuarios')
		}
	];

	onMount(async () => {
		const ok = await session.hydrate();
		if (!ok) {
			await goto('/login', { replaceState: true });
			return;
		}
		ready = true;
	});

	function logout() {
		session.logout();
		goto('/login');
	}
</script>

{#if !ready}
	<main class="grid min-h-screen place-items-center">
		<p class="text-sm tracking-wide text-muted">Verificando sesión…</p>
	</main>
{:else}
	<div class="min-h-screen lg:grid lg:grid-cols-[260px_1fr]">
		<aside class="border-b border-white/10 bg-navy-900/70 px-5 py-6 backdrop-blur-xl lg:border-r lg:border-b-0">
			<div class="mb-8 flex items-center gap-3">
				<div class="grid h-10 w-10 place-items-center rounded-2xl bg-blue-500/20 font-extrabold text-glow ring-1 ring-cyan-400/30">
					H
				</div>
				<div>
					<p class="text-sm font-bold tracking-[0.2em] text-ice">HMDP</p>
					<p class="text-xs text-muted">Administración</p>
				</div>
			</div>

			<nav class="flex gap-2 lg:flex-col">
				{#each links as link}
					<a
						href={link.href}
						class="rounded-xl px-3 py-2 text-sm font-medium transition {link.match(page.url.pathname)
							? 'bg-blue-500/20 text-ice ring-1 ring-cyan-400/20'
							: 'text-muted hover:bg-white/5 hover:text-ice'}"
					>
						{link.label}
					</a>
				{/each}
			</nav>

			<div class="mt-8 hidden rounded-2xl border border-white/10 bg-navy-950/50 p-4 lg:block">
				<p class="truncate text-sm font-semibold">{session.user?.full_name}</p>
				<p class="truncate text-xs text-muted">{session.user?.email}</p>
				<button
					class="mt-4 w-full rounded-lg border border-white/10 px-3 py-2 text-xs font-semibold text-muted hover:bg-white/5 hover:text-ice"
					onclick={logout}
				>
					Cerrar sesión
				</button>
			</div>
		</aside>

		<div class="min-h-screen">
			<header class="flex items-center justify-between border-b border-white/10 px-5 py-4 lg:px-8">
				<p class="text-sm text-muted">Entorno de administración</p>
				<button class="text-xs font-semibold text-muted hover:text-ice lg:hidden" onclick={logout}>
					Salir
				</button>
			</header>
			<div class="px-5 py-6 lg:px-8">
				{@render children()}
			</div>
		</div>
	</div>
{/if}
