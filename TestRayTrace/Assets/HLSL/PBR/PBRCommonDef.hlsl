#ifndef PBRCOMMONDEF_HLSL
#define PBRCOMMONDEF_HLSL
#include "../TransferMath/TransferMath.hlsl"

struct Material_PBR
{
	float3 albedo;
	float metallic;
	float roughness;
};

float DistributionGGX(float3 N, float3 H, float roughness)
{
	float a = max(0.001f, roughness * roughness);
	float a2 = a * a;
	float NdotH = max(dot(N, H), 0.0);
	float NdotH2 = NdotH * NdotH;

	float nom = a2;
	float denom = (NdotH2 * (a2 - 1.0) + 1.0);
	denom = PI * denom * denom;

	return nom / denom;
}

float DistributionGGX(float NdotH, float roughness)
{
	float a = max(0.001f, roughness * roughness);
	float a2 = a * a;
	float NdotH2 = NdotH * NdotH;

	float nom = a2;
	float denom = (NdotH2 * (a2 - 1.0) + 1.0);
	denom = PI * denom * denom;

	return nom / denom;
}

//#######################################################################################

//https://learnopengl-cn.github.io/07%20PBR/03%20IBL/01%20Diffuse%20irradiance/
float3 fresnelSchlickRoughness(float cosTheta, float3 F0, float roughness)
{
	float3 tt = 1.0 - roughness;
	return F0 + (max(tt, F0) - F0) * pow(1.0 - cosTheta, 5.0);
}

float3 IS_SampleSpecularH(float3 N, float roughness, float x1, float x2)
{
	float a = max(0.001f, roughness*roughness);
	float phi = 2 * PI*x1;
	float costheta = sqrt((1 - x2) / (1 + (a*a - 1)*x2));
	float sintheta = sqrt(max(0.0, 1.0 - costheta * costheta)); //·ÀÖ¹¼«ÏÞÎó²î -0.00000x
	float3 H = float3(
		sintheta*cos(phi),
		sintheta*sin(phi),
		costheta);
	return Vec2NormalHemisphere(H, N);
}

#endif