shader_type canvas_item;

uniform int px_ratio;
uniform float line_offset;
uniform int line_thickness;
uniform float transparency : hint_range(0.0, 1.0, 0.1);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec2 pixel = UV * 256.0 + vec2(line_offset);
	if (int(pixel.x) % px_ratio < line_thickness || int(pixel.y) % px_ratio < line_thickness) {
		float brightness = (length(color.rgb) / 1.732);
		COLOR.rgb = mix(color.rgb, vec3(1.0-(brightness*brightness)), transparency);
	} else {
		COLOR = color;
	}
}
