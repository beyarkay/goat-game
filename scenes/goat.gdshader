shader_type canvas_item;

uniform int player;

void fragment() {
	vec4 pixel_colour = texture(TEXTURE, UV);
	vec4 dark_brown = vec4(
		74.0/255.0,
		58.0/255.0,
		48.0/255.0,
		0.0
	);
	vec4 light_brown = vec4(
		171.0/255.0,
		144.0/255.0,
		89.0/255.0,
		0.0
	);

	if (player == 2) {
		vec3 delta = abs(pixel_colour.rgb - dark_brown.rgb);
		vec3 rgb = length(delta) < 0.1 ? light_brown.rgb : pixel_colour.rgb;
		COLOR = vec4(rgb, pixel_colour.a);
	}
}
