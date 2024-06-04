shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void light() {
	vec3 c = texture(screen_texture, SCREEN_UV, 1.0).rgb / 1.0;
	SHADOW_MODULATE = vec4(c, 1.0);
	LIGHT = texture(screen_texture, SCREEN_UV, 0.0);
	// LIGHT = vec4(255,255,255,0.1);
}
