#ifndef DD_SHADER_LIGHTING_INCLUDED
#define DD_SHADER_LIGHTING_INCLUDED

#include "DDShaderFrameworkConfig.cginc"
#include "DDShaderVariables.cginc"
#include "DDShaderUtil.cginc"
#include "DDShaderLightUtil.cginc"

struct v2f
{
	float4 pos : SV_POSITION;
    DD_COLOR
	DD_UV_COORDS(0)
	DD_UV_COORDS_EX(9)
	DD_V2F_INDIRECT(1)
	UNITY_FOG_COORDS(2)
	UNITY_LIGHTING_COORDS(3, 4)

	float4 tangentToWorld[3] : TEXCOORD5;

	DD_SCREEN_UV_COORDS(8)

	UNITY_VERTEX_INPUT_INSTANCE_ID
};

v2f vert(a2v v)
{
	v2f o = (v2f)0;
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_TRANSFER_INSTANCE_ID(v, o);

	FUNC_VERTEX(v);
#ifdef NEED_VERTEX_COLOR
	o.color = v.color;
#endif
	SET_UV(o.uv, v);
	SET_UV_EX(o, v);
	float3 posWorld = mul(unity_ObjectToWorld, v.vertex);
	o.pos = UnityObjectToClipPos(v.vertex);
	float3 normal = UnityObjectToWorldNormal(v.normal);

#ifdef USE_GI
	o.indirect = VERTEX_GI(v.texcoord1, posWorld, normal);
#endif

	float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
	float3x3 tangentToWorld = TangentToWorldPerVertex(normal, tangentWorld.xyz, tangentWorld.w);
	o.tangentToWorld[0].xyz = tangentToWorld[0];
	o.tangentToWorld[1].xyz = tangentToWorld[1];
	o.tangentToWorld[2].xyz = tangentToWorld[2];

	o.tangentToWorld[0].w = posWorld.x;
	o.tangentToWorld[1].w = posWorld.y;
	o.tangentToWorld[2].w = posWorld.z;

#ifdef NEED_SCREEN_UV
	o.screenUV = DDComputeScreenPos(o.pos);
#endif

	UNITY_TRANSFER_LIGHTING(o, v.texcoord1);
	UNITY_TRANSFER_FOG(o, o.pos);
	return o;
}

inline DDGI FragmentGI(in DDLight mainlight, in v2f i, in float3 worldPos, in half3 viewDir, in SurfaceData_T IN)
{
	DDGI gi;
#ifdef USE_GI
	half4 i_ambientOrLightmapUV = convert(i.indirect);
	DDGIInput giInput = FUNC_GIINPUT(mainlight, worldPos, viewDir, IN.Normal, i_ambientOrLightmapUV);
	FUNC_GI(IN, giInput, gi);
#else
	ResetGI(gi);
	gi.light = mainlight;
#endif
	return gi;
}

half4 frag(v2f i
#ifdef CARE_FACING
	, fixed facing : VFACE
#endif
) : SV_Target
{
	UNITY_SETUP_INSTANCE_ID(i);

#if defined(CARE_FACING) && defined(BACK_FACE_REVERT)
	if (facing < 0)
		i.tangentToWorld[2].z = -i.tangentToWorld[2].z;
#endif

	float3 worldPos = float3(i.tangentToWorld[0].w, i.tangentToWorld[1].w, i.tangentToWorld[2].w);
	float3 worldVertexNormal = normalize(i.tangentToWorld[2].xyz);
	float3 worldBinormal = normalize(i.tangentToWorld[1].xyz);
	float3 worldTangent = normalize(i.tangentToWorld[0].xyz);

	float3 viewVec = UnityWorldSpaceViewDir(worldPos);
	half3 viewDir = normalize(viewVec);

	DD_INIT_INPUT(input, i);

	SurfaceData_T IN = (SurfaceData_T)0;
	RestOutput(IN);
	FUNC_SURF(input, IN);
#ifdef _ALPHATEST_ON
	clip(IN.Alpha - (_VAR_CUTOFF));
#endif

#ifdef _NORMALMAP
	float3 N = normalize(PerPixelWorldNormal(IN.Normal, i.tangentToWorld));
#else
	float3 N = worldVertexNormal;
#endif
	IN.Normal = N;

	UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
	DDLight mainlight = GetLight(atten, worldPos);

	DDGI gi = FragmentGI(mainlight, i, worldPos, viewDir, IN);

	ShadingData_T shadingData = (ShadingData_T)0;
	FUNC_SHADING_PREPARE(IN, shadingData);

	DD_INIT_LIGHTING_INPUT(lightingInput);
	half3 final = FUNC_LIGHTING_INDIRECT(shadingData, lightingInput, gi.indirect);
	final += FUNC_LIGHTING_DIRECT(shadingData, lightingInput, gi.light);
	final += IN.Emission;

	UNITY_APPLY_FOG(i.fogCoord, final);

	FUNC_FINAL(final, worldPos);

	half alpha = 1;
#ifdef KEEP_ALPHA
	alpha = shadingData.alpha;
#endif

#ifdef UNITY_COLORSPACE_GAMMA
	final = LinearToGammaSpace(final);
#endif

	return half4(final, alpha);
}

#endif