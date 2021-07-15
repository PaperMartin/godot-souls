shader_type spatial;
render_mode world_vertex_coords, shadows_disabled;
uniform vec4 WaterColor : hint_color;
uniform float metallic : hint_range(0,1);
uniform float roughness : hint_range(0,1);
uniform float depthFactor = 1;
uniform sampler2D normal1 : hint_normal;
uniform vec4 normal1param = vec4(1,1,0,0);
uniform sampler2D normal2 : hint_normal;
uniform vec4 normal2param = vec4(1,1,0,0);
uniform float normalstrength = 1;

varying vec2 worldcoords;

void vertex(){
	worldcoords = VERTEX.xz;
}

void fragment(){
	float depth = texture(DEPTH_TEXTURE,SCREEN_UV).r;
	depth = depth * 2.0 - 1.0;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	depth = depth + VERTEX.z;
	depth = exp(-depth * depthFactor);
	
	depth = clamp(depth,0.0,1.0);
	
	ALPHA = 1.0 - depth;
	
	ALBEDO = WaterColor.xyz;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	vec3 normalsample1 = texture(normal1,(worldcoords / normal1param.xy) + normal1param.zw * TIME).xyz;
	vec3 normalsample2 = texture(normal2,(worldcoords / normal2param.xy) + normal2param.zw * TIME).xyz;
	NORMALMAP = mix(normalsample1,normalsample2,0.5);
	NORMALMAP_DEPTH = normalstrength;
}