#ifndef SKIN_LIGHT_MODEL_2_INCLUDED
#define SKIN_LIGHT_MODEL_2_INCLUDED

#include "UnityStandardUtils.cginc"

#define TEX1_UVST _MainTex_ST
#define INPUT_NEED_WORLD_POS
#define INPUT_NEED_WORLD_VERTEX_NORMAL
#include "../Framework/DDShaderLightingCommon.cginc"
#include "../Framework/DDShaderUtil.cginc"

sampler2D _MainTex;
half4 _MainTex_ST;
half4 _Color;

sampler2D _BumpMap;

sampler2D _MaskTex;
half _Smoothness;
half _SpecularScale;
half _CurvatureFactor;

struct SkinSurfaceData
{
	half3 Albedo;
	half3 Normal;
	half Smoothness;
	half Occlusion;
	half Curvature;
	half3 Emission;
	half SpecularScale;
};

inline void RestOutput(out SkinSurfaceData IN)
{
	IN.Albedo = 0;
	IN.Normal = half3(0, 0, 1);
	IN.Smoothness = 0;
	IN.Occlusion = 1;
	IN.SpecularScale = 1;
	IN.Emission = 0;
	IN.Curvature = 0.5;
}

void surf(Input IN, inout SkinSurfaceData o)
{
	half4 col = tex2D(_MainTex, IN.uv);
	half3 albedo = col.rgb * _Color.rgb;
#ifdef UNITY_COLORSPACE_GAMMA
	albedo = GammaToLinearSpace(albedo);
#endif
	o.Albedo = albedo;
	o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv));
	half4 mask = tex2D(_MaskTex, IN.uv);
	o.Smoothness = mask.r * _Smoothness;
	o.SpecularScale = mask.g * _SpecularScale;
#if defined(CURVE_REALTIME)
	o.Curvature = saturate(_CurvatureFactor * 0.01 * (length(fwidth(IN.worldVertexNormal)) / length(fwidth(IN.worldPos))));
#elif defined(CURVE_TEX)
	o.Curvature = mask.b;
#endif
	o.Occlusion = mask.a;
}

#define SurfaceData_T SkinSurfaceData
#define FUNC_SURF surf

struct SkinShadingData
{
	half3 diffColor;
	half3 specColor;
	half smoothness;
	half curvature;
	half oneMinusReflectivity;
	half specularScale;
	half alpha;
};

#define ShadingData_T SkinShadingData

inline void ShadingPrepare_Skin(SkinSurfaceData IN, out SkinShadingData shadingData)
{
	shadingData.specColor = 0.028f;
	shadingData.diffColor = EnergyConservationBetweenDiffuseAndSpecular(IN.Albedo, shadingData.specColor, shadingData.oneMinusReflectivity);
	shadingData.smoothness = IN.Smoothness;
	shadingData.curvature = IN.Curvature;
	shadingData.specularScale = IN.SpecularScale;
	shadingData.alpha = 1;
}

#define FUNC_SHADING_PREPARE ShadingPrepare_Skin

sampler2D _SkinLUT;

#define USE_UNITYGI
#define USE_CUSTOM_FUNC_GI
#include "../Predefine/DDPDShaderGI.cginc"

void Skin_GI(in SurfaceData_T s, in DDGIInput input, out DDGI gi)
{
	GI_IndirectDiffuse(1, input, gi);
#ifndef NO_NEED_INDIRECT_SPECULAR
	gi.indirect.specular = GI_IndirectSpecular(s.Occlusion, s.Smoothness, input);
#endif
}

#include "../Predefine/DDPDBRDF.cginc"

half3 DiffuseTerm_Skin(half3 lightColor, half3 diffColor, half nl, half curvature)
{
	half wrappedNdL = (nl * 0.5 + 0.5);
	half3 diffFactor = tex2D(_SkinLUT, float2(wrappedNdL, curvature));
	return diffColor * diffFactor * lightColor;
}

half3 DD_Skin_LightingFunc_Indirect(in SkinShadingData shadingData, in LightingInput lightingInput, in DDIndirect indirect)
{
	half3 diffuse = shadingData.diffColor;
	half3 specular = shadingData.specColor;
	half smoothness = shadingData.smoothness;
	half oneMinusReflectivity = shadingData.oneMinusReflectivity;
	half specularScale = shadingData.specularScale;

	half nv = saturate(dot(lightingInput.worldNormal, lightingInput.viewDir));
	half perceptualRoughness = 1.0h - smoothness;
	half roughness = perceptualRoughness * perceptualRoughness;

	half3 indirectSpecularTerm = IndirectSpecularTerm_BRDF2(indirect.specular, specular, nv, smoothness, roughness, perceptualRoughness, oneMinusReflectivity) * specularScale;

	half3 final = 0;
	final += diffuse * indirect.diffuse;
#ifndef NO_NEED_INDIRECT_SPECULAR
	final += indirectSpecularTerm;
#endif

	return final;
}

half3 DD_Skin_LightingFunc_Direct(in ShadingData_T shadingData, in LightingInput lightingInput, in DDLight light)
{
	half3 L = light.dir;
	half3 lightColor = light.color * light.atten;

	half3 diffuse = shadingData.diffColor;
	half3 specular = shadingData.specColor;
	half smoothness = shadingData.smoothness;
	half curvature = shadingData.curvature;
	half oneMinusReflectivity = shadingData.oneMinusReflectivity;
	half specularScale = shadingData.specularScale;

	half perceptualRoughness = 1.0h - smoothness;
	half roughness = perceptualRoughness * perceptualRoughness;

	half nl = dot(lightingInput.worldNormal, L);
	half3 diffTerm = DiffuseTerm_Skin(lightColor, diffuse, nl, curvature);
	half3 specTerm = SpecularTerm_PBR_BRDF2(lightColor, specular, nl, lightingInput.worldNormal, L, lightingInput.viewDir, smoothness, roughness) * specularScale;

	half3 final = 0;
	final += diffTerm + specTerm;

	return final;
}

#define _NORMALMAP

#ifdef UNITY_PASS_FORWARDBASE
	#define FUNC_GI Skin_GI
	#define FUNC_LIGHTING_INDIRECT DD_Skin_LightingFunc_Indirect
	#define FUNC_LIGHTING_DIRECT DD_Skin_LightingFunc_Direct
	#include "../Framework/DDShaderLighting.cginc"
#elif defined(UNITY_PASS_FORWARDADD)
	#define FUNC_LIGHTING_DIRECT DD_Skin_LightingFunc_Direct
	#include "../Framework/DDShaderLightingAdd.cginc"
#elif defined(UNITY_PASS_SHADOWCASTER)
	#include "../Framework/DDShaderShadow.cginc"
#endif

#endif