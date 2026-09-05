import { browser } from '$app/environment';
import { api } from './api.js';

const TOKEN_KEY = 'hmdp_token';

function readToken() {
	if (!browser) return null;
	return localStorage.getItem(TOKEN_KEY);
}

class Session {
	token = $state(readToken());
	/** @type {{ id: string, email: string, full_name: string, role: string, is_active: boolean } | null} */
	user = $state(null);
	loading = $state(true);

	get canManageUsers() {
		return this.user?.role === 'admin' || this.user?.role === 'super_admin';
	}

	get canDeleteUsers() {
		return this.user?.role === 'super_admin';
	}

	async hydrate() {
		if (!this.token) {
			this.user = null;
			this.loading = false;
			return false;
		}

		try {
			const data = await api('/api/auth/me', { token: this.token });
			this.user = data.user;
			return true;
		} catch {
			this.logout();
			return false;
		} finally {
			this.loading = false;
		}
	}

	/**
	 * @param {string} email
	 * @param {string} password
	 */
	async login(email, password) {
		const data = await api('/api/auth/login', {
			method: 'POST',
			body: { email, password }
		});
		this.token = data.token;
		this.user = data.user;
		if (browser) localStorage.setItem(TOKEN_KEY, data.token);
		this.loading = false;
		return data;
	}

	logout() {
		this.token = null;
		this.user = null;
		this.loading = false;
		if (browser) localStorage.removeItem(TOKEN_KEY);
	}
}

export const session = new Session();
