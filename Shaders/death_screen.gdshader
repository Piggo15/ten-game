shader_type canvas_item;

uniform sampler2D SCREEN : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec3 result = textureLod(SCREEN, SCREEN_UV, 1.5).rgb;
	COLOR.rgb = result; 
}
