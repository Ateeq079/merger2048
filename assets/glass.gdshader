shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;
uniform vec4 mix_color : source_color = vec4(1.0, 1.0, 1.0, 0.2);

void fragment() {
	vec4 blurred = textureLod(screen_texture, SCREEN_UV, blur_amount);
	vec4 style_color = COLOR;
	
	if (style_color.a > 0.0) {
		COLOR.rgb = mix(blurred.rgb, mix_color.rgb, mix_color.a);
		COLOR.a = style_color.a; // preserve original alpha for anti-aliased corners
	}
}
