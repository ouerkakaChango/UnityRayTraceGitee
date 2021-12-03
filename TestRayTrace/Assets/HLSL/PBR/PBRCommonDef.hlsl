#ifndef PBRCOMMONDEF_HLSL
#define PBRCOMMONDEF_HLSL
struct Material_PBR
{
	float3 albedo;
	float metallic;
	float roughness;
};

//https://learnopengl-cn.github.io/07%20PBR/03%20IBL/01%20Diffuse%20irradiance/
float3 fresnelSchlickRoughness(float cosTheta, float3 F0, float roughness)
{
	float3 tt = 1.0 - roughness;
	return F0 + (max(tt, F0) - F0) * pow(1.0 - cosTheta, 5.0);
}

#endif