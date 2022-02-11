#ifndef DD_PD_BRDF_INCLUDED
#define DD_PD_BRDF_INCLUDED

#include "UnityStandardBRDF.cginc"

half3 IndirectSpecularTerm_BRDF2(half3 indirectLightColor, half3 specColor, half nv, half smoothness, half roughness, half perceptualRoughness, half oneMinusReflectivity)
{
	half surfaceReduction = (0.6 - 0.08 * perceptualRoughness);
	surfaceReduction = 1.0 - roughness * perceptualRoughness * surfaceReduction;
	half grazingTerm = saturate(smoothness + (1 - oneMinusReflectivity));

	return surfaceReduction * FresnelLerpFast(specColor, grazingTerm, nv) * indirectLightColor;
}

half3 IndirectSpecularTerm_BRDF3(half3 indirectLightColor, half3 specColor, half nv, half smoothness, half roughness, half perceptualRoughness, half oneMinusReflectivity)
{
	half fresnelTerm = Pow4(1 - nv);
	half grazingTerm = saturate(smoothness + (1 - oneMinusReflectivity));
	return lerp(specColor, grazingTerm, fresnelTerm) * indirectLightColor;
}

half3 NoIndirectSpecularTerm(half3 indirectLightColor, half3 specColor, half nv, half smoothness, half roughness, half perceptualRoughness, half oneMinusReflectivity)
{
	return 0;
}

half3 DiffuseTerm_HalfLambert(half3 lightColor, half3 diffColor, half nl)
{
	return diffColor * (nl * 0.5 + 0.5) * lightColor;
}

half3 DiffuseTerm_Lambert(half3 lightColor, half3 diffColor, half nl)
{
	return diffColor * max(nl, 0) * lightColor;
}

half3 SpecularTerm_PBR_BRDF2(half3 lightColor, half3 specColor, half nl, half3 N, half3 L, half3 V, half smoothness, half roughness)
{
	float3 halfDir = Unity_SafeNormalize(float3(L)+V);
	float nh = saturate(dot(N, halfDir));
	float lh = saturate(dot(L, halfDir));

	half a2 = roughness * roughness;

	half d = nh * nh * (a2 - 1.f) + 1.00001f;
	half specularTerm = 1;
	specularTerm = a2 / (max(0.1h, lh * lh) * (roughness + 0.5h) * (d * d) * 4.0h);
#if defined (SHADER_API_MOBILE)
	specularTerm = specularTerm - 1e-4f;
#endif
#if defined (SHADER_API_MOBILE)
	specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
#endif

	return specularTerm * specColor * max(nl, 0) * lightColor;
}

half3 SpecularTerm_PBR_BRDF3(half3 lightColor, half3 specColor, half nl, half3 N, half3 L, half3 V, half smoothness, half roughness)
{
	float3 reflDir = reflect(V, N);
	half rl = dot(reflDir, L);
	half nv = saturate(dot(N, V));

	half2 rlPow4AndFresnelTerm = Pow4(float2(rl, 1 - nv));  // use R.L instead of N.H to save couple of instructions
	half rlPow4 = rlPow4AndFresnelTerm.x; // power exponent must match kHorizontalWarpExp in NHxRoughness() function in GeneratedTextures.cpp

	half LUT_RANGE = 16.0;
	half specularTerm = tex2D(unity_NHxRoughness, half2(rlPow4, SmoothnessToPerceptualRoughness(smoothness))).r * LUT_RANGE;


	return specularTerm * specColor * max(nl, 0) * lightColor;
}

half3 NoSpecularTerm(half3 lightColor, half3 specColor, half nl, half3 N, half3 L, half3 V, half smoothness, half roughness)
{
	return 0;
}

#endif