shader_type canvas_item;

uniform int px_ratio;
uniform float line_thickness;
uniform int int_thickness;
//uniform vec4 line_color : source_color;

uniform sampler2D image : hint_screen_texture;

void fragment() {
	vec2 pixel = UV / TEXTURE_PIXEL_SIZE + vec2(line_thickness / 2.0);
	if (int(pixel.x) % px_ratio < int_thickness || int(pixel.y) % px_ratio < int_thickness) {
		float color_brightness = length(texture(image, SCREEN_UV).rgb);
		if (color_brightness > 0.8) {
			COLOR.rgb = vec3(0.2);
		} else {
			COLOR.rgb = vec3(1.0 - color_brightness);
		}
		COLOR.a = 0.6;
		//COLOR = vec4(0);
	} else {COLOR = vec4(0);}
}

