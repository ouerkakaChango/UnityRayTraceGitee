#ifndef TERRAIN_SURFACE_INCLUDED
#define TERRAIN_SURFACE_INCLUDED
#define TEX2_COORD2
#define INPUT_NEED_VIEWDIR_TANGENTSPACE

#include "../Framework/DDShaderLightingCommon.cginc"
#include "../Predefine/DDPDSurfaceData.cginc"
#include "../Framework/DDShaderUtil.cginc"
#include "UnityCG.cginc"


sampler2D _BumpMap;
half _BumpScale;
UNITY_DECLARE_TEX2D_NOSAMPLER(_MetallicGlossMap);
half _Metallic;
half _GlossMapScale;
UNITY_DECLARE_TEX2D_NOSAMPLER(_MetallicGlossMap02);
UNITY_DECLARE_TEX2D_NOSAMPLER(_MetallicGlossMap03);
UNITY_DECLARE_TEX2D_NOSAMPLER(_MetallicGlossMap04);
UNITY_DECLARE_TEX2D_NOSAMPLER(_MetallicGlossMap05);

half4 _Emission;
half _LightPower;//�ƹ�ǿ��ϵ��
half4 _Color;
half _HeightBlendWeight;

UNITY_DECLARE_TEX2D(_Diffuse01);
uniform float4 _Diffuse01_ST;
UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalMap01);
uniform float4 _NormalMap01_ST;
uniform float _NormalScale01;

UNITY_DECLARE_TEX2D(_Diffuse02);
uniform float4 _Diffuse02_ST;
UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalMap02);
uniform float4 _NormalMap02_ST;
uniform float _NormalScale02;

UNITY_DECLARE_TEX2D(_Diffuse03);
uniform float4 _Diffuse03_ST;
UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalMap03);
uniform float4 _NormalMap03_ST;
uniform float _NormalScale03;

UNITY_DECLARE_TEX2D(_Diffuse04);
uniform float4 _Diffuse04_ST;
UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalMap04);
uniform float4 _NormalMap04_ST;
uniform float _NormalScale04;

uniform sampler2D _SplatAlpha;
uniform float4 _SplatAlpha_ST;

uniform float _UseUV02;

float _UseParallax;
float _Parallax;

struct TerrainSurfaceData
{
	half3 Albedo;
	half3 Normal;
	half3 Emission;
	half Metallic;
	half Smoothness;
	half Occlusion;
	half Alpha;
	half AddLightShadow;
};

inline void RestOutput(out TerrainSurfaceData IN)
{
	IN.Albedo = 0;
	IN.Normal = half3(0, 0, 1);
	IN.Emission = 0;
	IN.Metallic = 0;
	IN.Smoothness = 0;
	IN.Occlusion = 1;
	IN.Alpha = 1;
	IN.AddLightShadow = 1;
}

half2 Blend(half splat, half layer1Height, half layer2Height)
{
	half2 control = half2(1 - splat.x, splat.x);
	half2 height = half2(layer1Height, layer2Height);
	half2 blend = max(height, 0.001) * control;
	half ma = max(blend.x, blend.y);
	blend = max(blend - ma + _HeightBlendWeight, 0) * control;
	blend /= blend.x + blend.y;
	return blend;
}

half3 Blend(half2 splat, half layer1Height, half layer2Height, half layer3Height)
{
	half3 control = half3((1 - splat.x) * (1 - splat.y), splat.x * (1 - splat.y), splat.y);
	half3 height = half3(layer1Height, layer2Height, layer3Height);
	half3 blend = max(height, 0.001) * control;
	half ma = max(max(blend.x, blend.y), blend.z);
	blend = max(blend - ma + _HeightBlendWeight, 0) * control;
	blend /= blend.x + blend.y + blend.z;
	return blend;
}

half4 Blend(half3 splat, half layer1Height, half layer2Height, half layer3Height, half layer4Height)
{
	half4 control = half4((1 - splat.x) * (1 - splat.y) * (1 - splat.z), splat.x * (1 - splat.y) * (1 - splat.z), splat.y * (1 - splat.z), splat.z);
	return control;
	half4 height = half4(layer1Height, layer2Height, layer3Height, layer4Height);
	half4 blend = max(height, 0.001) * control;
	half ma = max(max(blend.x, blend.y), max(blend.z, blend.w));
	blend = max(blend - ma + _HeightBlendWeight, 0) * control;
	blend /= blend.x + blend.y + blend.z + blend.w;
	return blend;
}

