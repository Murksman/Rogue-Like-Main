shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

uniform float brightness: hint_range(0.0, 2.0);
uniform float contrast: hint_range(0.0, 1.0);
uniform float saturation: hint_range(0.0, 2.0);

void fragment() {
	vec4 c = texture(screen_texture, SCREEN_UV, 0.0);
	
	c.rgb = mix(vec3(0.0), c.rgb, brightness);
	c.rgb = mix(vec3(0.5), c.rgb, contrast);
	c.rgb = mix(vec3(dot(vec3(1.0), c.rgb) * 0.33333), c.rgb, saturation);
	
	
	COLOR = c;
}