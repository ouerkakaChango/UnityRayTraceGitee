#define OBJNUM 5

#define MaxSDF 100000
#define MaxTraceDis 1000
#define MaxTraceTime 640
#define TraceThre 0.001
#define NormalEpsilon 0.01

#define SceneSDFSoftShadowBias 0.1
#define SceneSDFShadowNormalBias 0.001
#define SceneSDFSoftShadowK 16

#include "../../HLSL/PBR/PBRCommonDef.hlsl"
#include "../../HLSL/PBR/PBR_IBL.hlsl"
#include "../../HLSL/PBR/PBR_GGX.hlsl"

#include "../../HLSL/Spline/SplineCommonDef.hlsl"
#include "../../HLSL/Noise/WoodNoise.hlsl"

Material_PBR GetObjMaterial_PBR(int obj)
{
	Material_PBR re;
	re.albedo = float3(1, 1, 1);
	re.metallic = 0.0f;
	re.roughness = 0.8f;

	//@@@SDFBakerMgr ObjMaterial
if(obj == 0 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 1 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 2 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 3 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 0.2;
}
else if (obj == 4 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 1;
}
	//@@@
	return re;
}

int GetObjRenderMode(int obj)
{
//@@@SDFBakerMgr ObjRenderMode
int renderMode[5];
renderMode[0] = 2;
renderMode[1] = 2;
renderMode[2] = 0;
renderMode[3] = 0;
renderMode[4] = 2;
return renderMode[obj];
//@@@
}

void ObjPreRender(inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
if(mode == 2)
{
	mat.albedo *= WoodColor(5*minHit.P);
	mode = 0;
}
}

float3 RenderSceneObj(Texture2DArray envSpecTex2DArr, Ray ray, HitInfo minHit)
{
	Material_PBR mat = GetObjMaterial_PBR(minHit.obj);
	int mode = GetObjRenderMode(minHit.obj);
	ObjPreRender(mode, mat, ray, minHit);
//@@@SDFBakerMgr ObjRender
if(mode==0)
{
float3 lightDirs[1];
float3 lightColors[1];
lightDirs[0] = float3(-0.2610216, -0.6762021, -0.6889255);
lightColors[0] = float3(1, 1, 1);
float3 re = 0.3 * mat.albedo;
for(int i=0;i<1;i++)
{
re += PBR_GGX(mat, minHit.N, -ray.dir, -lightDirs[i], lightColors[i]);
}
return re;
}
//@@@
else if (mode == 1)
{
	return PBR_IBL(envSpecTex2DArr, mat, minHit.N, -ray.dir);
}
	return 0;
}

float HardShadow_TraceScene(Ray ray, out HitInfo info);
float SoftShadow_TraceScene(Ray ray, out HitInfo info);
float RenderSceneSDFShadow(Ray ray, HitInfo minHit)
{
float3 lightDir = normalize(float3(-1, -1, -1));
ray.pos = minHit.P;
ray.dir = -lightDir;
ray.pos += SceneSDFShadowNormalBias * minHit.N;
HitInfo hitInfo;
return saturate(0.2 + HardShadow_TraceScene(ray, hitInfo));

//return 1;
}

//###################################################################################
#include "../../HLSL/SDFGame/SDFCommonDef.hlsl"
#include "../../HLSL/Noise/NoiseCommonDef.hlsl"

//tutorial: iq modeling https://www.youtube.com/watch?v=-pdSjBPH3zM

float SDFFoTou(float3 p)
{
	float re = 0;
	float r = 10.45 + 0.05*sin(16 * p.y)*sin(16 * p.x + 10 * _Time.y)*sin(16 * p.z);
	float3 center = float3(0, 0.5, 0);
	re = length(p - center) - r;
	re *= 0.5f;
	return re;
}
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

float GetObjSDF(int inx, float3 p)
{

	//### A
	//float a1 = SDFShearXBoxTransform(p, float3(5, 0.5, 0.5),
	//	0, 0.3,
	//	float3(0, -0.5, -1.5));
	//
	//float a2 = SDFShearXBoxTransform(p, float3(5, 0.5, 0.5),
	//	0, -0.3,
	//	float3(0, -0.5, 1.5));
	//
	//float a3 = SDFBox(p, float3(-1.5, -0.5, 0), float3(0.4, 0.5, 2));
	//
	//float re = min(a1,a2);
	//re = min(re,a3);

	//### Spline
	//float re = 10000;
	//float2 box = float2(0.1, 0.05);
	//Transform trans;
	//Init(trans);
	//float2 spline[5];
	//spline[0] = float2(0,0);
	//spline[1] = float2(1.06,0.72);
	//spline[2] = float2(1.67,0);
	//spline[3] = float2(2.717196,-1.236034);
	//spline[4] = float2(2.89,-3);

	//float2 sp[9];
	//sp[0] = float2(2, 0.44);
	//sp[1] = float2(0, -0.1);
	//sp[2] = float2(-0.67, 0.58);
	//sp[3] = float2(-1.175332, 1.092874);
	//sp[4] = float2(-1.21, 1.54);
	//sp[5] = float2(-1.247879, 2.028534);
	//sp[6] = float2(-0.64, 2.5);
	//sp[7] = float2(0.2687165, 3.204794);
	//sp[8] = float2(2, 2.5);

	//FUNC_SDFBoxedQuadBezier(re, p, spline, 5, trans, box)
	//FUNC_SDFBoxedQuadBezier(re, p, sp, 9, trans, box)

	//###
	float re = MaxTraceDis + 1; //Make sure default is an invalid SDF

	//@@@SDFBakerMgr ObjSDF
if(inx == 0 )
{
inx = -1;
}
else if (inx == 1 )
{
re = min(re, 0 + SDFBox(p, float3(0.861513, 1.894959, -5.500246), float3(0.07071168, 1.511707, 0.06462751), float3(338.16, 71.39999, 0)));
}
else if (inx == 2 )
{
re = min(re, 0 + SDFBox(p, float3(0, 0, 0), float3(20, 0.5, 20), float3(0, 0, 0)));
}
else if (inx == 3 )
{
re = min(re, 0 + SDFBox(p, float3(0.5009151, 2.27, -4.9), float3(0.7450001, 1.11, 0.025), float3(338.16, 71.39999, 0)));
}
else if (inx == 4 )
{
re = min(re, 0 + SDFBox(p, float3(0.4200063, 1.894959, -4.188335), float3(0.07071168, 1.511707, 0.06462751), float3(338.16, 71.39999, 0)));
}
	//@@@
	if(inx == -1)
	{
		float trunkBox = SDFBox(p, float3(0, 2, 0), float3(0.2, 2, 0.2), float3(0, 0, 0));
		re = min(re, trunkBox );
	}
return re;

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