#if defined(_DIFFUSENUM_SPLATR)
#define LAYER_BLEND_TYPE half2
#elif defined(_DIFFUSENUM_SPLATRG)
#define LAYER_BLEND_TYPE half3
#elif defined(_DIFFUSENUM_SPLATRGB)
#define LAYER_BLEND_TYPE half4
#else
#define LAYER_BLEND_TYPE half
#endif

half GetParallaxHeight(float2 uv, float4 splat, out LAYER_BLEND_TYPE blend)
{
	float2 uv1 = TRANSFORM_TEX(uv, _Diffuse01);
	float4 cold1 = UNITY_SAMPLE_TEX2D(_Diffuse01, uv1);
	float layer1Height = cold1.a;

#if _DIFFUSENUM_SPLATR
	float2 uv2 = TRANSFORM_TEX(uv, _Diffuse02);
	float4 cold2 = UNITY_SAMPLE_TEX2D(_Diffuse02, uv2);
	float layer2Height = cold2.a;
	blend = Blend(splat, layer1Height, layer2Height);
	return layer1Height * blend.x + layer2Height * blend.y;
#elif _DIFFUSENUM_SPLATRG
	float2 uv2 = TRANSFORM_TEX(uv, _Diffuse02);
	float4 cold2 = UNITY_SAMPLE_TEX2D(_Diffuse02, uv2);
	float layer2Height = cold2.a;

	float2 uv3 = TRANSFORM_TEX(uv, _Diffuse03);
	float4 cold3 = UNITY_SAMPLE_TEX2D(_Diffuse03, uv3);
	float layer3Height = cold3.a;

	blend = Blend(splat, layer1Height, layer2Height, layer3Height);

	return layer1Height * blend.x + layer2Height * blend.y + layer3Height * blend.z;
#elif _DIFFUSENUM_SPLATRGB
	float2 uv2 = TRANSFORM_TEX(uv, _Diffuse02);
	float4 cold2 = UNITY_SAMPLE_TEX2D(_Diffuse02, uv2);
	float layer2Height = cold2.a;

	float2 uv3 = TRANSFORM_TEX(uv, _Diffuse03);
	float4 cold3 = UNITY_SAMPLE_TEX2D(_Diffuse03, uv3);
	float layer3Height = cold3.a;

	float2 uv4 = TRANSFORM_TEX(uv, _Diffuse04);
	float4 cold4 = UNITY_SAMPLE_TEX2D(_Diffuse04, uv4);
	float layer4Height = cold4.a;

	blend = Blend(splat, layer1Height, layer2Height, layer3Height, layer4Height);

	return layer1Height * blend.x + layer2Height * blend.y + layer3Height * blend.z + layer4Height * blend.w;
#else
	blend = 1;
	return layer1Height;
#endif
}

float2 DD_ParallaxOffset1Step(float h, float height, float3 viewDir)
{
	h = h * height - height / 2.0;
	float3 v = normalize(viewDir);
	v.z += 0.42;
	return h * (v.xy / v.z);
}

float2 CalcParallaxOffset(float2 uv, float4 splat, half3 viewDir, out LAYER_BLEND_TYPE blend)
{
	float h = GetParallaxHeight(uv, splat, blend);
	float2 offset = DD_ParallaxOffset1Step(h, _Parallax, viewDir);
	return offset;
}

half3 GetAlbedo(float2 uv, float4 splat, float2 offset, LAYER_BLEND_TYPE pblend, bool usePBlend, out LAYER_BLEND_TYPE blend)
{
	float2 uv1 = TRANSFORM_TEX(uv, _Diffuse01) + offset;
	float4 cold1 = UNITY_SAMPLE_TEX2D(_Diffuse01, uv1);
	float layer1Height = cold1.a;

#if _DIFFUSENUM_SPLATR
	float2 uv2 = TRANSFORM_TEX(uv, _Diffuse02) + offset;
	float4 cold2 = UNITY_SAMPLE_TEX2D(_Diffuse02, uv2);
	float layer2Height = cold2.a;
	blend = usePBlend ? pblend : Blend(splat, layer1Height, layer2Height);
	return cold1 * blend.x + cold2 * blend.y;
#elif _DIFFUSENUM_SPLATRG
	float2 uv2 = TRANSFORM_TEX(uv, _Diffuse02) + offset;
	float4 cold2 = UNITY_SAMPLE_TEX2D(_Diffuse02, uv2);
	float layer2Height = cold2.a;

	float2 uv3 = TRANSFORM_TEX(uv, _Diffuse03) + offset;
	float4 cold3 = UNITY_SAMPLE_TEX2D(_Diffuse03, uv3);
	float layer3Height = cold3.a;

	blend = usePBlend ? pblend : Blend(splat, layer1Height, layer2Height, layer3Height);

	return cold1 * blend.x + cold2 * blend.y + cold3 * blend.z;
#elif _DIFFUSENUM_SPLATRGB
	float2 uv2 = TRANSFORM_TEX(uv, _Diffuse02) + offset;
	float4 cold2 = UNITY_SAMPLE_TEX2D(_Diffuse02, uv2);
	float layer2Height = cold2.a;

	float2 uv3 = TRANSFORM_TEX(uv, _Diffuse03) + offset;
	float4 cold3 = UNITY_SAMPLE_TEX2D(_Diffuse03, uv3);
	float layer3Height = cold3.a;

	float2 uv4 = TRANSFORM_TEX(uv, _Diffuse04) + offset;
	float4 cold4 = UNITY_SAMPLE_TEX2D(_Diffuse04, uv4);
	float layer4Height = cold4.a;

	blend = usePBlend ? pblend : Blend(splat, layer1Height, layer2Height, layer3Height, layer4Height);

	return cold1 * blend.x + cold2 * blend.y + cold3 * blend.z + cold4 * blend.w;
#else
	blend = 1;
	return cold1.rgb;
#endif
}

