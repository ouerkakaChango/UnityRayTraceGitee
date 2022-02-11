#ifndef CARTOON_SURFACE_INCLUDED
#define CARTOON_SURFACE_INCLUDED

#define TEX1_UVST _MainTex_ST

#include "../Framework/DDShaderLightingCommon.cginc"
#include "../Predefine/DDPDSurfaceData.cginc"
#include "../Framework/DDShaderUtil.cginc"
#include "UnityCG.cginc"
#include "UnityStandardUtils.cginc"

sampler2D _MainTex;
half4 _MainTex_ST;
half4 _Color;

sampler2D _BumpMap;
half _BumpScale;
sampler2D _MetallicGlossMap;
half _Metallic;
half _Glossiness;
half _OcclusionStrength;
half4 _Emission;

void surf(Input IN, inout CommonSurfaceData o)
{
	half4 col = tex2D(_MainTex, IN.uv);
#ifdef UNITY_COLORSPACE_GAMMA
	col.rgb = GammaToLinearSpace(col.rgb);
#endif

	half3 albedo = col.rgb * _Color.rgb;

	o.Albedo = albedo;
	o.Alpha = col.a * _Color.a;
	half3 normal = ScaleNormal(tex2D(_BumpMap, IN.uv), _BumpScale);
	o.Normal = normal;

	half4 mask = tex2D(_MetallicGlossMap, IN.uv);
	o.Metallic = mask.r * _Metallic;
	o.Smoothness = mask.g * _Glossiness;
	o.Occlusion = LerpOneTo(mask.b, _OcclusionStrength);
	o.Emission = mask.a * _Emission.rgb * o.Albedo;
}

#define SurfaceData_T CommonSurfaceData
#define FUNC_SURF surf
#define USE_CARTOON_LIGHT_MODEL

#if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
#define KEEP_ALPHA
#endif

#include "CartoonLightModel.cginc"

#endif