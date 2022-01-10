#define OBJNUM 1

#define TraceThre 0.0001
#define TraceStart 0.0005

#include "../PBR/PBRCommonDef.hlsl"

Material_PBR GetObjMaterial_PBR(int obj)
{
	Material_PBR re;
	re.albedo = float3(1, 1, 1);
	re.metallic = 1.0f;
	re.roughness = 0.0f;

	//re.metallic = 0.0f;
	//re.roughness = 0.8f;
	return re;
}
//###################################################################################
#include "SDFCommonDef.hlsl"
#include "../Noise/NoiseCommonDef.hlsl"

//tutorial: iq modeling https://www.youtube.com/watch?v=-pdSjBPH3zM

//float SDFFoTou(float3 p)
//{
//	float re = 0;
//	float r = 10.45 + 0.05*sin(16 * p.y)*sin(16 * p.x + 10 * _Time.y)*sin(16 * p.z);
//	float3 center = float3(0, 0.5, 0);
//	re = length(p - center) - r;
//	re *= 0.5f;
//	return re;
//}

float SDFPlanet(float3 p)
{
	float re = 0;
	float r = 0.5;// +0.05*sin(16 * p.y)*sin(16 * p.x + 10 * _Time.y)*sin(16 * p.z);
	float dis = fbm4(p.zxy*10);
	r += 0.02*smoothstep(0.5f, 1.0f, dis);
	float3 center = float3(0, 0.5, 0);
	 
	re = length(p - center) - r;
	re *= 0.5f;
	return re;
}

//float3 SDFPlanetNormal(float3 p);

float GetObjSDF(int inx, float3 p)
{
	if (inx == 0)
	{
		//return SDFSphere(p, float3(0, 0.5, 0), 0.5); //球
		return SDFPlanet(p);
	}
	//else if (inx == 1)
	//{//地面
	//	//box center(0, -1.2, -5), bound(5, 0.1, 5)
	//	return SDFBox(p, float3(0, -1.2, -5), float3(5, 0.1, 5));
	//}
	else
	{
		return -1;
	}
}

float3 GetObjSDFNormal(int inx, float3 p)
{
	float epsilon = 0.0001f;
	return normalize(float3(
		GetObjSDF(inx, float3(p.x + epsilon, p.y, p.z)) - GetObjSDF(inx, float3(p.x - epsilon, p.y, p.z)),
		GetObjSDF(inx, float3(p.x, p.y + epsilon, p.z)) - GetObjSDF(inx, float3(p.x, p.y - epsilon, p.z)),
		GetObjSDF(inx, float3(p.x, p.y, p.z + epsilon)) - GetObjSDF(inx, float3(p.x, p.y, p.z - epsilon))
		));
}

float3 GetObjNormal(int inx, float3 p)
{
	if (inx == 0)
	{
		//return SDFSphereNormal(p, float3(0, 0.5, 0));
		//return SDFPlanetNormal(p);
		return GetObjSDFNormal(inx, p);
	}
	else
	{
		return GetObjSDFNormal(inx, p);
	}
}

void SDFScene(in Ray ray,out HitInfo info)
{
	info.bHit = 0;
	info.obj = -1;
	info.N = 0;
	info.P = 0;

	bool bConti = true;
	float maxTraceDis = 100.0f;

	float traceDis = -1.0f;
	int objInx = -1;
	float objSDF[OBJNUM];
	float sdf = 1000; //a very large,can be larger than maxTraceDis

	//old错误方法：ray.pos += ray.dir*TraceStart;
	//new方法：向N方向走出去
	int c1 = 0;
	while (c1<10000)
	{
		sdf = 1000;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			objSDF[inx] = GetObjSDF(inx, ray.pos);
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

		ray.pos += GetObjNormal(objInx, ray.pos)*TraceStart*c1;
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
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				objSDF[inx] = GetObjSDF(inx, ray.pos);
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
				info.N = GetObjNormal(objInx, ray.pos);
				//int count = 1;
				//while (length(info.N)<0.001)
				//{
				//	info.N = GetObjNormal(objInx, info.P - ray.dir*0.001*count);
				//	count++;
				//}
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