<script>
	const cards = [
		{
			tag: 'Inventario',
			title: 'Piezas y refacciones',
			copy: 'SKU, marca, stock y precio. Controla lo que tienes en anaquel como en mostrador.',
			href: '/piezas',
			cta: 'Ver piezas'
		},
		{
			tag: 'Taller',
			title: 'Autos registrados',
			copy: 'Marca, modelo, año y placas. Cada unidad del cliente, lista para cotizar.',
			href: '/autos',
			cta: 'Ver autos'
		},
		{
			tag: 'Equipo',
			title: 'Usuarios del sistema',
			copy: 'Admins y operadores con acceso seguro para operar la refaccionaria.',
			href: '/usuarios',
			cta: 'Ver usuarios'
		},
		{
			tag: 'Acceso',
			title: 'Ingresar al panel',
			copy: 'Sesiones con JWT y contraseñas cifradas. Entra y empieza a registrar.',
			href: '/login',
			cta: 'Ingresar'
		}
	];
</script>

<section class="bg-az-black px-4 py-14 text-white md:py-20">
	<div class="mx-auto max-w-6xl">
		<p class="text-xs font-semibold uppercase tracking-[0.2em] text-az-orange">Refaccionaria digital</p>
		<h1 class="mt-3 max-w-3xl font-display text-4xl font-bold uppercase leading-none md:text-6xl">
			HMDP Zone · Piezas, autos y usuarios
		</h1>
		<div class="mt-4 h-1.5 w-24 bg-az-orange"></div>
		<p class="mt-6 max-w-2xl text-base text-zinc-300 md:text-lg">
			Sistema web para refaccionarias: inventario de refacciones, registro de vehículos y control del personal.
			Inspirado en la claridad de mostrador de una tienda de autopartes.
		</p>
		<div class="mt-8 flex flex-wrap gap-3">
			<a href="/piezas" class="rounded bg-az-red px-5 py-3 text-sm font-bold uppercase tracking-wide text-white hover:bg-red-700"
				>Ir al inventario</a
			>
			<a
				href="/login"
				class="rounded border border-white/40 px-5 py-3 text-sm font-bold uppercase tracking-wide text-white hover:border-az-orange hover:text-az-orange"
				>Ingresar</a
			>
		</div>
	</div>
</section>

<section class="bg-white px-4 py-12 dark:bg-zinc-950">
	<div class="mx-auto grid max-w-6xl gap-4 md:grid-cols-2">
		{#each cards as card}
			<a
				href={card.href}
				class="group border border-zinc-200 bg-az-gray p-6 transition hover:border-az-orange dark:border-zinc-800 dark:bg-zinc-900"
			>
				<p class="text-xs font-bold uppercase tracking-[0.18em] text-az-red">{card.tag}</p>
				<h2 class="mt-2 font-display text-2xl font-bold uppercase">{card.title}</h2>
				<div class="mt-2 h-1 w-12 bg-az-orange"></div>
				<p class="mt-4 text-sm text-zinc-600 dark:text-zinc-400">{card.copy}</p>
				<span class="mt-5 inline-block text-sm font-bold uppercase text-az-red group-hover:underline">{card.cta} →</span>
			</a>
		{/each}
	</div>
</section>

<section class="border-t border-zinc-200 bg-az-gray px-4 py-10 dark:border-zinc-800 dark:bg-zinc-900">
	<div class="mx-auto grid max-w-6xl gap-6 md:grid-cols-3">
		<div>
			<p class="font-display text-xl font-bold uppercase">Información</p>
			<div class="mt-2 h-1 w-10 bg-az-orange"></div>
			<p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">API REST · Supabase · bcrypt · JWT</p>
		</div>
		<div>
			<p class="font-display text-xl font-bold uppercase">Horario demo</p>
			<div class="mt-2 h-1 w-10 bg-az-orange"></div>
			<p class="mt-3 text-sm font-semibold text-green-700 dark:text-green-400">Abierto · Backend en :3000</p>
		</div>
		<div>
			<p class="font-display text-xl font-bold uppercase">Contacto</p>
			<div class="mt-2 h-1 w-10 bg-az-orange"></div>
			<p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
				Ryan Rolando Garcia Galvan<br />
				Jean Sebastian De La Rosa Escobedo
			</p>
		</div>
	</div>
</section>
