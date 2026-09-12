import * as THREE from 'three';

/** @param {HTMLCanvasElement} canvas */
export function createWorld(canvas) {
	const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
	renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
	renderer.setClearColor(0xf3efe6, 1);
	const scene = new THREE.Scene();
	scene.fog = new THREE.Fog(0xf3efe6, 12, 36);
	const cam = new THREE.PerspectiveCamera(38, 1, 0.1, 80);
	cam.position.set(0, 1.4, 10);

	scene.add(new THREE.HemisphereLight(0xfffaf3, 0xc9b8a6, 1.1));
	const key = new THREE.DirectionalLight(0xffffff, 1.4);
	key.position.set(4, 8, 6);
	const fill = new THREE.DirectionalLight(0xb794f6, 0.35);
	fill.position.set(-6, 2, 2);
	scene.add(key, fill);

	const plaster = new THREE.MeshStandardMaterial({ color: 0xf7f4ee, roughness: 0.88 });
	const left = new THREE.Mesh(new THREE.BoxGeometry(3.2, 14, 8), plaster);
	left.position.set(-8.2, 1, -2);
	left.rotation.y = 0.35;
	const right = left.clone();
	right.position.set(8.2, 1, -2);
	right.rotation.y = -0.35;
	scene.add(left, right);

	const bits = new THREE.Group();
	const mats = [0x2e1064, 0x7c3aed, 0xe9d5ff, 0xffffff].map(
		(c) => new THREE.MeshStandardMaterial({ color: c, roughness: 0.4 })
	);
	for (let i = 0; i < 42; i++) {
		const m = new THREE.Mesh(new THREE.PlaneGeometry(0.18 + Math.random() * 0.35, 0.12), mats[i % 4]);
		const side = Math.random() < 0.5 ? -1 : 1;
		m.position.set(side * (3.8 + Math.random() * 5), Math.random() * 8 - 1, (Math.random() - 0.5) * 8);
		m.rotation.set(Math.random(), Math.random(), Math.random());
		bits.add(m);
	}
	scene.add(bits);

	let mx = 0,
		my = 0,
		progress = 0,
		raf = 0;
	const mouse = (e) => {
		mx = (e.clientX / innerWidth) * 2 - 1;
		my = (e.clientY / innerHeight) * 2 - 1;
	};
	const resize = () => {
		renderer.setSize(innerWidth, innerHeight, false);
		cam.aspect = innerWidth / innerHeight;
		cam.updateProjectionMatrix();
	};
	addEventListener('pointermove', mouse);
	addEventListener('resize', resize);
	resize();

	const tick = () => {
		const t = performance.now() * 0.0004;
		bits.children.forEach((c, i) => {
			c.position.y += Math.sin(t + i) * 0.002;
			c.rotation.z += 0.003;
		});
		cam.position.x = mx * 0.4;
		cam.position.y = 1.4 + my * -0.15 + progress * 0.4;
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
			removeEventListener('pointermove', mouse);
			removeEventListener('resize', resize);
			renderer.dispose();
		}
	};
}
