shader_type canvas_item;

// 法线起伏倍率（无单位倍率）：1.0 为原始法线强度，调高可强化岩石棱面、树冠层叠与晶簇切面的受光对比。
uniform float normal_strength : hint_range(0.0, 2.5) = 1.25;
// 法线受光面色阶数（阶）：仅对三维法线朝向做硬朗色阶化，保留平滑径向衰减以消除平面同心光圈。
uniform int light_bands : hint_range(2, 8) = 4;
// 实时像素高光强度（倍率）：冰溪水面与水晶采集器可调至 0.25~0.45，泥土和树干保持 0.03~0.08。
uniform float specular_strength : hint_range(0.0, 1.5) = 0.06;
// 实时高光阈值（余弦阈值）：越接近 1.0 高光像素点越集中硬朗。
uniform float specular_threshold : hint_range(0.5, 0.99) = 0.91;
// 暗部环绕保底比例（倍率）：避免冷林背光面死黑，确保 8x8 棋盘格界与单位轮廓清晰可读。
uniform float wrap_amount : hint_range(0.0, 0.5) = 0.28;

// 连续林地复用普通地贴图中心的冻土纹理。世界单位均为原始像素。
uniform bool continuous_ground = false;
uniform bool trim_lower_skirt = false;
uniform vec2 tile_center = vec2(0.0);
varying vec2 ground_position;

void vertex() {
	ground_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	if (continuous_ground) {
		vec2 patch = mod(floor(ground_position), vec2(16.0, 8.0));
		COLOR = texture(TEXTURE, (vec2(16.5, 10.5) + patch) / vec2(48.0, 32.0));
		NORMAL_MAP = vec3(0.5, 0.5, 1.0);
	} else if (trim_lower_skirt) {
		vec2 offset = ground_position - tile_center;
		if (offset.y > 0.0 && abs(offset.x) / 24.0 + offset.y / 12.0 > 1.0) {
			discard;
		}
	}
}

void light() {
	vec3 n = NORMAL;
	n.xy *= normal_strength;
	n = normalize(n);

	float raw_ndotl = dot(n, LIGHT_DIRECTION);
	float wrapped = clamp((raw_ndotl + wrap_amount) / (1.0 + wrap_amount), 0.0, 1.0);

	// 仅在法线有明显倾斜（立体侧面/树冠/岩石/晶簇）时做阶梯量化，水平地面过渡自然不产生同心圆靶环
	float tilt = clamp(length(NORMAL.xy) * 2.2, 0.0, 1.0);
	float bands = float(max(light_bands, 2));
	float stepped_ndotl = floor(wrapped * bands + 0.25) / bands;
	float final_ndotl = mix(wrapped, stepped_ndotl, tilt);

	float atten = LIGHT_COLOR.a;
	vec3 half_vec = normalize(LIGHT_DIRECTION + vec3(0.0, 0.0, 1.0));
	float spec_dot = max(0.0, dot(n, half_vec));
	float spec_step = step(specular_threshold, spec_dot) * step(0.25, atten) * specular_strength * tilt;

	vec3 lit_rgb = (COLOR.rgb * final_ndotl + vec3(spec_step)) * LIGHT_COLOR.rgb * LIGHT_ENERGY;
	LIGHT = vec4(lit_rgb, atten);
}
