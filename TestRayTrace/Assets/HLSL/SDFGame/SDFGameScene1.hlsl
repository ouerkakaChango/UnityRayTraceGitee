#define OBJNUM 2

#define MaxSDF 100000
#define MaxTraceDis 10
#define MaxTraceTime 640
#define TraceThre 0.001
#define NormalEpsilon 0.0001

#define SceneSDFSoftShadowBias 0.1
#define SceneSDFShadowNormalBias 0.001
#define SceneSDFSoftShadowK 16

#include "../PBR/PBRCommonDef.hlsl"
#include "../HLSL/PBR/PBR_IBL.hlsl"
#include "../HLSL/PBR/PBR_GGX.hlsl"

Material_PBR GetObjMaterial_PBR(int obj)
{
	Material_PBR re;
	re.albedo = float3(1, 1, 1);
	re.metallic = 0.0f;
	re.roughness = 0.8f;

	if (obj == 0)
	{
		re.metallic = 1.0f;
		re.roughness = 0.0f;
	}
	else if (obj == 1)
	{
		re.metallic = 0.0f;
		re.roughness = 1.0f;
		re.albedo = 1;
	}
	return re;
}

float3 RenderSceneObj(Texture2DArray envSpecTex2DArr, Ray ray, HitInfo minHit)
{
	Material_PBR mat = GetObjMaterial_PBR(minHit.obj);
	if(minHit.obj==0)
	{
		return PBR_IBL(envSpecTex2DArr, mat, minHit.N, -ray.dir);
	}
	else if (minHit.obj == 1)
	{
		float3 lightDir = normalize(float3(1, -1, 1));
		float3 lightColor = float3(1, 1, 1) * 3.5;
		return PBR_GGX(mat, minHit.N, -ray.dir, -lightDir, lightColor) + 0.3 * mat.albedo;
	}
	return 0;
}

float HardShadow_TraceScene(Ray ray, out HitInfo info);
float SoftShadow_TraceScene(Ray ray, out HitInfo info);
float RenderSceneSDFShadow(Ray ray, HitInfo minHit)
{
	float3 lightDir = normalize(float3(1, -1, 1));
	ray.pos = minHit.P;
	ray.dir = -lightDir;
	ray.pos += SceneSDFShadowNormalBias * minHit.N;
	HitInfo hitInfo;
	return HardShadow_TraceScene(ray, hitInfo);
	//return 1;
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
	float r = 0.48;// +0.05*sin(16 * p.y)*sin(16 * p.x + 10 * _Time.y)*sin(16 * p.z);
	float dis = fbm4(p.zxy*10);
	r += 0.02*smoothstep(0.5f, 1.0f, dis);
	float3 center = float3(0, r, 0);
	 
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
	else if (inx == 1)
	{//地面
		//box center(0, -1.2, -5), bound(5, 0.1, 5)
		return SDFBox(p, float3(0, -0.5, 0), float3(5, 0.5, 5));
	}
	else
	{
		return -1;
	}
}

float3 GetObjSDFNormal(int inx, float3 p)
{
	return normalize(float3(
		GetObjSDF(inx, float3(p.x + NormalEpsilon, p.y, p.z)) - GetObjSDF(inx, float3(p.x - NormalEpsilon, p.y, p.z)),
		GetObjSDF(inx, float3(p.x, p.y + NormalEpsilon, p.z)) - GetObjSDF(inx, float3(p.x, p.y - NormalEpsilon, p.z)),
		GetObjSDF(inx, float3(p.x, p.y, p.z + NormalEpsilon)) - GetObjSDF(inx, float3(p.x, p.y, p.z - NormalEpsilon))
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


float TraceScene(Ray ray, out HitInfo info)
{
	Init(info);

	int traceCount = 0;
	while (traceCount <= MaxTraceTime)
	{
		int objInx = -1;
		float objSDF[OBJNUM];
		float sdf = MaxSDF;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			objSDF[inx] = GetObjSDF(inx, ray.pos);
			if (objSDF[inx] < sdf)
			{
				sdf = objSDF[inx];
				objInx = inx;
			}
		}

		if (sdf > MaxTraceDis)
		{
			break;
		}

		if (sdf <= TraceThre)
		{
			info.bHit = true;
			info.obj = objInx;
			info.N = GetObjNormal(objInx, ray.pos);
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		traceCount++;
	}

	if (info.bHit)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

float HardShadow_TraceScene(Ray ray, out HitInfo info)
{
	Init(info);

	int traceCount = 0;
	while (traceCount <= MaxTraceTime*0.1)
	{
		int objInx = -1;
		float objSDF[OBJNUM];
		float sdf = MaxSDF;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			objSDF[inx] = GetObjSDF(inx, ray.pos);
			if (objSDF[inx] < sdf)
			{
				sdf = objSDF[inx];
				objInx = inx;
			}
		}

		if (sdf > MaxTraceDis)
		{
			break;
		}

		if (sdf <= TraceThre*0.5)
		{
			info.bHit = true;
			info.obj = objInx;
			//info.N = GetObjNormal(objInx, ray.pos);
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		traceCount++;
	}

	if (info.bHit)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

//https://www.shadertoy.com/view/MsfGRr
float SoftShadow_TraceScene(Ray ray, out HitInfo info)
{
	Init(info);
	float sha = 1.0;
	float t = 0.005 * 0.1; //一个非0小值，会避免极其细微的多余shadow

	int traceCount = 0;
	while (traceCount <= MaxTraceTime*0.2)
	{
		int objInx = -1;
		float objSDF[OBJNUM];
		float sdf = MaxSDF;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			objSDF[inx] = GetObjSDF(inx, ray.pos);
			if (objSDF[inx] < sdf)
			{
				sdf = objSDF[inx];
				objInx = inx;
			}
		}

		if (sdf <= 0)
		{
			sha = 0;
			break;
		}

		if (sdf > MaxTraceDis)
		{
			break;
		}

		sha = min(sha, SceneSDFSoftShadowK * sdf / t);
		if (sha < 0.001) break;

		//*0.1f解决背面漏光问题
		if (sdf <= TraceThre*0.1f)
		{
			info.bHit = true;
			info.obj = objInx;
			//info.N = GetObjNormal(objInx, ray.pos);
			info.P = ray.pos;
			break;
		}

		t += clamp(sdf, 0.01*SceneSDFSoftShadowBias, 0.5*SceneSDFSoftShadowBias);

		ray.pos += sdf * ray.dir;
		traceCount++;
	}

	return saturate(sha);
}