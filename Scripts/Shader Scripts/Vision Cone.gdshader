shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D mask_texture;

uniform vec2 r_vision_displacement = vec2(3.0, 0.0);
uniform vec2 g_vision_displacement = vec2(0.0, 2.0);
uniform vec2 b_vision_displacement = vec2(-3.0, 0.0);


void fragment() {
	float effect = texture(mask_texture, SCREEN_UV).r;
	
	float blur = mix(0.0, 0.0, effect);
	float r = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*r_vision_displacement*effect), blur).r;
	float g = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*g_vision_displacement*effect), blur).g;
	float b = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*b_vision_displacement*effect), blur).b;
	// vec3 c = (texture(vision_shape, SCREEN_UV, 0.0).rgb);
	
	vec3 c = vec3(r,g,b);
	c = mix(c, c * 1.0, effect);
	COLOR = vec4(c.x,c.y,c.z,effect);
}
