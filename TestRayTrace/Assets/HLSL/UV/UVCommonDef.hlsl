#ifndef UVCOMMONDEF_HLSL
#define UVCOMMONDEF_HLSL
#include "../Transform/TransformCommonDef.hlsl"

bool InBound(float2 p, float2 bound, float tolerence = 0.00001f)
{
	if (bound.x < 0 || bound.y < 0)
	{
		return false; 
	}
	return lt(abs(p) , (bound + tolerence) );
}

float2 BoxedUV(float2 p, float2 bound)
{
	if (bound.x < 0 || bound.y < 0)
	{
		return 0;
	}
	return (p + bound) / bound * 0.5;
}

float2 BoxedUV(float3 p, float3 center, float3 bound, float3 rotEuler)
{
	p = p - center;
	p = InvRotByEuler(p, rotEuler);

	if (InBound(p.xy, bound.xy)&&abs(p.z)>=bound.z)
	{
		return BoxedUV(p.xy, bound.xy);
	}
	else if (InBound(p.xz, bound.xz) && abs(p.y) >= bound.y)
	{
		return BoxedUV(p.xz, bound.xz);
	}
	else if (InBound(p.yz, bound.yz) && abs(p.x) >= bound.x)
	{
		return BoxedUV(p.yz, bound.yz);
	}
	//never reach!
	return 0;
}

void BoxedTB(out float3 T, out float3 B, float3 p, float3 center, float3 bound, float3 rotEuler)
{
	p = p - center;
	p = InvRotByEuler(p, rotEuler);

	if (InBound(p.xy, bound.xy) && abs(p.z) >= bound.z)
	{
		T = RotByEuler(float3(1, 0, 0), rotEuler);
		B = RotByEuler(float3(0, 1, 0), rotEuler);
		return;
	}
	else if (InBound(p.xz, bound.xz) && abs(p.y) >= bound.y)
	{
		T = RotByEuler(float3(1, 0, 0), rotEuler);
		B = RotByEuler(float3(0, 0, 1), rotEuler);
		return;
	}
	else if (InBound(p.yz, bound.yz) && abs(p.x) >= bound.x)
	{
		T = RotByEuler(float3(0, 1, 0), rotEuler);
		B = RotByEuler(float3(0, 0, 1), rotEuler);
		return;
	}
	//never reach!
	T = float3(1, 0, 0);
	B = float3(0, 1, 0);
}

float2 RemapTarUV(float2 inUV, float2 uvmin, float2 uvmax)
{
	float u = (inUV.x - uvmin.x) / (uvmax.x - uvmin.x);
	float v = (inUV.y - uvmin.y) / (uvmax.y - uvmin.y);
	return float2(u, v);
}

float2 RemapSrcUV(float2 inUV, float2 uvmin, float2 uvmax)
{
	float u = inUV.x*(uvmax.x - uvmin.x) + uvmin.x;
	float v = inUV.y*(uvmax.y - uvmin.y) + uvmin.y;
	return float2(u, v);
}

float2 RemapUV(float2 inUV, float2 src_uvmin, float2 src_uvmax, float2 tar_uvmin, float2 tar_uvmax)
{
	float2 stand_uv = RemapTarUV(inUV, tar_uvmin, tar_uvmax);
	return RemapSrcUV(stand_uv, src_uvmin, src_uvmax);
}

float3 ApplyNTangent(float3 n_tan, float3 N, float3 T, float3 B, float3 intensity = 1)
{
	float3 n_world = normalize(n_tan.x*T + n_tan.y*B + n_tan.z*N);
	return normalize(lerp(N, n_world, intensity));
}

float3 SampleNormalMap(in Texture2D<float3> normalmap, float2 uv, float3 N, float3 T,float3 B, float3 intensity = 1)
{
	float3 n_tan = normalmap.SampleLevel(common_linear_repeat_sampler, uv, 0).rgb;
	n_tan = normalize(2 * n_tan - 1);
	return ApplyNTangent(n_tan, N, T, B, intensity);
}

float2 SimpleUVFromPos(float3 P, float3 N, float3 scale = 1)
{
	float2 uv = scale.y*P.xz;
	float2 uv2 = scale.z*P.xy;
	uv = lerp(uv2, uv, abs(N.y));
	float2 uv3 = scale.x*P.zy;
	uv = lerp(uv, uv3, abs(N.x));
	return uv;
}

#endif