// @ts-nocheck
import * as THREE from 'three';

function dustTexture() {
	const c = document.createElement('canvas');
	c.width = c.height = 64;
	const g = c.getContext('2d');
	if (!g) return new THREE.Texture();
	const grd = g.createRadialGradient(32, 32, 1, 32, 32, 30);
	grd.addColorStop(0, 'rgba(255,255,255,0.95)');
	grd.addColorStop(0.35, 'rgba(255,255,255,0.35)');
	grd.addColorStop(1, 'rgba(255,255,255,0)');
	g.fillStyle = grd;
	g.beginPath();
	g.arc(32, 32, 30, 0, Math.PI * 2);
	g.fill();
	const tex = new THREE.CanvasTexture(c);
	tex.needsUpdate = true;
	return tex;
}

const LIGHT = { bg: 0xf3efe6, plaster: 0xf7f4ee, dust: 0x6b4a9e };
const DARK = { bg: 0x12081c, plaster: 0x1c102c, dust: 0xd8b4fe };

/**
 * @param {HTMLCanvasElement} canvas
 * @param {() => boolean} isDark
 */
export function createWorld(canvas, isDark) {
	const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true, powerPreference: 'high-performance' });
	renderer.outputColorSpace = THREE.SRGBColorSpace;
	const scene = new THREE.Scene();
	const cam = new THREE.PerspectiveCamera(40, 1, 0.1, 80);
	cam.position.set(0, 1.2, 9);

	scene.add(new THREE.HemisphereLight(0xfffaf3, 0x3b2a55, 1));
	const key = new THREE.DirectionalLight(0xffffff, 1.2);
	key.position.set(4, 8, 6);
	scene.add(key);

	const plaster = new THREE.MeshStandardMaterial({ color: LIGHT.plaster, roughness: 0.9 });
	const wall = (x, ry) => {
		const m = new THREE.Mesh(new THREE.BoxGeometry(2.4, 16, 10), plaster);
		m.position.set(x, 1, -3);
		m.rotation.y = ry;
		return m;
	};
	scene.add(wall(-7.6, 0.42), wall(7.6, -0.42));

	const COUNT = 520;
	const pos = new Float32Array(COUNT * 3);
	const vel = new Float32Array(COUNT * 3);
	for (let i = 0; i < COUNT; i++) {
		pos[i * 3] = (Math.random() - 0.5) * 14;
		pos[i * 3 + 1] = Math.random() * 10 - 1;
		pos[i * 3 + 2] = (Math.random() - 0.5) * 10;
		vel[i * 3] = (Math.random() - 0.5) * 0.012;
		vel[i * 3 + 1] = -0.004 - Math.random() * 0.01;
		vel[i * 3 + 2] = (Math.random() - 0.5) * 0.008;
	}
	const geo = new THREE.BufferGeometry();
	geo.setAttribute('position', new THREE.BufferAttribute(pos, 3));
	const dustMat = new THREE.PointsMaterial({
		map: dustTexture(),
		color: LIGHT.dust,
		size: 0.12,
		transparent: true,
		depthWrite: false,
		opacity: 0.85,
		sizeAttenuation: true,
		blending: THREE.NormalBlending
	});
	scene.add(new THREE.Points(geo, dustMat));

	const flakeGeo = new THREE.BoxGeometry(0.16, 0.22, 0.012);
	const flakeMat = new THREE.MeshStandardMaterial({ color: 0xc4b5fd, roughness: 0.55, metalness: 0.05 });
	const flakes = new THREE.InstancedMesh(flakeGeo, flakeMat, 70);
	const dummy = new THREE.Object3D();
	/** @type {{ x: number, y: number, z: number, rx: number, ry: number, rz: number, vy: number, spin: number }[]} */
	const flakeState = [];
	for (let i = 0; i < 70; i++) {
		const s = {
			x: (Math.random() - 0.5) * 12,
			y: Math.random() * 9,
			z: (Math.random() - 0.5) * 8,
			rx: Math.random() * Math.PI,
			ry: Math.random() * Math.PI,
			rz: Math.random() * Math.PI,
			vy: 0.006 + Math.random() * 0.01,
			spin: 0.008 + Math.random() * 0.02
		};
		flakeState.push(s);
	}
	scene.add(flakes);

	let mx = 0,
		my = 0,
		progress = 0,
		raf = 0;
	const mouse = (e) => {
		mx = (e.clientX / innerWidth) * 2 - 1;
		my = (e.clientY / innerHeight) * 2 - 1;
	};

	const applyTheme = () => {
		const pal = isDark() ? DARK : LIGHT;
		renderer.setClearColor(pal.bg, 1);
		scene.fog = new THREE.Fog(pal.bg, 10, 32);
		plaster.color.setHex(pal.plaster);
		dustMat.color.setHex(pal.dust);
		flakeMat.color.setHex(isDark() ? 0xa78bfa : 0x7c3aed);
	};
	applyTheme();

	const resize = () => {
		const w = Math.max(1, canvas.clientWidth);
		const h = Math.max(1, canvas.clientHeight);
		renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
		renderer.setSize(w, h, false);
		cam.aspect = w / h;
		cam.updateProjectionMatrix();
	};
	const ro = new ResizeObserver(resize);
	ro.observe(canvas);
	addEventListener('pointermove', mouse);
	resize();

	const tick = () => {
		applyTheme();
		const attr = geo.getAttribute('position');
		for (let i = 0; i < COUNT; i++) {
			pos[i * 3] += vel[i * 3] + mx * 0.002;
			pos[i * 3 + 1] += vel[i * 3 + 1];
			pos[i * 3 + 2] += vel[i * 3 + 2];
			if (pos[i * 3 + 1] < -2) pos[i * 3 + 1] = 9;
			if (pos[i * 3] > 8) pos[i * 3] = -8;
			if (pos[i * 3] < -8) pos[i * 3] = 8;
		}
		attr.needsUpdate = true;

		flakeState.forEach((s, i) => {
			s.y -= s.vy;
			s.x += Math.sin(s.y + i) * 0.004;
			s.rx += s.spin;
			s.rz += s.spin * 0.6;
			if (s.y < -2) s.y = 9;
			dummy.position.set(s.x, s.y, s.z);
			dummy.rotation.set(s.rx, s.ry, s.rz);
			dummy.updateMatrix();
			flakes.setMatrixAt(i, dummy.matrix);
		});
		flakes.instanceMatrix.needsUpdate = true;

		cam.position.x = mx * 0.28;
		cam.position.y = 1.2 + my * -0.1 + progress * 0.25;
		cam.lookAt(0, 1, -2);
		renderer.render(scene, cam);
		raf = requestAnimationFrame(tick);
	};
	tick();

	return {
		/** @param {number} v */
		setProgress: (v) => {
			progress = v;
		},
		destroy() {
			cancelAnimationFrame(raf);
			ro.disconnect();
			removeEventListener('pointermove', mouse);
			dustMat.map?.dispose();
			renderer.dispose();
		}
	};
}
