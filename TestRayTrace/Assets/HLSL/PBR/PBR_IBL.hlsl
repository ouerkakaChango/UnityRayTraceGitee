#include "../PBR/PBRCommonDef.hlsl"

float3 GetEnvIrradiance_equirectangular(Texture2D envTex, float3 dir, bool unityDir)
{
	dir = normalize(dir);

	float2 uv = EquirectangularToUV(dir, unityDir);
	uint envTexW, envTexH;
	envTex.GetDimensions(envTexW, envTexH);
	return envTex[uv*float2(envTexW, envTexH)].rgb;
}

SamplerState my_point_repeat_sampler;
float3 GetEnvIrradiance_equirectangular(Texture2D envTex, float3 dir, float mip, bool unityDir)
{
	dir = normalize(dir);
	float2 uv = EquirectangularToUV(dir, unityDir);
	return envTex.SampleLevel(my_point_repeat_sampler, uv, mip).rgb;
}

//https://learnopengl-cn.github.io/07%20PBR/03%20IBL/02%20Specular%20IBL/
//https://matheowis.github.io/HDRI-to-CubeMap/

const float MAX_REFLECTION_LOD = 4.0;
SamplerState my_point_clamp_sampler;
SamplerState _LinearClamp;
float3 PBR_IBL(Texture2D envDiffTex, Texture2D envRefTex, Texture2D brdfLUT, Material_PBR param, float3 N, float3 V)
{
	//???
	float ao = 1;

	float3 F0 = 0.04;
	F0 = lerp(F0, param.albedo, param.metallic);

	//diffuse
	float3 kS = fresnelSchlickRoughness(max(dot(N, V), 0.0), F0, param.roughness);
	float3 kD = 1.0 - kS;
	float3 irradiance = GetEnvIrradiance_equirectangular(envDiffTex, N, true);
	float3 indirect_diffuse = (kD * irradiance * param.albedo) * ao;

	//spec
	float3 R = reflect(-V, N);
	
	float3 prefilteredColor;
	{
		//???
		//Unity_ComputeShader里没法用cubemap和它自带的卷积mip功能
		//得自己用texArr，将预积分的5张图放进去。
		//prefilteredColor = GetEnvIrradiance_equirectangular(envRefTex, R, param.roughness * MAX_REFLECTION_LOD, true);
	}
	{
		//??? 临时应付，不正确
		prefilteredColor = lerp(irradiance, GetEnvIrradiance_equirectangular(envRefTex, N, true), 1 - param.roughness);
	}
	float2 envBRDF_UV = 0;
	envBRDF_UV.x = max(dot(N, V),0);
	envBRDF_UV.y = param.roughness;
	
	float2 envBRDF = brdfLUT.SampleLevel(my_point_clamp_sampler, envBRDF_UV, 0).rg;
	float3 indirect_specular = prefilteredColor * (kS * envBRDF.x + envBRDF.y) * ao;

	return indirect_diffuse +indirect_specular;
}