half3 GetNormal(float2 uv, LAYER_BLEND_TYPE blend, float2 offset)
{
	float2 uv1 = TRANSFORM_TEX(uv, _Diffuse01) + offset;
	half4 nor1 = UNITY_SAMPLE_TEX2D_SAMPLER(_NormalMap01, _Diffuse01, uv1);
	float bumpScale1 = _NormalScale01;

	half4 normal = half4(0, 0, 1, 1);
	float bumpScale = 1;

#if _DIFFUSENUM_SPLATR
	float2 uv2 = TRANSFORM_TEX(uv, _Diffuse02) + offset;

	half4 nor2 = UNITY_SAMPLE_TEX2D_SAMPLER(_NormalMap02, _Diffuse02, uv2);
	float bumpScale2 = _NormalScale02;

	normal = nor1 * blend.x + nor2 * blend.y;
	bumpScale = bumpScale1 * blend.x + bumpScale2 * blend.y;
#elif _DIFFUSENUM_SPLATRG
	float2 uv2 = TRANSFORM_TEX(uv, _Diffuse02) + offset;
	float2 uv3 = TRANSFORM_TEX(uv, _Diffuse03) + offset;

	half4 nor2 = UNITY_SAMPLE_TEX2D_SAMPLER(_NormalMap02, _Diffuse02, uv2);
	float bumpScale2 = _NormalScale02;

	half4 nor3 = UNITY_SAMPLE_TEX2D_SAMPLER(_NormalMap03, _Diffuse03, uv3);
	float bumpScale3 = _NormalScale03;

	normal = nor1 * blend.x + nor2 * blend.y + nor3 * blend.z;
	bumpScale = bumpScale1 * blend.x + bumpScale2 * blend.y + bumpScale3 * blend.z;
#elif _DIFFUSENUM_SPLATRGB
	float2 uv2 = TRANSFORM_TEX(uv, _Diffuse02) + offset;
	float2 uv3 = TRANSFORM_TEX(uv, _Diffuse03) + offset;
	float2 uv4 = TRANSFORM_TEX(uv, _Diffuse04) + offset;

	half4 nor2 = UNITY_SAMPLE_TEX2D_SAMPLER(_NormalMap02, _Diffuse02, uv2);
	float bumpScale2 = _NormalScale02;

	half4 nor3 = UNITY_SAMPLE_TEX2D_SAMPLER(_NormalMap03, _Diffuse03, uv3);
	float bumpScale3 = _NormalScale03;

	half4 nor4 = UNITY_SAMPLE_TEX2D_SAMPLER(_NormalMap04, _Diffuse04, uv4);
	float bumpScale4 = _NormalScale04;

	normal = nor1 * blend.x + nor2 * blend.y + nor3 * blend.z + nor4 * blend.w;
	bumpScale = bumpScale1 * blend.x + bumpScale2 * blend.y + bumpScale3 * blend.z + bumpScale4 * blend.w;

#else
	normal = nor1;
	bumpScale = bumpScale1;
#endif

	return ScaleNormal(normal, bumpScale);
}

