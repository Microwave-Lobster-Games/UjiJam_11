shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D texture_albedo : source_color, filter_nearest;
uniform vec4 target_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); 
uniform float threshold : hint_range(0.0, 1.0) = 0.1;                 

uniform bool open_door = false;

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
}

void fragment() {
	vec4 tex_color = texture(texture_albedo, UV);
    ALBEDO = tex_color.rgb;
    ALPHA = tex_color.a;
    
    float color_diff = distance(tex_color.rgb, target_color.rgb);
    
    if (!open_door && color_diff < threshold) {
        ALPHA = 0.0;
    }
	
	else {
		ALPHA = tex_color.a;
	} 
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
