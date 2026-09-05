<script>
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { session } from '$lib/session.svelte.js';

	onMount(async () => {
		const ok = await session.hydrate();
		goto(ok ? '/app' : '/login', { replaceState: true });
	});
</script>

<main class="grid min-h-screen place-items-center">
	<p class="text-sm tracking-wide text-muted">Cargando panel…</p>
</main>
