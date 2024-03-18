shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float brightness: hint_range(0.0, 1.0);
uniform float contrast: hint_range(0.0, 1.0);
uniform float saturation: hint_range(0.0, 2.0);

uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

void fragment() {
	float r = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*r_displacement), 0.0).r;
	float g = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*g_displacement), 0.0).g;
	float b = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*b_displacement), 0.0).b;
	vec3 c = vec3(r,g,b);
	
	c = mix(vec3(0.0), c.rgb, brightness);
	c = mix(vec3(0.5), c.rgb, contrast);
	c = mix(vec3(dot(vec3(1.0), c.rgb) * 0.33333), c.rgb, saturation);
	
	
	COLOR = vec4(c, 1.0);
}