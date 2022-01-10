#define SysOBJNUM 1

//###################################################################################
#include "SDFCommonDef.hlsl"
#include "../RayMath.hlsl"

float GetSysObjSDF(int inx, float3 p)
{
	if (inx == 0)
	{//x轴圆柱
		return SDFXAxis(p, 0.1f);
	}
	else
	{
		return -1;
	}
}

float3 GetSysObjSDFNormal(int inx, float3 p)
{
	float epsilon = 0.0001f;
	return normalize(float3(
		GetSysObjSDF(inx, float3(p.x + epsilon, p.y, p.z)) - GetSysObjSDF(inx, float3(p.x - epsilon, p.y, p.z)),
		GetSysObjSDF(inx, float3(p.x, p.y + epsilon, p.z)) - GetSysObjSDF(inx, float3(p.x, p.y - epsilon, p.z)),
		GetSysObjSDF(inx, float3(p.x, p.y, p.z + epsilon)) - GetSysObjSDF(inx, float3(p.x, p.y, p.z - epsilon))
		));
}

float3 GetSysObjNormal(int inx, float3 p)
{
	if (inx == 0)
	{
		return SDFXAxisNormal(p);
	}
	else
	{
		return GetSysObjSDFNormal(inx, p);
	}
}

void RaySys(in Ray ray, out HitInfo info, out float3 sysColor)
{
	Init(info);

	Plane xPlane;
	xPlane.p = 0;
	xPlane.n = float3(0, 1, 0);
	float k = RayCastPlane(ray, xPlane);
	if (k > 0)
	{
		float3 hitP = ray.pos + k * ray.dir;
		if (abs(hitP.z) < 0.1f)
		{
			info.bHit = 1;
			info.N = xPlane.n;
			info.P = hitP;
			sysColor = float3(1, 0, 0);
		}
	}

	Plane zPlane;
	zPlane.p = 0;
	zPlane.n = float3(0, 1, 0);
	k = RayCastPlane(ray, zPlane);
	if (k > 0)
	{
		float3 hitP = ray.pos + k * ray.dir;
		if (abs(hitP.x) < 0.1f)
		{
			info.bHit = 1;
			info.N = xPlane.n;
			info.P = hitP;
			sysColor = float3(0, 0, 1);
		}
	}
}