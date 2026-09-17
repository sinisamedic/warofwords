shader_type canvas_item;

uniform float dissolve : hint_range(0.0, 1.0) = 0.0;
uniform vec4 region_uv = vec4(0.0, 0.0, 1.0, 1.0);
varying vec4 tint;

void vertex() { tint = COLOR; }

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	vec2 local = (UV - region_uv.xy) / region_uv.zw;
	vec2 cell = floor(local * vec2(25.0, 32.0));
	float noise = fract(sin(dot(cell, vec2(127.1, 311.7))) * 43758.5453);
	float field = length((local - vec2(0.50, 0.47)) * vec2(0.8, 1.0)) + noise * 0.23;
	float threshold = dissolve * 1.15 - 0.08;
	float remain = smoothstep(threshold, threshold + 0.035, field);
	float edge = (1.0 - smoothstep(0.015, 0.08, abs(field - threshold))) * step(0.001, dissolve);
	COLOR = vec4(pixel.rgb + vec3(1.9, 0.9, 0.2) * edge, pixel.a * remain) * tint;
}
