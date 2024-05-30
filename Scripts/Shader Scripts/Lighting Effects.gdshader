shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void light() {
	SHADOW_MODULATE = texture(screen_texture, SCREEN_UV, 3);
	LIGHT = texture(screen_texture, SCREEN_UV, 0.0);
	//LIGHT = vec4(255,255,255,0.1);
}
