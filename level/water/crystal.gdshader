shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

// Varyings
varying vec3 WorldPos;

uniform sampler2D colorGradient1;
uniform sampler2D colorGradient2;
uniform sampler2D NoiseTexture_Alpha : hint_normal;
uniform sampler2D NoiseTexture_Specular : hint_normal;
uniform sampler2D gradientSpecular;

void vertex() {
	mat4 n_out2p0 = MODEL_MATRIX;
	vec3 n_out3p0 = VERTEX;
	vec3 n_out4p0 = (n_out2p0 * vec4(n_out3p0, 1.0)).xyz;
	WorldPos = n_out4p0;
}

void fragment() {
	float worldPosY = WorldPos.y;
	float worldPosZ = WorldPos.z;

	vec4 color1 = texture(colorGradient1, vec2(worldPosY));
	vec4 color2 = texture(colorGradient2, vec2(worldPosZ));

	vec3 mixVector = vec3(1.00000, 1.00000, 1.00000);
	vec3 base_color = mix(vec3(color1.xyz), vec3(color2.xyz), mixVector);

// Alpha
	float noiseAlpha = texture(NoiseTexture_Alpha, UV).r;
	vec2 scaleUVFunc = vec2(1.00000, 1.00000);
	vec2 offsetUVFunc = vec2(0.00000, 1.00000);
	vec2 transparency = offsetUVFunc * scaleUVFunc + vec2(noiseAlpha);

// Specular
	float noiseSpecular = texture(NoiseTexture_Specular, UV).r;
	vec4 specular = texture(gradientSpecular, vec2(noiseSpecular));

// Output:0
	ALBEDO = base_color;
	ALPHA = transparency.x;
	SPECULAR = specular.x;
}
