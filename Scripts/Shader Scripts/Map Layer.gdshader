shader_type canvas_item;

render_mode unshaded;

uniform bool is_visible = true;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

void fragment() {
	vec4 c = texture(screen_texture, SCREEN_UV);;
	if (!is_visible) {
		c.a *= 0.2;
	}
	COLOR = c;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
