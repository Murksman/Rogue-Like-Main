shader_type canvas_item;
uniform vec4 outline_color : source_color;
uniform float outline_width;

void fragment() {
	vec2 cp = UV - vec2(0.5);
	float dist = cp.x * cp.x * cp.x * cp.x + cp.y * cp.y * cp.y * cp.y;
	if (dist + outline_width > 0.0625) {
		if (dist < 0.0625) {
			COLOR = outline_color;
		} else {
			COLOR.a = 0.0;
		}
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}
