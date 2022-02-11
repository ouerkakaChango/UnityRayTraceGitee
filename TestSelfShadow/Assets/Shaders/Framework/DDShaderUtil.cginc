#ifndef DD_SHADER_UTIL_INCLUDED
#define DD_SHADER_UTIL_INCLUDED

#define DD_PI            3.14159265359f
#define DD_TWO_PI        6.28318530718f

half3x3 TangentToWorldPerVertex(half3 normal, half3 tangent, half tangentSign)
{
	half sign = tangentSign * unity_WorldTransformParams.w;
	half3 binormal = cross(normal, tangent) * sign;
	return half3x3(tangent, binormal, normal);
}

float3 ScaleNormal(float4 packednormal, float bumpScale)
{
#if defined(UNITY_NO_DXT5nm)
	float3 normal = packednormal.xyz * 2 - 1;
#if (SHADER_TARGET >= 30)
	normal.xy *= bumpScale;
#endif
	return normal;
#else
	packednormal.x *= packednormal.w;

	float3 normal;
	normal.xy = (packednormal.xy * 2 - 1);
#if (SHADER_TARGET >= 30)
	normal.xy *= bumpScale;
#endif
	normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
	return normal;
#endif
}

float3 DD_UnpackNormal(float4 packednormal)
{
#if defined(UNITY_NO_DXT5nm)
	float3 normal = packednormal.xyz * 2 - 1;
	return normal;
#else
	packednormal.x *= packednormal.w;

	float3 normal;
	normal.xy = (packednormal.xy * 2 - 1);

	normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
	return normal;
#endif
}

float3 PerPixelWorldNormal(float3 normalTangent, float4 tangentToWorld[3])
{
	float3 tangent = tangentToWorld[0].xyz;
	float3 binormal = tangentToWorld[1].xyz;
	float3 normal = tangentToWorld[2].xyz;

#if UNITY_TANGENT_ORTHONORMALIZE
	normal = NormalizePerPixelNormal(normal);
	tangent = normalize(tangent - normal * dot(tangent, normal));
	float3 newB = cross(normal, tangent);
	binormal = newB * sign(dot(newB, binormal));
#endif

	return  tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z;
}

half4 GetTexColor(sampler2D Tex, float4 Tex_ST, float2 iuv)
{
	float2 fuv = iuv * Tex_ST.xy + Tex_ST.zw;
	return tex2D(Tex, fuv);
}

half4 convert(half3 params)
{
	return half4(params, 0);
}

half4 convert(half2 params)
{
	return half4(params, 0, 0);
}

half factor(half v, half _min, half _max)
{
    return (v - _min) / (_max - _min);
}

half2 factor(half2 v, half2 _min, half2 _max)
{
	return (v - _min) / (_max - _min);
}

float3 GetModelWorldPos()
{
    return float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]);
}

//y: GrabScreenPos; z: ScreenPos
float4 DDComputeScreenPos(float4 pos)
{
#if UNITY_UV_STARTS_AT_TOP
	float grabScreenScale = -1.0;
#else
	float grabScreenScale = 1.0;
#endif
	float screenScale = _ProjectionParams.x;

	float4 o = pos * 0.5f;
	o.xyz = float3(o.x, o.y * grabScreenScale, o.y * screenScale) + o.w;
	o.w = pos.w;
	return o;
}

#endif