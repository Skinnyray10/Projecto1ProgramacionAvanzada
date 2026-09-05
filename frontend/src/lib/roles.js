/** @type {Record<string, { label: string, class: string }>} */
export const ROLE_STYLES = {
	super_admin: {
		label: 'Super admin',
		class: 'bg-cyan-400/15 text-cyan-300 ring-cyan-400/30'
	},
	admin: {
		label: 'Admin',
		class: 'bg-blue-500/15 text-blue-300 ring-blue-400/30'
	},
	operator: {
		label: 'Operador',
		class: 'bg-slate-500/15 text-slate-300 ring-slate-400/20'
	}
};

/** @param {string} role */
export function roleLabel(role) {
	return ROLE_STYLES[role]?.label ?? role;
}

/** @param {string} iso */
export function formatDate(iso) {
	if (!iso) return '—';
	return new Intl.DateTimeFormat('es-MX', {
		dateStyle: 'medium',
		timeStyle: 'short'
	}).format(new Date(iso));
}
