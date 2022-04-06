#ifndef SDFCOMMONDEF_HLSL
#define SDFCOMMONDEF_HLSL

#define Fast_MAXSDFTraceCount 256
#define Fast_SDFTraceThre 0.001

#include "../Transform/TransformCommonDef.hlsl"

float SDFBox(float3 p, float3 center, float3 bound)
{
	float3 q = abs(p - center) - bound;
	return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float SDFBoxTransform(float3 p, float3 bound,
	float3 center, float3 rotEuler=0, float3 scale=1)
{
	p = p - center;
	p = RotByEuler(p,-rotEuler);
	float3 q = abs(p) - bound * scale;
	return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float SDFSphere(float3 p, float3 center, float radius)
{
	return length(p - center) - radius;
}

float3 SDFSphereNormal(float3 p, float3 center)
{
	return normalize(p - center);
}

float SDFShearXBoxTransform(float3 p, float3 bound,
	float shy, float shz,
	float3 center, float3 rotEuler = 0, float3 scale = 1)
{
	bound *= scale;
	float3 vec = p - center;
	float3 shp = ShearX(vec, -shy, -shz);
	p = RotByEuler(shp, rotEuler);
	float3 q = abs(p) - bound;
	float re = length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
	if (NearZero(shz)&& NearZero(shy))
	{
		return re;
	}
	else if (NearZero(shz))
	{
		float tanY = abs(shy > 0 ? (1 / shz) : (shy));
		return re * sin(atan(tanY));
	}
	else if (NearZero(shy))
	{
		float tanZ = abs(shz > 0 ? (1 / shz) : (shz));
		return re * sin(atan(tanZ));
	}
	else
	{
		float tanY = abs(shy > 0 ? (1 / shz) : (shy));
		float tanZ = abs(shz > 0 ? (1 / shz) : (shz));
		return re * sin(atan(tanZ)) * sin(atan(tanY));
	}
}

float SDFShearXSphere(float3 p, float3 center, float radius,
	float shy, float shz)
{
	p = p - center;
	p = ShearX(p, -shy, -shz);
	float re = length(p) - radius;
	if (NearZero(shz) && NearZero(shy))
	{
		return re;
	}
	else if (NearZero(shz))
	{
		float tanY = abs(shy > 0 ? (1 / shz) : (shy));
		return re * sin(atan(tanY));
	}
	else if (NearZero(shy))
	{
		float tanZ = abs(shz > 0 ? (1 / shz) : (shz));
		return re * sin(atan(tanZ));
	}
	else
	{
		float tanY = abs(shy > 0 ? (1 / shz) : (shy));
		float tanZ = abs(shz > 0 ? (1 / shz) : (shz));
		return re * sin(atan(tanZ)) * sin(atan(tanY));
	}
}

void FastSDFTraceSphere(Ray ray, out HitInfo info
	, float3 center, float radius)
{
	Init(info);

	int traceCount = 0;
	while (traceCount <= Fast_MAXSDFTraceCount)
	{
		//get sdf at now pos
		float sdf = SDFSphere(ray.pos, center, radius);

		if (sdf <= Fast_SDFTraceThre)
		{
			info.bHit = true;
			//!!!
			info.obj = 0;
			info.N = SDFSphereNormal(ray.pos, center);
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		traceCount++;
	}
}

float SDFXCylinder(float3 p, float r)
{
	p.x = 0;
	return length(p) - r;
}

float3 SDFXCylinderNormal(float3 p)
{
	p.x = 0;
	return normalize(p);
}

float SDFXAxis(float3 p, float r)
{
	if (abs(p.z) > r)
	{
		p.x = 0;
		return min(
			length(p - float3(0, 0, r)), 
			length(p - float3(0, 0, -r))
		);
	}
	else
	{
		return abs(p.y);
	}
}

float3 SDFXAxisNormal(float3 p)
{
	return p.y > 0 ? float3(0, 1, 0) : float3(0, -1, 0);
}

#endif