shader_type canvas_item;
uniform vec4 outline_color : source_color;
uniform vec4 outline_selected_color : source_color;
uniform float outline_width;
uniform float corner_radius : hint_range(0.0, 64.0, 0.1);

uniform float selected_blend = 0.0;

void fragment() {
	//vec2 corner_uv = vec2(corner_radius) * 0.016;
	vec2 corner_uv = corner_radius * TEXTURE_PIXEL_SIZE;
	vec2 px = abs(UV - vec2(0.5)) - vec2(0.5) + corner_uv;
	
	bool outline = false;
	
	if (px.x < 0.0) {
		if (px.y + outline_width * TEXTURE_PIXEL_SIZE.y > corner_uv.y) {
			outline = true;
		} else if (px.y < 0.0 && px.x + outline_width * TEXTURE_PIXEL_SIZE.x > corner_uv.x) {
			outline = true;
		}
	}
	else if (px.y < 0.0) {
		if (px.x + outline_width * TEXTURE_PIXEL_SIZE.x > corner_uv.x) {
			outline = true;
		}
	}
	else {
		vec2 r_inner = max(0.0, corner_radius - outline_width) * TEXTURE_PIXEL_SIZE;
		if (length(vec2(px.x, px.y) / r_inner) > 1.0) {
			if (length(vec2(px.x, px.y) / corner_uv) > 1.0) {
				COLOR.a = 0.0;
			} else {
				outline = true;
			}
		}
	}
	
	if (outline) {
		vec4 blended_color = mix(outline_color, outline_selected_color, selected_blend);
		COLOR.rgb = mix(COLOR.rgb, blended_color.rgb, blended_color.a);
	}
}
