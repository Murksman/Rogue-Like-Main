shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D vision_shape;
uniform float view_angle : hint_range(0.0, 1.0);
uniform float vision_fade_length : hint_range(0.0, 1.0);
uniform float vision_horizontal_offset : hint_range(0.0, 1.0);

uniform float peripheral_radius : hint_range(0.0, 1.0);
uniform float peripheral_cutoff : hint_range(0.0, 1.0);
uniform vec2 look_direction = vec2(0.0, 1.0);

uniform vec2 r_vision_displacement = vec2(3.0, 0.0);
uniform vec2 g_vision_displacement = vec2(0.0, 2.0);
uniform vec2 b_vision_displacement = vec2(-3.0, 0.0);

vec2 Orientate(vec2 input_uv) {
	vec2 rotation_uv = vec2(-input_uv.y, -input_uv.x);
	
	float real_c = (rotation_uv.x * look_direction.x) + (rotation_uv.y * look_direction.y * -1.0);
	float complex_c = (rotation_uv.x * look_direction.y) + (rotation_uv.y * look_direction.x); 
	
	return vec2(real_c, complex_c);
}

void fragment() {
	vec2 uv = SCREEN_UV * vec2(1.77777, 1.0) - vec2(0.388888, 0.0);
	vec2 rotatedUV = Orientate(uv - vec2(0.5, 0.5)) + vec2(0.5, 0.5);
	
	vec2 vision_cone;
	if (rotatedUV.x > 0.5) {
		if (rotatedUV.x > 0.5 - vision_horizontal_offset && rotatedUV.x < 0.5 + vision_horizontal_offset) {}
		vision_cone = rotatedUV - vec2(vision_horizontal_offset, 0.0);
	} else {
		vision_cone = rotatedUV + vec2(vision_horizontal_offset, 0.0);
	}
	
	float vision_ratio = abs(vision_cone.x - 0.5) / abs(vision_cone.y - 0.5);
	float distortion_effect = smoothstep(0.0, 1.0, ((vision_ratio - view_angle) / vision_fade_length) + vision_fade_length);
	
	float dist = length(uv - vec2(0.5, 0.5)) - peripheral_radius;
	float cutoffAmount = smoothstep(0.0, 1.0, (dist / peripheral_cutoff) + peripheral_cutoff);
	
	if (rotatedUV.x > 0.5 - vision_horizontal_offset && rotatedUV.x < 0.5 + vision_horizontal_offset) {distortion_effect = 0.0;}
	
	if (rotatedUV.y > 0.5) {distortion_effect = 1.0;}
	
	if (distortion_effect > cutoffAmount) {distortion_effect = cutoffAmount;}
	
	if (texture(vision_shape, SCREEN_UV, 0.0).r < 0.2) {distortion_effect = 1.0;}
	
	float blur = mix(0.0, 2.0, distortion_effect);
	float r = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*r_vision_displacement*distortion_effect*look_direction), blur).r;
	float g = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*g_vision_displacement*distortion_effect*look_direction), blur).g;
	float b = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*b_vision_displacement*distortion_effect*look_direction), blur).b;
	// vec3 c = (texture(vision_shape, SCREEN_UV, 0.0).rgb);
	
	vec3 c = vec3(r,g,b);
	
	COLOR.rgb = mix(c, c / 3.0, distortion_effect);
	COLOR.a = 1.0;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
