shader_type canvas_item;
render_mode unshaded;

// 距离使用等轴格坐标，雾始终锚定世界，保护全部可操作格。
uniform float fog_start_cells = 0.15;
uniform float fog_width_cells = 3.0;
uniform float flow_speed = 1.2;
varying vec2 world_position;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), f.x), f.y);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 p = floor(world_position);
	vec2 relative = (p - vec2(320.0, 80.0)) / vec2(24.0, 12.0);
	vec2 cell = vec2(relative.x + relative.y, relative.y - relative.x) * 0.5;
	vec2 outside = max(abs(cell - vec2(3.5)) - vec2(4.0), vec2(0.0));
	float distance_out = length(outside);
	float drift = noise(p / 43.0 + vec2(TIME * flow_speed / 43.0, 0.0));
	float detail = noise(p / 19.0 - vec2(0.0, TIME * flow_speed / 75.0));
	float edge = distance_out + (drift - 0.5) * 0.55;
	float amount = smoothstep(fog_start_cells, fog_start_cells + fog_width_cells, edge);
	amount *= smoothstep(0.0, 0.25, distance_out);
	vec3 mist = mix(vec3(0.065, 0.105, 0.125), vec3(0.12, 0.19, 0.21), drift * 0.65 + detail * 0.35);
	COLOR = vec4(floor(mist * 64.0 + 0.5) / 64.0, amount);
}
