#ifndef DD_SHADER_LIGHTING_COMMON_INCLUDED
#define DD_SHADER_LIGHTING_COMMON_INCLUDED

#include "UnityInstancing.cginc"

struct a2v
{
	float4 vertex : POSITION;
	float4 tangent : TANGENT;
	half3 normal : NORMAL;
	half4 texcoord : TEXCOORD0;
	half4 texcoord1 : TEXCOORD1;
	half4 texcoord2 : TEXCOORD2;
	half4 texcoord3 : TEXCOORD3;
	half4 color : COLOR;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct DDLight
{
	half3 color;
	half atten;
	half3 dir;
	half lightAtten;
};

inline void ResetLight(out DDLight outLight)
{
	outLight.color = 0;
	outLight.atten = 0;
	outLight.dir = half3(0, 1, 0);
	outLight.lightAtten = 0;
}

struct DDGIInput
{
	DDLight light;
	float3 worldPos;
	half3 viewDir;
	half3 normalWorld;
	half2 lmapUV;
	half3 ambient;

#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION) || defined(UNITY_ENABLE_REFLECTION_BUFFERS)
	float4 boxMin[2];
#endif
#ifdef UNITY_SPECCUBE_BOX_PROJECTION
	float4 boxMax[2];
	float4 probePosition[2];
#endif
	// HDR cubemap properties, use to decompress HDR texture
	float4 probeHDR[2];
};

struct DDIndirect
{
	half3 diffuse;
	half3 specular;
};

struct DDGI
{
	DDLight light;
	DDIndirect indirect;
};

inline void ResetGI(out DDGI outGI)
{
	ResetLight(outGI.light);
	outGI.indirect.diffuse = 0;
	outGI.indirect.specular = 0;
}

struct LightingInput
{
	half3 viewDir;
	float3 worldPos;
	half3 worldNormal;
	float3 worldTangent;
#ifdef LIGHTING_INPUT_NEED_UV2
	float2 uv2;
#endif
#ifdef LIGHTING_INPUT_NEED_SCREEN_UV
	float2 screenUV;
	float2 grabScreenUV;
#endif
};

struct Input
{
	half2 uv;
#if defined(TEX2_UVST) || defined(TEX2_COORD2)
	half2 uv2;
#endif
#if defined(TEX3_UVST) || defined(TEX3_COORD3)
	half2 uv3;
#endif
#if defined(TEX4_UVST) || defined(TEX4_COORD4)
	half2 uv4;
#endif
#ifdef NEED_VERTEX_COLOR
	half4 color;
#endif
#ifdef INPUT_NEED_WORLD_POS
	float3 worldPos;
#endif
#ifdef INPUT_NEED_WORLD_VERTEX_NORMAL
	float3 worldVertexNormal;
#endif
#ifdef INPUT_NEED_WORLD_TANGENT
	float3 worldTangent;
#endif
#ifdef INPUT_NEED_VIEWDIR_TANGENTSPACE
	half3 viewDirTS;
#endif
#ifdef INPUT_NEED_SCREEN_UV
	float2 screenUV;
	float2 grabScreenUV;
#endif
#ifdef INPUT_NEED_DEPTH
	float depth;
#endif
};

#endif