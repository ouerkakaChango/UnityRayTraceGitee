#ifndef DD_SHADER_META_INCLUDED
#define DD_SHADER_META_INCLUDED

#include "DDShaderFrameworkConfig.cginc"
#include "UnityCG.cginc"
#include "DDShaderVariables.cginc"
#include "UnityMetaPass.cginc"

struct v2f_meta
{
    float4 pos      : SV_POSITION;
    DD_COLOR
    DD_UV_COORDS(0)
	DD_UV_COORDS_EX(9)
#ifdef EDITOR_VISUALIZATION
    float2 vizUV        : TEXCOORD1;
    float4 lightCoord   : TEXCOORD2;
#endif

    float4 tangentToWorld[3] : TEXCOORD3;
    DD_SCREEN_UV_COORDS(8)
};

v2f_meta vert_meta (a2v v)
{
    v2f_meta o = (v2f_meta)0;
    o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);
    SET_UV(o.uv, v);
    SET_UV_EX(o, v);

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

#ifdef NEED_SCREEN_UV
    o.screenUV = DDComputeScreenPos(o.pos);
#endif

#ifdef EDITOR_VISUALIZATION
    o.vizUV = 0;
    o.lightCoord = 0;
    if (unity_VisualizationMode == EDITORVIZ_TEXTURE)
        o.vizUV = UnityMetaVizUV(unity_EditorViz_UVIndex, v.texcoord.xy, v.texcoord1.xy, v.texcoord2.xy, unity_EditorViz_Texture_ST);
    else if (unity_VisualizationMode == EDITORVIZ_SHOWLIGHTMASK)
    {
        o.vizUV = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        o.lightCoord = mul(unity_EditorViz_WorldToLight, mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)));
    }
#endif
    return o;
}

half DD_SmoothnessToRoughness(half smoothness)
{
    return (1 - smoothness) * (1 - smoothness);
}

half3 DDUnityLightmappingAlbedo(half3 diffuse, half3 specular, half smoothness)
{
    half roughness = DD_SmoothnessToRoughness(smoothness);
    half3 res = diffuse;
    res += specular * roughness * 0.5;
    return res;
}

float4 frag_meta (v2f_meta i) : SV_Target
{
    float3 worldPos = float3(i.tangentToWorld[0].w, i.tangentToWorld[1].w, i.tangentToWorld[2].w);
    float3 worldVertexNormal = normalize(i.tangentToWorld[2].xyz);
    float3 worldBinormal = normalize(i.tangentToWorld[1].xyz);
    float3 worldTangent = normalize(i.tangentToWorld[0].xyz);

    half3 viewVec = UnityWorldSpaceViewDir(worldPos);
    half3 viewDir = normalize(viewVec);

    DD_INIT_INPUT(input, i);

    SurfaceData_T IN = (SurfaceData_T)0;
	RestOutput(IN);
	FUNC_SURF(input, IN);

    ShadingData_T shadingData = (ShadingData_T)0;
    FUNC_SHADING_PREPARE(IN, shadingData);

    UnityMetaInput o;
    UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);
#ifdef EDITOR_VISUALIZATION
    o.Albedo = shadingData.diffColor;
    o.VizUV = i.vizUV;
    o.LightCoord = i.lightCoord;
#else
    o.Albedo = DDUnityLightmappingAlbedo(shadingData.diffColor, shadingData.specColor, shadingData.smoothness);
#endif

    o.SpecularColor = shadingData.specColor;
    o.Emission = IN.Emission;

    return UnityMetaFragment(o);
}


#endif