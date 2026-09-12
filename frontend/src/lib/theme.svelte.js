import { browser } from '$app/environment';

function read() {
	if (!browser) return 'light';
	const saved = localStorage.getItem('hmdp_theme');
	if (saved === 'dark' || saved === 'light') return saved;
	return matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

class Theme {
	mode = $state(read());

	get dark() {
		return this.mode === 'dark';
	}

	apply() {
		if (!browser) return;
		document.documentElement.classList.toggle('dark', this.dark);
		localStorage.setItem('hmdp_theme', this.mode);
	}

	toggle() {
		this.mode = this.dark ? 'light' : 'dark';
		this.apply();
	}
}

export const theme = new Theme();
