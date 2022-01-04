#define SysOBJNUM 1

#define TraceThre 0.01
#define TraceStart 0.05

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

void SDFSys(in Ray ray,out HitInfo info)
{
	info.bHit = 0;
	info.obj = -1;
	info.N = 0;
	info.P = 0;

	bool bConti = true;
	float maxTraceDis = 100.0f;

	float traceDis = -1.0f;
	int objInx = -1;
	float objSDF[SysOBJNUM];
	float sdf = 1000; //a very large,can be larger than maxTraceDis

	//old错误方法：ray.pos += ray.dir*TraceStart;
	//new方法：向N方向走出去
	int c1 = 0;
	while (c1<10000)
	{
		sdf = 1000;
		for (int inx = 0; inx < SysOBJNUM; inx++)
		{
			objSDF[inx] = GetSysObjSDF(inx, ray.pos);
			if (objSDF[inx] < sdf)
			{
				sdf = objSDF[inx];
				objInx = inx;
			}
		}
		if (sdf >= TraceStart)
		{
			break;
		}

		ray.pos += GetSysObjNormal(objInx, ray.pos)*TraceStart*c1;
		c1 += 1;
	}
	if (c1 >= 10000)
	{
		info.bHit = -2;
		bConti = false;
	}
	if (bConti)
	{
		int c2 = 0;
		while (c2 < 10000)
		{
			sdf = 1000; //a very large,can be larger than maxTraceDis
			for (int inx = 0; inx < SysOBJNUM; inx++)
			{
				objSDF[inx] = GetSysObjSDF(inx, ray.pos);
				if (objSDF[inx] < sdf)
				{
					sdf = objSDF[inx];
					objInx = inx;
				}
			}

			if (sdf > maxTraceDis)
			{
				break;
			}
			else if (sdf <= TraceThre)
			{
				traceDis = sdf;
				info.bHit = 1;
				info.obj = objInx;
				info.P = ray.pos;
				info.N = GetSysObjNormal(objInx, ray.pos);
				break;
			}
			ray.pos += ray.dir*sdf;
			c2 += 1;
		}
		if (c2 >= 10000)
		{
			info.bHit = -1;
		}
	}
}