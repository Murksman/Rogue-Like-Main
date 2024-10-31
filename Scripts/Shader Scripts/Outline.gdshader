shader_type canvas_item;

render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap_anisotropic;
uniform float opacity : hint_range(0.0, 1.0, 0.05);
uniform float highlight_opacity : hint_range(0.0, 1.0, 0.05);
uniform float highlight_thickness : hint_range(0.0, 10.0, 0.1);
uniform float highlight_bias : hint_range(0.0, 1.0, 0.01);
uniform vec4 highlight_color : source_color; 

void fragment() {
	COLOR = texture(screen_texture, SCREEN_UV);
	
	if (COLOR.a > 0.001 && textureLod(screen_texture, SCREEN_UV, highlight_thickness).a < highlight_bias) {
		COLOR = mix(COLOR, highlight_color, highlight_opacity);
	}
	else {
		COLOR.a *= opacity;
	}
}
