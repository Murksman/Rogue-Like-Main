shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float view_angle : hint_range(0.0, 1.0);
uniform float vision_fade_length : hint_range(0.0, 1.0);
uniform float vision_horizontal_offset : hint_range(0.0, 1.0);

uniform float peripheral_radius : hint_range(0.0, 1.0);
uniform float peripheral_cutoff : hint_range(0.0, 1.0);
uniform vec2 look_direction = vec2(0.0, 1.0);
uniform vec2 player_offset = vec2(0.0, 0.0);

uniform vec2 r_vision_displacement = vec2(3.0, 0.0);
uniform vec2 g_vision_displacement = vec2(0.0, 2.0);
uniform vec2 b_vision_displacement = vec2(-3.0, 0.0);

vec2 Orientate(vec2 input_uv) {
	vec2 rotation_uv = vec2(-input_uv.y, -input_uv.x);
	
	float real_c = (rotation_uv.x * look_direction.x) - (rotation_uv.y * look_direction.y);
	float complex_c = (rotation_uv.x * look_direction.y) + (rotation_uv.y * look_direction.x); 
	
	return vec2(real_c, complex_c);
}

void fragment() {
	vec2 uv = (SCREEN_UV + player_offset) * vec2(1.77777, 1.0) - vec2(0.388888, 0.0);
	vec2 rotatedUV = Orientate(uv - vec2(0.5, 0.5)) + vec2(0.5, 0.5);
	vec2 vision_cone;
	if (rotatedUV.x > 0.5) {
		// if (rotatedUV.x > 0.5 - vision_horizontal_offset && rotatedUV.x < 0.5 + vision_horizontal_offset) {}
		vision_cone = rotatedUV - vec2(vision_horizontal_offset, 0.0);
	} else {
		vision_cone = rotatedUV + vec2(vision_horizontal_offset, 0.0);
	}
	
	// float vision_fade = vision_fade_length / (rotatedUV.x + 0.5);
	float vision_ratio = abs(vision_cone.x - 0.5) / abs(vision_cone.y - 0.5);
	float distortion_effect = smoothstep(0.0, 1.0, ((vision_ratio - view_angle) / vision_fade_length) + vision_fade_length);
	
	float dist = length(uv - vec2(0.5, 0.5)) - peripheral_radius;
	float cutoffAmount = smoothstep(0.0, 1.0, (dist / peripheral_cutoff) + peripheral_cutoff);
	
	if (rotatedUV.x > 0.5 - vision_horizontal_offset && rotatedUV.x < 0.5 + vision_horizontal_offset) {distortion_effect = 0.0;}
	
	if (rotatedUV.y > 0.5) {distortion_effect = 1.0;}
	
	// distortion_effect -= cutoffAmount;
	if (distortion_effect > cutoffAmount) {distortion_effect = cutoffAmount;}
	distortion_effect = clamp(distortion_effect,0.0,1.0); 
	
	vec4 c = texture(screen_texture, SCREEN_UV, 1.0);
	
	// vec3 c = (texture(vision_shape, SCREEN_UV, 0.0).rgb);
	
	c = mix(c, vec4(1), distortion_effect);
	COLOR = vec4(c.x,c.y,c.z,distortion_effect);
}
