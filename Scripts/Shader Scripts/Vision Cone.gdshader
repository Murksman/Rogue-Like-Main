shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform sampler2D mask_texture;

uniform sampler2D lensing_noise_map : filter_nearest;
uniform sampler2D fog_noise_map : filter_linear_mipmap;

uniform vec2 r_vision_displacement = vec2(3.0, 0.0);
uniform vec2 g_vision_displacement = vec2(0.0, 2.0);
uniform vec2 b_vision_displacement = vec2(-3.0, 0.0);

uniform float vision_noise_amplitude : hint_range(0.0, 100.0, 0.5);
uniform float vision_cone_blurring : hint_range(0.0, 10.0, 0.1);


void fragment() {
	float effect = texture(mask_texture, SCREEN_UV).r;
	
	float blur = mix(0.0, vision_cone_blurring, effect);
	
	vec3 lensing = texture(lensing_noise_map, SCREEN_UV).rgb;
	vec2 lensing_displacement = (vec2(lensing.x, lensing.y) - vec2(0.5)) * vision_noise_amplitude;
	
	vec2 r_displacement = SCREEN_PIXEL_SIZE*((r_vision_displacement*effect) + lensing_displacement);
	vec2 g_displacement = SCREEN_PIXEL_SIZE*((g_vision_displacement*effect) + lensing_displacement);
	vec2 b_displacement = SCREEN_PIXEL_SIZE*((b_vision_displacement*effect) + lensing_displacement);
	
	float r = textureLod(screen_texture, SCREEN_UV + r_displacement, blur).r;
	float g = textureLod(screen_texture, SCREEN_UV + g_displacement, blur).g;
	float b = textureLod(screen_texture, SCREEN_UV + b_displacement, blur).b;
	
	vec3 c = vec3(r,g,b);
	
	vec4 fog = textureLod(fog_noise_map, SCREEN_UV, 0.0);
	
	c = mix(c, vec3(0.0, 0.15, 0.2), clamp(1.0 - (r+g+b) / 1.0, 0.0, 1.0));
	//c = mix(c, c * 1.0, effect);
	
	COLOR = vec4(c.x,c.y,c.z,effect);
	//COLOR = texture(lensing_noise_map, SCREEN_UV);
}
