shader_type canvas_item;

uniform sampler2D skin_plaette;
uniform sampler2D team_plaette;
uniform int skin_color : hint_enum("Light", "Medium", "Dark");
uniform int team_color;

vec2 px_to_uv(ivec2 pos, ivec2 tex_size){
	return vec2(
		(float(pos[0]) + 0.5) / float(tex_size[0]),
		(float(pos[1]) + 0.5) / float(tex_size[1])
	);
}

vec4 get_plaette_color(vec4 color, sampler2D plaette, int selection){
	ivec2 tex_size = textureSize(plaette,0);
	for(int i = 0; i < tex_size[0]; i++){
		vec2 uv_color_ref = px_to_uv(ivec2(i, 0), tex_size);
		vec4 color_ref = texture(plaette, uv_color_ref);
		if (color == color_ref){
			vec2 uv_color_dest = px_to_uv(ivec2(i, selection), tex_size);
			return texture(plaette, uv_color_dest);
		}
	}
	return color;
}

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = get_plaette_color(COLOR, team_plaette, team_color);
	if (skin_color > 0){
		COLOR = get_plaette_color(COLOR, skin_plaette, skin_color);
	}
}

void vertex() {
	// Called for every vertex the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
