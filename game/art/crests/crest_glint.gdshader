shader_type canvas_item;
render_mode unshaded;

// 数据贴图使用线性取样；不添加 source_color，不把法线当作颜色做 gamma 变换。
uniform sampler2D crest_normal : hint_normal, filter_nearest, repeat_disable;
uniform sampler2D highlight_mask : filter_nearest, repeat_disable;
// 周期，单位秒；自动扫光时每个周期从左向右通过一次。
uniform float period_seconds : hint_range(0.5, 8.0) = 3.0;
// -1 自动播放，0..1 手动定位扫光进度，便于动画或测试控制。
uniform float sweep_phase : hint_range(-1.0, 1.0) = -1.0;
// 光带半宽，以纹章宽度为 1；强度是附加高光的混合比例。
uniform float band_half_width : hint_range(0.02, 0.4) = 0.065;
uniform float highlight_strength : hint_range(0.0, 1.0) = 0.85;
uniform vec4 highlight_color : source_color = vec4(1.0, 0.98, 0.88, 1.0);

// 悬停由 CrestHoverView 传入。默认关闭，原有静态／扫光使用方式保持有效。
uniform float hovering = 0.0;
uniform vec2 mouse_screen_pos = vec2(0.0);
uniform vec2 viewport_size = vec2(960.0, 560.0);
uniform float screen_scale = 258.46;
uniform bool shadow_pass = false;
// 局部倾斜把投影中心放在纹章上；浮起位移由展示组件单独控制。
uniform bool local_tilt = false;
uniform vec2 tilt_center_screen = vec2(0.0);
varying vec2 projected_uv;
varying float reciprocal_w;
varying vec4 vertex_tint;

void vertex() {
	vertex_tint = COLOR;
	float w = 1.0;
	if (hovering > 0.0 && !shadow_pass) {
		mat4 to_screen = CANVAS_MATRIX * MODEL_MATRIX;
		vec2 screen_vertex = (to_screen * vec4(VERTEX, 0.0, 1.0)).xy;
		float mid_dist = length(screen_vertex - 0.5 * viewport_size) / length(viewport_size);
		vec2 mouse_offset = (screen_vertex - mouse_screen_pos) / max(screen_scale, 1.0);
		// Balatro dissolve.fs 的齐次 w 偏移；在 CanvasItem 中显式执行透视除法。
		float depth = 0.2 * (-0.03 - 0.3 * max(0.0, 0.3 - mid_dist))
			* hovering * dot(mouse_offset, mouse_offset) / max(2.0 - mid_dist, 0.1);
		if (local_tilt) {
			// 原式 -a*|p-m|² 的方向项为 +2a*dot(p,m)。去掉统一放大的项，
			// 以固定中心投影：指针一侧 w>1 压下，对侧 w<1 翘起。
			// 系数在中心计算，避免屏幕位置让同一平面四角产生不同曲率。
			float center_dist = length(tilt_center_screen - 0.5 * viewport_size) / length(viewport_size);
			float a = 0.2 * (0.03 + 0.3 * max(0.0, 0.3 - center_dist))
				* hovering / max(2.0 - center_dist, 0.1);
			vec2 p = (screen_vertex - tilt_center_screen) / max(screen_scale, 1.0);
			vec2 m = (mouse_screen_pos - tilt_center_screen) / max(screen_scale, 1.0);
			depth = 2.0 * a * dot(p, m);
		}
		w = max(1.0 + depth, 0.5);
		vec2 origin = local_tilt ? tilt_center_screen : 0.5 * viewport_size;
		vec2 projected = origin + (screen_vertex - origin) / w;
		VERTEX = (inverse(to_screen) * vec4(projected, 0.0, 1.0)).xy;
	}
	// CanvasItem 没有可写的 clip.w；显式校正 UV，避免四边形的对角线扭折。
	reciprocal_w = 1.0 / w;
	projected_uv = UV / w;
}

void fragment() {
	vec2 uv = projected_uv / reciprocal_w;
	vec4 base = texture(TEXTURE, uv) * vertex_tint;
	vec2 texel_uv = (floor(uv / TEXTURE_PIXEL_SIZE) + 0.5) * TEXTURE_PIXEL_SIZE;
	vec3 normal = normalize(texture(crest_normal, texel_uv).rgb * 2.0 - 1.0);
	float reflectivity = texture(highlight_mask, texel_uv).r;
	float phase = sweep_phase < 0.0 ? fract(TIME / max(period_seconds, 0.01)) : sweep_phase;
	float scan_position = mix(-0.95, 0.95, phase);
	float location = dot(texel_uv - vec2(0.5), normalize(vec2(1.0, 0.65)));
	// 法线只改变光带在各切面上的位置和强弱，扫光本身始终清晰可见。
	location += normal.x * 0.035 + normal.y * 0.02;
	float band = 1.0 - smoothstep(band_half_width * 0.35, band_half_width, abs(location - scan_position));
	float thin_band = 1.0 - smoothstep(band_half_width * 0.12, band_half_width * 0.38, abs(location - scan_position + 0.12));
	band = max(band, thin_band * 0.65);
	// OpenGL 法线 +Y 朝上；虚拟光源也使用相同坐标约定。
	vec3 light_direction = normalize(vec3((phase - 0.5) * 2.8, 0.45, 0.8));
	vec3 halfway = normalize(light_direction + vec3(0.0, 0.0, 1.0));
	float reflection = pow(max(dot(normal, halfway), 0.0), 6.0);
	float levels = floor(clamp(band, 0.0, 1.0) * 3.0 + 0.5) / 3.0;
	float material_reflection = pow(clamp(reflectivity, 0.0, 1.0), 0.35);
	float amount = clamp(levels * (0.55 + 0.45 * reflection) * material_reflection * highlight_strength, 0.0, 1.0);
	// 仅叠加高光，不重新计算漫反射，不改变作者手绘阴影和透明轮廓。
	COLOR = vec4(mix(base.rgb, highlight_color.rgb, amount), base.a);
	if (shadow_pass) COLOR = vec4(0.0, 0.0, 0.0, base.a * 0.3);
}
