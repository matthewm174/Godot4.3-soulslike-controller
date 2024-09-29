shader_type spatial;
render_mode specular_schlick_ggx;

uniform sampler2D ground_albedo;
uniform sampler2D ground_normal_map : hint_normal;
uniform sampler2D ground_roughness;
uniform sampler2D rain_splash : hint_normal;
uniform sampler2D rain_wet_normal : hint_normal;
uniform sampler2D noise;

uniform float blend_raining;

uniform vec3 world_up;

varying vec3 normal_vec;

float bias(float value,float power){
	return pow(value,power);
}

void vertex(){
	normal_vec = NORMAL;
}

void fragment(){
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	float offset = texture(noise,UV).r*0.5;
	vec3 water_travel_direction = world_up - normal_vec;
	vec2 compressed_water_travel_direction = water_travel_direction.xz;
	ROUGHNESS = (1.0 - blend_raining) + fresnel*0.1;
	METALLIC = bias(blend_raining,0.5)/2.0+0.3;
	SPECULAR = 1.0;
	float mix_factor = -((2.0*(0.5))/3.141592)*asin(sin((2.0*3.141592)*(TIME+0.25+offset)))+0.5;
	vec3 newnormal = mix(texture(rain_wet_normal,UV+compressed_water_travel_direction*mod(TIME+0.5+offset,1.0)).rgb,texture(rain_wet_normal,UV+compressed_water_travel_direction*mod(TIME+offset,1.0)).rgb,mix_factor);
	NORMALMAP = mix(texture(ground_normal_map,UV).rgb,newnormal,bias(blend_raining,0.4));
	ALBEDO = texture(ground_albedo,UV+(newnormal.xz*bias(blend_raining,8.0)/50.0)).rgb + fresnel*0.1;
	RIM = blend_raining / 10.0;
	
}