half3 GetPBRMask(float2 uv, LAYER_BLEND_TYPE blend, float2 offset)
{
	half metallic = 0;
	half smoothness = 0;
	half emission = 0;

	float2 uv1 = TRANSFORM_TEX(uv, _Diffuse01) + offset;
	half4 mask1 = UNITY_SAMPLE_TEX2D_SAMPLER(_MetallicGlossMap, _Diffuse01, uv1);

#if _DIFFUSENUM_SPLATR
	float2 uv2 = TRANSFORM_TEX(uv, _Diffuse02) + offset;

	half4 mask2 = UNITY_SAMPLE_TEX2D_SAMPLER(_MetallicGlossMap02, _Diffuse02, uv2);

	metallic = mask1.r * blend.x + mask2.r * blend.y;
	smoothness = mask1.a * blend.x + mask2.a * blend.y;
	emission = mask1.b * blend.x + mask2.b * blend.y;
#elif _DIFFUSENUM_SPLATRG
	float2 uv2 = TRANSFORM_TEX(uv, _Diffuse02) + offset;
	float2 uv3 = TRANSFORM_TEX(uv, _Diffuse03) + offset;

	half4 mask2 = UNITY_SAMPLE_TEX2D_SAMPLER(_MetallicGlossMap02, _Diffuse02, uv2);
	half4 mask3 = UNITY_SAMPLE_TEX2D_SAMPLER(_MetallicGlossMap03, _Diffuse03, uv3);

	metallic = mask1.r * blend.x + mask2.r * blend.y + mask3.r * blend.z;
	smoothness = mask1.a * blend.x + mask2.a * blend.y + mask3.a * blend.z;
	emission = mask1.b * blend.x + mask2.b * blend.y + mask3.b * blend.z;
#elif _DIFFUSENUM_SPLATRGB
	float2 uv2 = TRANSFORM_TEX(uv, _Diffuse02) + offset;
	float2 uv3 = TRANSFORM_TEX(uv, _Diffuse03) + offset;
	float2 uv4 = TRANSFORM_TEX(uv, _Diffuse04) + offset;

	half4 mask2 = UNITY_SAMPLE_TEX2D_SAMPLER(_MetallicGlossMap02, _Diffuse02, uv2);
	half4 mask3 = UNITY_SAMPLE_TEX2D_SAMPLER(_MetallicGlossMap03, _Diffuse03, uv3);
	half4 mask4 = UNITY_SAMPLE_TEX2D_SAMPLER(_MetallicGlossMap04, _Diffuse04, uv4);

	metallic = mask1.r * blend.x + mask2.r * blend.y + mask3.r * blend.z /*+ mask4.r * blend.w*/;
	smoothness = mask1.a * blend.x + mask2.a * blend.y + mask3.a * blend.z /*+ mask4.a * blend.w*/;
	emission = mask1.b * blend.x + mask2.b * blend.y + mask3.b * blend.z /*+ mask4.b * blend.w*/;
#else
	metallic = mask1.r;
	smoothness = mask1.a;
	emission = mask1.b;
#endif

	return half3(metallic, smoothness, emission);
}

void surf(Input IN, inout TerrainSurfaceData o)
{
	half3 col = 0;
	half3 normal = 0;
	half3 pbrmask = 0;

	float2 splatUV = _UseUV02 == 0 ? IN.uv : IN.uv2;
	float4 tex2DNode4 = GetTexColor(_SplatAlpha, _SplatAlpha_ST, splatUV);

#ifdef _PARALLAX
	bool useParallax = _UseParallax != 0;
	LAYER_BLEND_TYPE pblend;
	float2 offset = useParallax ? CalcParallaxOffset(IN.uv, tex2DNode4, IN.viewDirTS, pblend) : 0;
#else
	bool useParallax = false;
	LAYER_BLEND_TYPE pblend = 0;
	float2 offset = 0;
#endif
	float2 uv = IN.uv;

	LAYER_BLEND_TYPE blend;
	col = GetAlbedo(uv, tex2DNode4, offset, pblend, useParallax, blend);
	normal = GetNormal(uv, blend, offset);
	pbrmask = GetPBRMask(uv, blend, offset);

	o.Albedo = col * _Color.rgb * 2.0h;

	o.Normal = normal;

	o.Metallic = pbrmask.x * _Metallic;
	o.Smoothness = pbrmask.y * _GlossMapScale;
	o.Emission = pbrmask.z * _Emission.rgb * o.Albedo;

	o.AddLightShadow = tex2DNode4.a;
}

#define TEX1_UVST _SplatAlpha_ST
#define SurfaceData_T TerrainSurfaceData

#define USE_UNITY_LIGHT_MODEL
#define FUNC_SURF surf

#include "UnityLightModel.cginc"

#endif