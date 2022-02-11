#ifndef HAIR_LIGHT_MODEL_INCLUDED
#define HAIR_LIGHT_MODEL_INCLUDED

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
half _SpecularShininess1;
half _ShiftValue1;
half4 _SpecularColor1;

half _SpecularShininess2;
half _ShiftValue2;
half4 _SpecularColor2;

struct HairSurfaceData
{
	half3 Diffuse;
	half3 Normal;
	half3 Tangent;
	half SpecluarScale;
	half SpecularShift1;
	half SpecularShift2;
	half3 Emission;
};

inline void RestOutput(out HairSurfaceData IN)
{
	IN.Diffuse = 0;
	IN.Normal = half3(0, 0, 1);
	IN.Tangent = half3(1, 0, 0);
	IN.SpecluarScale = 1;
	IN.SpecularShift1 = 0;
	IN.SpecularShift2 = 0;
	IN.Emission = 0;
}

void surf(Input IN, inout HairSurfaceData o)
{
	half4 col = tex2D(_MainTex, IN.uv);
	half3 diffuse = col.rgb * _Color.rgb;
#ifdef UNITY_COLORSPACE_GAMMA
	diffuse = GammaToLinearSpace(diffuse);
#endif
	o.Diffuse = diffuse;
	o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv));
	o.Tangent = IN.worldTangent;
	half4 mask = tex2D(_HairMask, IN.uv);
	o.SpecluarScale = mask.r;
	o.SpecularShift1 = mask.g - 0.5 + _ShiftValue1;
	o.SpecularShift2 = mask.g - 0.5 + _ShiftValue2;
}

#define SurfaceData_T HairSurfaceData
#define FUNC_SURF surf

struct HairShadingData
{
	half3 diffColor;
	half3 specColor1, specColor2;
	half3 tangent;
	half shininess1, shininess2;
	half specularShift1, specularShift2;
	half alpha;
};

#define ShadingData_T HairShadingData
#include "../Predefine/DDPDUtils.cginc"

inline void ShadingPrepare_Hair(HairSurfaceData IN, out HairShadingData shadingData)
{
	shadingData.diffColor = IN.Diffuse;
	shadingData.tangent = IN.Tangent;

	shadingData.specColor1 = _SpecularColor1 * IN.SpecluarScale;
	shadingData.shininess1 = _SpecularShininess1;
	shadingData.specularShift1 = IN.SpecularShift1;

	shadingData.specColor2 = _SpecularColor2 * IN.SpecluarScale;
	shadingData.shininess2 = _SpecularShininess2;
	shadingData.specularShift2 = IN.SpecularShift2;
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

	half3 specular1 = shadingData.specColor1;
	half specularShift1 = shadingData.specularShift1;
	half shininess1 = shadingData.shininess1;

	half3 specular2 = shadingData.specColor2;
	half specularShift2 = shadingData.specularShift2;
	half shininess2 = shadingData.shininess2;

	half nl = dot(lightingInput.worldNormal, L);
	half3 diffTerm = DiffuseTerm_HalfLambert(lightColor, diffuse, nl);
	half3 specTerm1 = SpecularTerm_KajiyaKay(lightColor, specular1, nl, tangent, lightingInput.worldNormal, specularShift1, lightingInput.viewDir, L, shininess1);
	half3 specTerm2 = SpecularTerm_KajiyaKay(lightColor, specular2, nl, tangent, lightingInput.worldNormal, specularShift2, lightingInput.viewDir, L, shininess2);

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