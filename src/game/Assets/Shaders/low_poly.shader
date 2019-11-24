shader_type spatial;

// color property
uniform vec4 color : hint_color;
// heightmap texture
uniform sampler2D tex;
// factor of height
uniform int height_range = 0;

void vertex() {
	// assign heights using a heightmap
	// see: https://godot.readthedocs.io/en/latest/tutorials/3d/mesh_generation_with_heightmap_and_shaders.html
	VERTEX = vec3(VERTEX.x, texture(tex, UV).g * float(height_range), VERTEX.z);
}

void fragment() {
	// same normal vector for every face
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	// green color
	vec3 material_color = color.rgb;
	ALBEDO = material_color;
}
