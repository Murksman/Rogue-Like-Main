shader_type canvas_item;

render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform sampler2D mask_texture;
uniform bool is_visible = true;
uniform bool is_editing = true;

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	COLOR = color;
	
	if (!is_editing) {
		vec4 mask_value = texture(mask_texture, SCREEN_UV);
		
		COLOR.a = (1.0 - mask_value.r) * color.a;
	}
	
	if (!is_visible) {
		COLOR.a *= 0.2;
	}
}
