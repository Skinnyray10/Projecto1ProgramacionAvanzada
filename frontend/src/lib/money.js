const KEY = 'hmdp_movimientos';

/** @typedef {{ id: string, type: 'ingreso' | 'gasto', amount: number, category: string, note: string, date: string }} Move */

/** @returns {Move[]} */
export function loadMoves() {
	try {
		return JSON.parse(localStorage.getItem(KEY) || '[]');
	} catch {
		return [];
	}
}

/** @param {Move[]} items */
export function saveMoves(items) {
	localStorage.setItem(KEY, JSON.stringify(items));
}

/** @param {number} n */
export function money(n) {
	return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(n);
}
