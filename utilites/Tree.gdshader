shader_type spatial;
render_mode cull_disabled; 

uniform sampler2D atlas_texture : source_color, filter_nearest;
uniform int atlas_columns = 3; 

varying flat float tex_index;

void vertex() {
	vec3 billboard_scale = vec3(
		length(MODEL_MATRIX[0]),
		length(MODEL_MATRIX[1]),
		length(MODEL_MATRIX[2])
	);
	
	mat4 m = VIEW_MATRIX * MODEL_MATRIX;
	m[0][0] = billboard_scale.x;
	m[0][1] = 0.0;
	m[0][2] = 0.0;
	
	m[2][0] = 0.0;
	m[2][1] = 0.0;
	m[2][2] = billboard_scale.z;
	
	MODELVIEW_MATRIX = m;
	tex_index = floor(INSTANCE_CUSTOM.r + 0.5);
}

void fragment() {
	float scale_x = 1.0 / float(atlas_columns);
	vec2 adjusted_uv = UV;
	
	adjusted_uv.x = (UV.x * scale_x) + (tex_index * scale_x);
	
	vec4 tex_color = texture(atlas_texture, adjusted_uv);
	
	ALBEDO = tex_color.rgb;
	
	ALPHA = tex_color.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	
	NORMAL = (VIEW_MATRIX * vec4(0.0, 0.0, 1.0, 0.0)).xyz;
}