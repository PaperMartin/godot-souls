shader_type spatial;
render_mode unshaded, world_vertex_coords, depth_draw_always, depth_test_disable, shadows_disabled, blend_mix;

uniform sampler2D VerticalGradient;
uniform int MAX_MARCH_STEP = 255;
uniform float scrollSpeed = 1.0;
uniform float flameScale = 25;
uniform vec3 sphere1Pos;
uniform float sphere1Radius = 1;
uniform vec3 sphere2Pos;
uniform float sphere2Radius = 1;
uniform float smoothing = 1;
uniform float flameSmoothing = 1;

const highp float EPSILON = 0.001;
const float MIN_DIST = 0.0;
const float MAX_DIST = 25.0;

varying vec3 camPos;
varying vec3 vertexPos;
varying vec3 noiseScroll;

float random (vec3 p3) {
	p3  = fract(p3 * .1031);
	p3 += dot(p3, p3.zyx + 31.32);
	return fract((p3.x + p3.y) * p3.z);
}


float noise3d( vec3 uvw ){
	vec3 u = fract(uvw);
	uvw = floor(uvw);
	u = smoothstep(0.0,1.0,u); // uncomment for linear
	float a = random( uvw );
	float b = random( uvw+vec3(1.0,0.0,0.0) );
	float c = random( uvw+vec3(0.0,1.0,0.0) );
	float d = random( uvw+vec3(1.0,1.0,0.0) );
	float e = random( uvw+vec3(0.0,0.0,1.0) );
	float f = random( uvw+vec3(1.0,0.0,1.0) );
	float g = random( uvw+vec3(0.0,1.0,1.0) );
	float h = random( uvw+vec3(1.0,1.0,1.0) );
	
    return mix(mix(mix( a, b, u.x),
                   mix( c, d, u.x), u.y),
               mix(mix( e, f, u.x),
                   mix( g, h, u.x), u.y), u.z);
}

float fbm(vec3 x) {
	float v = 0.0;
	float a = 0.5;
	vec3 shift = vec3(200.0);
	const int OCTAVES = 2;
	for (int i = 0; i < OCTAVES; ++i) {
		v += a * noise3d(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

float sdf_noise(vec3 pos){
	return fbm(pos) -1.0;
}

float smoothMin(float dstA, float dstB, float k){
	float h = clamp( 0.5 + 0.5*(dstB-dstA)/k, 0.0, 1.0 );
	return mix( dstB, dstA, h ) - k*h*(1.0-h);
}

float smoothMax(float dstA, float dstB, float k)
{
    return smoothMin(dstA, dstB, -k);
}

float intersect_sdf(float distA,float distB){
	return max (distA, distB);
}

float union_sdf(float distA, float distB){
	return min (distA,distB);
}

float difference_sdf(float distA, float distB){
	return max (distA, -distB);
}

float sdf_sphere(vec3 samplePoint,vec3 pos,float size){
	return length(samplePoint + pos) - size;
}

float sdf_box(vec3 samplePoint,vec3 pos, vec3 bounds){
	vec3 q = abs(samplePoint + pos) - bounds;
	
	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdf_scene(vec3 samplePoint,vec3 objectPos){
	float sphere = sdf_sphere(samplePoint, -sphere1Pos - objectPos, sphere1Radius);
	float sphere2 = sdf_sphere(samplePoint, -sphere2Pos - objectPos, sphere2Radius);
	float noise = sdf_noise(((samplePoint  - objectPos) * flameScale) + noiseScroll);
	float sphere2noise = smoothMin(sphere2,-noise,flameSmoothing);
	//return sphere2noise;
	return smoothMin(sphere,sphere2noise,smoothing);
}

float shortestDistanceToSurface(vec3 eye, vec3 viewRayDirection,vec3 objectPos, float start, float end){
	float depth = start;
	for (int i = 0; i < MAX_MARCH_STEP; i++){
		
		float dist = sdf_scene(eye + depth * viewRayDirection,objectPos);
		
		if (dist < EPSILON){
			return depth;
		}
		
		depth += dist;
		
		if (depth >= end){
			return end;
		}
	}
}

vec3 rayDirection(float fov, vec2 size, vec2 fragcoord){
	vec2 xy = fragcoord - size / 2.0;
	float z = size.y / tan(radians(fov) / 2.0);
	return normalize(vec3(xy,-z));
}

vec3 estimateNormal(vec3 samplePoint, vec3 objectPos){
	return normalize(vec3(
		sdf_scene(vec3(samplePoint.x + EPSILON, samplePoint.y, samplePoint.z), objectPos) - sdf_scene(vec3(samplePoint.x - EPSILON, samplePoint.y, samplePoint.z), objectPos),
        sdf_scene(vec3(samplePoint.x, samplePoint.y + EPSILON, samplePoint.z), objectPos) - sdf_scene(vec3(samplePoint.x, samplePoint.y - EPSILON, samplePoint.z), objectPos),
        sdf_scene(vec3(samplePoint.x, samplePoint.y, samplePoint.z  + EPSILON), objectPos) - sdf_scene(vec3(samplePoint.x, samplePoint.y, samplePoint.z - EPSILON), objectPos)
	));
}

void vertex(){
	camPos = CAMERA_MATRIX[3].xyz;
	vertexPos = VERTEX;
	float scroll = TIME * scrollSpeed;
	noiseScroll = vec3(10000,10000,10000) -  vec3(0,scroll,0);
}

void fragment(){
	vec3 dir = normalize(vertexPos - camPos);
	float dist = shortestDistanceToSurface(camPos,dir,WORLD_MATRIX[3].xyz,MIN_DIST,MAX_DIST);
	if (dist > MAX_DIST - EPSILON){
		discard;
	}
	
	float depth = texture(DEPTH_TEXTURE,SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	if (dist > linear_depth){
		discard;
	}
	
	DEPTH = dist;
	vec3 p = camPos + dist * dir;
	vec3 normal = estimateNormal(p,WORLD_MATRIX[3].xyz);
	NORMAL = (INV_CAMERA_MATRIX * vec4(normal, 0.0)).xyz;
	
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	
	ALBEDO = texture(VerticalGradient,vec2(fresnel,0)).xyz;
}