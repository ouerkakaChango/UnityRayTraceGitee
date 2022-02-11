#ifndef DD_SHADER_SHADOW_INCLUDED
#define DD_SHADER_SHADOW_INCLUDED

#include "DDShaderFrameworkConfig.cginc"
#include "UnityCG.cginc"
#include "DDShaderVariables.cginc"

#if defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
	#define SHADOW_USE_ALPHA
#endif

struct v2f_shadow {
	V2F_SHADOW_CASTER;
#ifdef SHADOW_USE_ALPHA
	DD_COLOR
	DD_UV_COORDS(0)
	DD_UV_COORDS_EX(9)
#ifdef _FRAMEWORK_NEED_TANGENT_TO_WORLD
	float4 tangentToWorld[3] : TEXCOORD2;
#endif
	DD_SCREEN_UV_COORDS(8)
#endif
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

v2f_shadow vert_shadow(a2v v)
{
	v2f_shadow o = (v2f_shadow)0;
	UNITY_SETUP_INSTANCE_ID(v);

#ifdef FUNC_VERTEX
	FUNC_VERTEX(v);
#endif

#ifdef SHADOW_USE_ALPHA
#ifdef NEED_VERTEX_COLOR
	o.color = v.color;
#endif
	SET_UV(o.uv, v);
	SET_UV_EX(o, v);

#ifdef _FRAMEWORK_NEED_TANGENT_TO_WORLD
	float3 posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
	float3 normal = UnityObjectToWorldNormal(v.normal);
	float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
	float3x3 tangentToWorld = TangentToWorldPerVertex(normal, tangentWorld.xyz, tangentWorld.w);
	o.tangentToWorld[0].xyz = tangentToWorld[0];
	o.tangentToWorld[1].xyz = tangentToWorld[1];
	o.tangentToWorld[2].xyz = tangentToWorld[2];

	o.tangentToWorld[0].w = posWorld.x;
	o.tangentToWorld[1].w = posWorld.y;
	o.tangentToWorld[2].w = posWorld.z;
#endif
#ifdef NEED_SCREEN_UV
	o.screenUV = DDComputeScreenPos(o.pos);
#endif
#endif
	TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
	return o;
}

float4 frag_shadow(v2f_shadow i) : COLOR
{
#ifdef SHADOW_USE_ALPHA
#ifdef _FRAMEWORK_NEED_TANGENT_TO_WORLD
	float3 worldPos = float3(i.tangentToWorld[0].w, i.tangentToWorld[1].w, i.tangentToWorld[2].w);
	float3 worldVertexNormal = normalize(i.tangentToWorld[2].xyz);
	float3 worldBinormal = normalize(i.tangentToWorld[1].xyz);
	float3 worldTangent = normalize(i.tangentToWorld[0].xyz);

	half3 viewVec = UnityWorldSpaceViewDir(worldPos);
	half3 viewDir = normalize(viewVec);
#endif
	DD_INIT_INPUT(input, i);

	SurfaceData_T IN = (SurfaceData_T)0;
	RestOutput(IN);
	FUNC_SURF(input, IN);

	ShadingData_T shadingData = (ShadingData_T)0;
	FUNC_SHADING_PREPARE(IN, shadingData);

	clip(shadingData.alpha - (_VAR_CUTOFF));
#endif

	SHADOW_CASTER_FRAGMENT(i)
}

#endif