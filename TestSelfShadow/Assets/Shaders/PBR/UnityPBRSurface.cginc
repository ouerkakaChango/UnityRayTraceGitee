#ifndef UNITY_PBR_SURFACE_INCLUDED
#define UNITY_PBR_SURFACE_INCLUDED

#define TEX1_UVST _MainTex_ST
#ifdef _USE_DETAIL_ON
#define TEX2_UVST _DetailAlbedoMap_ST
#endif

#include "../Framework/DDShaderLightingCommon.cginc"
#include "../Predefine/DDPDSurfaceData.cginc"
#include "../Framework/DDShaderUtil.cginc"
#include "UnityCG.cginc"
#include "UnityStandardUtils.cginc"

sampler2D _MainTex;
float4 _MainTex_ST;
half4 _Color;

sampler2D _BumpMap;
half _BumpScale;
sampler2D _MetallicGlossMap;
half _Metallic;
half _Glossiness;
half _OcclusionStrength;
half4 _EmissionColor;

sampler2D _DetailMask;
sampler2D _DetailAlbedoMap;
float4 _DetailAlbedoMap_ST;
sampler2D _DetailNormalMap;
half _DetailNormalMapScale;

void surf(Input IN, inout CommonSurfaceData o)
{
	half4 col = tex2D(_MainTex, IN.uv);
#ifdef UNITY_COLORSPACE_GAMMA
	col.rgb = GammaToLinearSpace(col.rgb);
#endif
	half3 albedo = col.rgb * _Color.rgb;

#if _USE_DETAIL_ON
	half detailMask = tex2D(_DetailMask, IN.uv).a;
	half3 detailAlbedo = tex2D(_DetailAlbedoMap, IN.uv2).rgb;
	albedo *= LerpWhiteTo(detailAlbedo * unity_ColorSpaceDouble.rgb, detailMask);
#endif

	//!!!
	albedo *= 1.0;

	o.Albedo = albedo;
	o.Alpha = col.a * _Color.a;
	half3 normal = ScaleNormal(tex2D(_BumpMap, IN.uv), _BumpScale);

#if defined(_USE_DETAIL_ON) && defined(UNITY_ENABLE_DETAIL_NORMALMAP)
	half3 detailNormal = ScaleNormal(tex2D(_DetailNormalMap, IN.uv2), _DetailNormalMapScale);
	normal = lerp(normal, BlendNormals(normal, detailNormal), detailMask);
#endif
	o.Normal = normal;

	half4 mask = tex2D(_MetallicGlossMap, IN.uv);
	o.Metallic = mask.r * _Metallic;
	o.Smoothness = mask.b * _Glossiness;
	o.Occlusion = LerpOneTo(mask.g, _OcclusionStrength);
	o.Emission = mask.a * _EmissionColor.rgb * o.Albedo;
}

#if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
#define KEEP_ALPHA
#endif

#define SurfaceData_T CommonSurfaceData
#define FUNC_SURF surf
#define USE_UNITY_LIGHT_MODEL

#include "UnityLightModel.cginc"

#endif