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
		T = InvRotByEuler(float3(1, 0, 0), rotEuler);
		B = InvRotByEuler(float3(0, 1, 0), rotEuler);
	}
	else if (InBound(p.xz, bound.xz) && abs(p.y) >= bound.y)
	{
		T = InvRotByEuler(float3(1, 0, 0), rotEuler);
		B = InvRotByEuler(float3(0, 0, 1), rotEuler);
	}
	else if (InBound(p.yz, bound.yz) && abs(p.x) >= bound.x)
	{
		T = InvRotByEuler(float3(0, 1, 0), rotEuler);
		B = InvRotByEuler(float3(0, 0, 1), rotEuler);
	}
	//never reach!
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
#endif