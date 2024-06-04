shader_type canvas_item;

uniform sampler2D mask_texture;

void fragment() {
	vec4 mask_value = texture(mask_texture, UV);
	vec4 color = texture(TEXTURE, UV);
	/* color.r = UV.x;
	color.g = UV.y;
	color.b = 0.0; */
	if (mask_value.r > 0.5) {
		COLOR = vec4(0.0);
	}
	else {
		COLOR = color;
	}
}
