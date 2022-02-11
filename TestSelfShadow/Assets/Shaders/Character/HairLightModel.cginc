#ifndef HAIR_LIGHT_MODEL_2_INCLUDED
#define HAIR_LIGHT_MODEL_2_INCLUDED

#include "UnityStandardUtils.cginc"

#define TEX1_UVST _MainTex_ST
#define INPUT_NEED_WORLD_TANGENT
#include "../Framework/DDShaderLightingCommon.cginc"
#include "../Framework/DDShaderUtil.cginc"

sampler2D _MainTex;
half4 _MainTex_ST;
half4 _Color;

sampler2D _NormalMap;

sampler2D _HairMask;
half _Glossiness;
half _Glossiness2;

half _ShiftValue1;
half4 _SpecularColor1;

half _ShiftValue2;
half4 _SpecularColor2;
half _Anisotropic;

struct HairSurfaceData
{
	half3 Albedo;
	half3 Normal;
	half3 Tangent;
	half Smoothness;
	half Smoothness2;
	half SpecularShift1;
	half SpecularShift2;
	half3 Emission;
	half SpecularScale;
};

inline void RestOutput(out HairSurfaceData IN)
{
	IN.Albedo = 0;
	IN.Normal = half3(0, 0, 1);
	IN.Tangent = half3(1, 0, 0);
	IN.Smoothness = 0;
	IN.Smoothness2 = 0;
	IN.SpecularShift1 = 0;
	IN.SpecularShift2 = 0;
	IN.Emission = 0;
	IN.SpecularScale = 1;
}

void surf(Input IN, inout HairSurfaceData o)
{
	half4 col = tex2D(_MainTex, IN.uv);
	half3 albedo = col.rgb * _Color.rgb;
#ifdef UNITY_COLORSPACE_GAMMA
	albedo = GammaToLinearSpace(albedo);
#endif
	o.Albedo = albedo;
	o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv));
	o.Tangent = IN.worldTangent;
	half4 mask = tex2D(_HairMask, IN.uv);
	o.Smoothness = _Glossiness;
	o.Smoothness2 = _Glossiness2;
	o.SpecularShift1 = mask.g - 0.5 + _ShiftValue1;
	o.SpecularShift2 = mask.g - 0.5 + _ShiftValue2;
	o.SpecularScale = mask.r;
}

#define SurfaceData_T HairSurfaceData
#define FUNC_SURF surf

struct HairShadingData
{
	half3 diffColor;
	half3 specColor1, specColor2;
	half3 tangent;
	half smoothness, smoothness2;
	half oneMinusReflectivity;
	half specularShift1, specularShift2;
	half alpha;
	half specularScale;
};

#define ShadingData_T HairShadingData
#include "../Predefine/DDPDUtils.cginc"

inline void ShadingPrepare_Hair(HairSurfaceData IN, out HairShadingData shadingData)
{
	half3 specColor = 0;
	shadingData.diffColor = DD_DiffuseAndSpecularFromMetallic(IN.Albedo, 0, specColor, shadingData.oneMinusReflectivity);
	shadingData.diffColor = IN.Albedo;
	shadingData.specColor1 = _SpecularColor1;
	shadingData.specColor2 = _SpecularColor2;

	shadingData.smoothness = IN.Smoothness;
	shadingData.smoothness2 = IN.Smoothness2;
	shadingData.tangent = IN.Tangent;

	shadingData.specularShift1 = IN.SpecularShift1;

	shadingData.specularShift2 = IN.SpecularShift2;
	shadingData.specularScale = IN.SpecularScale;
	shadingData.alpha = 1;
}

#define FUNC_SHADING_PREPARE ShadingPrepare_Hair

#define USE_UNITYGI
#define USE_CUSTOM_FUNC_GI
#include "../Predefine/DDPDShaderGI.cginc"

void Hair_GI(in SurfaceData_T s, in DDGIInput input, out DDGI gi)
{
	GI_IndirectDiffuse(1, input, gi);
}

#include "../Predefine/DDPDBRDF.cginc"

half3 SpecularTerm_KajiyaKay(half3 lightColor, half3 specColor, half nl, half3 worldTangent, half3 worldNormal, half shift, half3 viewDir, half3 lightDir, half shininess)
{
	half3 tangent = normalize(worldTangent + shift * worldNormal);
	float3 halfDir = Unity_SafeNormalize(float3(lightDir)+viewDir);
	half th = dot(tangent, halfDir);
	half sinTH = sqrt(1 - th * th);
	half dirAtten = smoothstep(-1, 0, th);
	return lightColor * specColor * dirAtten * pow(sinTH, shininess) * max(nl, 0);
}

