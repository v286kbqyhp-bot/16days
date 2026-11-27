shader_type canvas_item;
render_mode unshaded;

// 每通道色彩量化阶数（阶）：收敛多光源（晶光+篝火+月光）叠加产生的平滑过渡，保持手绘像素色板质感。
uniform int color_levels : hint_range(16, 256) = 64;
// 寒林四周暗角聚光倍率（0~0.45）：压暗外围密林边缘，将视觉焦点聚拢在中央 8x8 战棋沙盘。
uniform float vignette_strength : hint_range(0.0, 0.45) = 0.15;

void fragment() {
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
	vec2 snapped_uv = (floor(UV * tex_size) + vec2(0.5)) / tex_size;
	vec4 src = texture(TEXTURE, clamp(snapped_uv, vec2(0.001), vec2(0.999)));

	vec2 focus_delta = (snapped_uv - vec2(0.50, 0.48)) * vec2(1.12, 1.18);
	float dist2 = dot(focus_delta, focus_delta);
	float vig = 1.0 - clamp(dist2 * vignette_strength * 1.55, 0.0, vignette_strength);

	float lv = float(max(color_levels, 16));
	vec3 quant_rgb = floor(src.rgb * vig * lv + 0.5) / lv;
	COLOR = vec4(quant_rgb, src.a);
}
