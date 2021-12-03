#include "../PBR/PBRCommonDef.hlsl"
#include "../TransferMath/TransferMath.hlsl"

float3 GetEnvIrradiance_equirectangular(Texture2D envTex, float3 dir)
{
	dir = normalize(dir);

	float2 uv = EquirectangularToUV(dir);
	uint envTexW, envTexH;
	envTex.GetDimensions(envTexW, envTexH);
	return envTex[uv*float2(envTexW, envTexH)];
}

float3 PBR_IBL(Texture2D envTex, Material_PBR param, float3 N, float3 V)
{
	//???
	float ao = 1;

	float3 F0 = 0.04;
	F0 = lerp(F0, param.albedo, param.metallic);

	float3 kS = fresnelSchlickRoughness(max(dot(N, V), 0.0), F0, param.roughness);
	float3 kD = 1.0 - kS;
	float3 irradiance = GetEnvIrradiance_equirectangular(envTex, N);

	float3 indirect_diffuse = (kD * irradiance * param.albedo) * ao;

	//???
	return indirect_diffuse;
}