half3 SpecularTerm_BRDF2_Anisotropic(half3 lightColor, half3 specColor, half nl, half3 worldNormal, half3 lightDir, half3 viewDir, half smoothness, half roughness, half3 worldTangent, half shift)
{
	half3 tangent = normalize(worldTangent + shift * worldNormal);
	float3 halfDir = Unity_SafeNormalize(float3(lightDir)+viewDir);
	half th = dot(tangent, halfDir);
	half sinTH = sqrt(1 - th * th);
	float nh = saturate(dot(worldNormal, halfDir));
	float lh = saturate(dot(lightDir, halfDir));

	half a2 = roughness * roughness;

	half d = sinTH * sinTH * (a2 - 1.f) + 1.00001f;
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

half3 SpecularTerm_BRDF2_Anisotropic2(half3 lightColor, half3 specColor, half nl, half3 worldNormal, half3 lightDir, half3 viewDir, half smoothness, half roughness, half3 worldTangent, half shift)
{
	half3 tangent = normalize(worldTangent + shift * worldNormal);
	float3 halfDir = Unity_SafeNormalize(float3(lightDir)+viewDir);
	half th = dot(tangent, halfDir);
	half sinTH = sqrt(1 - th * th);
	float nh = saturate(dot(worldNormal, halfDir));
	float lh = saturate(dot(lightDir, halfDir));

	half aspect = sqrt(1 - 0.9 * _Anisotropic);
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


half3 Hair_LightingFunc_Indirect(in HairShadingData shadingData, in LightingInput lightingInput, in DDIndirect indirect)
{
	half3 diffuse = shadingData.diffColor;

	half3 final = 0;
	final += diffuse * indirect.diffuse;

	return final;
}

half3 Hair_LightingFunc_Direct(in ShadingData_T shadingData, in LightingInput lightingInput, in DDLight light)
{
	half3 L = light.dir;
	half3 lightColor = light.color * light.atten;

	half3 diffuse = shadingData.diffColor;
	half3 tangent = shadingData.tangent;
	half smoothness = shadingData.smoothness;
	half smoothness2 = shadingData.smoothness2;
	half3 specular1 = shadingData.specColor1;
	half specularShift1 = shadingData.specularShift1;
	half3 specular2 = shadingData.specColor2;
	half specularShift2 = shadingData.specularShift2;

	half nv = saturate(dot(lightingInput.worldNormal, lightingInput.viewDir));
	half perceptualRoughness = 1.0h - smoothness;
	half roughness = perceptualRoughness * perceptualRoughness;
	half perceptualRoughness2 = 1.0h - smoothness2;
	half roughness2 = perceptualRoughness2 * perceptualRoughness2;

	half nl = dot(lightingInput.worldNormal, L);
	half3 diffTerm = DiffuseTerm_HalfLambert(lightColor, diffuse, nl);
	half3 specTerm1 = SpecularTerm_BRDF2_Anisotropic(lightColor, specular1, nl, lightingInput.worldNormal, L, lightingInput.viewDir, smoothness, roughness, tangent, specularShift1) * shadingData.specularScale;
	half3 specTerm2 = SpecularTerm_BRDF2_Anisotropic(lightColor, specular2, nl, lightingInput.worldNormal, L, lightingInput.viewDir, smoothness2, roughness2, tangent, specularShift2) * shadingData.specularScale;

	half3 final = 0;
	final += diffTerm + specTerm1 + specTerm2;

	return final;
}

#define _NORMALMAP

#ifdef UNITY_PASS_FORWARDBASE
	#define FUNC_GI Hair_GI
	#define FUNC_LIGHTING_INDIRECT Hair_LightingFunc_Indirect
	#define FUNC_LIGHTING_DIRECT Hair_LightingFunc_Direct
	#include "../Framework/DDShaderLighting.cginc"
#elif defined(UNITY_PASS_FORWARDADD)
	#define FUNC_LIGHTING_DIRECT Hair_LightingFunc_Direct
	#include "../Framework/DDShaderLightingAdd.cginc"
#elif defined(UNITY_PASS_SHADOWCASTER)
	#include "../Framework/DDShaderShadow.cginc"
#endif

#endif