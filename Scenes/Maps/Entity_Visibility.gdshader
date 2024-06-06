shader_type canvas_item;

uniform sampler2D mask_texture;

void fragment() {
	vec4 mask_value = texture(mask_texture, UV);
	vec4 color = texture(TEXTURE, UV);
	/* color.r = UV.x;
	color.g = UV.y;
	color.b = 0.0; */
	COLOR.rgb = color.rgb;
	COLOR.a = (1.0 - mask_value.r) * color.a;
}
