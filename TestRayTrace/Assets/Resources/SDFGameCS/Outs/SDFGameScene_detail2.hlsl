﻿#define OBJNUM 3

#define MaxSDF 100000
#define MaxTraceDis 100
#define MaxTraceTime 6400
#define TraceThre 0.0001
#define NormalEpsilon 0.001

#define SceneSDFShadowNormalBias 0.2

#define SceneSDFSoftShadowBias 0.1
#define SceneSDFSoftShadowK 16

#include "../../../HLSL/PBR/PBRCommonDef.hlsl"
#include "../../../HLSL/PBR/PBR_IBL.hlsl"
#include "../../../HLSL/PBR/PBR_GGX.hlsl"

#include "../../../HLSL/UV/UVCommonDef.hlsl"
#include "../../../HLSL/Random/RandUtility.hlsl"
#include "../../../HLSL/Noise/NoiseCommonDef.hlsl"
#include "../../../HLSL/Transform/TransformCommonDef.hlsl"
#include "../../../HLSL/SDFGame/SDFCommonDef.hlsl"

float daoScale;

//@@@SDFBakerMgr TexSys
Texture2D<float3> lightmap_ground;
//@@@

//@@@SDFBakerMgr DyValSys
//@@@

void GetEnvInfoByID(int texInx, inout bool isPNGEnv, inout Texture2DArray envTexArr)
{
	//@@@SDFBakerMgr TexSys_EnvTexSettings
	//@@@
	if(texInx == 9999)
	{
		isPNGEnv = false;
		envTexArr = envSpecTex2DArr;
	}
}

void GetEnvTexArrByObj(int objInx, inout bool isPNGEnv, inout Texture2DArray envTexArr)
{
	//@@@SDFBakerMgr ObjEnvTex
	//@@@
	if(objInx == 9999)
	{
		isPNGEnv = false;
		envTexArr = envSpecTex2DArr;
	}
}

float GetPntlightAttenuation(float3 pos, float3 lightPos)
{
	//return 1;
	float d = length(pos - lightPos);
	return saturate(1 / (d*d));
	//float d = length(pos - lightPos);
	//return 1 / (1 + 0.2*d + 0.04*d*d);
}


Material_PBR GetObjMaterial_PBR(int obj)
{
	Material_PBR re;
	re.albedo = float3(1, 1, 1);
	re.metallic = 0.0f;
	re.roughness = 0.8f;
	re.ao = 1;

//@@@SDFBakerMgr ObjMaterial
if(obj == 0 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 0.4;
}
else if (obj == 1 )
{
re.albedo = float3(0, 0, 1);
re.metallic = 0;
re.roughness = 0.9;
}
else if (obj == 2 )
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
int renderMode[3];
renderMode[0] = 0;
renderMode[1] = 4;
renderMode[2] = 0;
return renderMode[obj];
//@@@
}

void ObjPreRender(inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
int inx = minHit.obj;
//@@@SDFBakerMgr SpecialObj
if(inx == 0 )
{
}
else if (inx == 1 )
{
}
else if (inx == 2 )
{
}
//@@@

	if(inx == 0)
	{
		//???
		//float2 uv = BoxedUV(minHit.P, float3(0, -0.5, 0), float3(5, 0.5, 5), float3(0, 0, 0));
		//float3 color = lightmap_ground.SampleLevel(common_point_clamp_sampler, uv, 0).rgb;
		//float2 grid = frac(1024*uv);
		//mat.albedo += float4(color,1);
		//mat.albedo = float4(grid,0,1);
	}
}

void ObjPostRender(inout float3 result, inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
if(camGammaMode == 1)
{
	
}
else{
	//gamma
	result = result / (result + 1.0);
	result = pow(result, 1/2.2);
}
}

float3 RenderSceneObj(Ray ray, HitInfo minHit)
{
	Material_PBR mat = GetObjMaterial_PBR(minHit.obj);
	int mode = GetObjRenderMode(minHit.obj);
	ObjPreRender(mode, mat, ray, minHit);
	float3 result = 0;
//@@@SDFBakerMgr ObjRender
if(mode==0)
{
float3 lightDirs[3];
float3 lightColors[3];
lightDirs[0] = normalize(minHit.P - float3(-0.07, 2.17, 3.42));
lightColors[0] = float3(1, 1, 1) * GetPntlightAttenuation(minHit.P, float3(-0.07, 2.17, 3.42));
lightDirs[1] = normalize(minHit.P - float3(0.04, 2.12, -3.29));
lightColors[1] = float3(1, 0.8581352, 0) * GetPntlightAttenuation(minHit.P, float3(0.04, 2.12, -3.29));
lightDirs[2] = normalize(minHit.P - float3(3.357384, 2.12, 0));
lightColors[2] = float3(1, 0.8581352, 0) * GetPntlightAttenuation(minHit.P, float3(3.357384, 2.12, 0));
result = 0 * mat.albedo * mat.ao;
for(int i=0;i<3;i++)
{
result += PBR_GGX(mat, minHit.N, -ray.dir, -lightDirs[i], lightColors[i]);
}
}
//@@@
else if (mode == 1)
{
	result = PBR_IBL(envSpecTex2DArr, mat, minHit.N, -ray.dir);
}
else if (mode == 2)
{
	//object reflection IBL
	bool isPNGEnv=false;
	Texture2DArray tempEnv;
	GetEnvTexArrByObj(minHit.obj, isPNGEnv, tempEnv);
	if(isPNGEnv)
	{
		result = PBR_IBL(tempEnv, mat, minHit.N, -ray.dir,1,1,true,true);
	}
	else
	{
		result = PBR_IBL(tempEnv, mat, minHit.N, -ray.dir);
	}
}
else if (mode == 3)
{
	//lightmap mode
	result = mat.albedo;
	//result = pow(result,2.2);
	//result = pow(result,2.2);
}
else if (mode == 4)
{
	//???
	float3 lightPos = float3(0,2,0);
	float3 lightColor = float3(1,1,1);
	float3 pos = minHit.P;
	pos.z = 4;
	//pos.x = 3;
	//pos.y = 3;
	float3 L = normalize(lightPos - pos);
	float3 n = float3(0,0,-1);//minHit.N
	//float3 v = float3(0,0,-1);
	//float3 h = normalize(l+v);
	//result = 0.05*saturate(dot(n,h));
	result = 0.05 * saturate(dot(n,L));
}
else if (mode == 333)
{
	float3 lightPos = float3(0,4,0);
	float3 lightColor = float3(1,1,1);
	float3 l = normalize(lightPos - minHit.P);
	result = PBR_GGX(mat, minHit.N, -ray.dir, l, lightColor);
}
	ObjPostRender(result, mode, mat, ray, minHit);
	return result;
}


float HardShadow_TraceScene(Ray ray, out HitInfo info);
float SoftShadow_TraceScene(Ray ray, out HitInfo info);

float GetDirHardShadow(Ray ray, float3 lightDir, in HitInfo minHit)
{
	ray.pos = minHit.P;
	ray.dir = -lightDir;
	ray.pos += SceneSDFShadowNormalBias * minHit.N;
	HitInfo hitInfo;
	return HardShadow_TraceScene(ray, hitInfo);
}

float RenderSceneSDFShadow(Ray ray, HitInfo minHit)
{
	float sha = 1;
if(false)
{
//@@@SDFBakerMgr DirShadow
float3 lightDirs[3];
lightDirs[0] = normalize(minHit.P - float3(-0.07, 2.17, 3.42));
lightDirs[1] = normalize(minHit.P - float3(0.04, 2.12, -3.29));
lightDirs[2] = normalize(minHit.P - float3(3.357384, 2.12, 0));
for(int i=0;i<3;i++)
{
	sha *= GetDirHardShadow(ray, lightDirs[i], minHit);
}
//@@@
}
sha = saturate(0.2 + sha);
return sha;
}

//###################################################################################
#include "../../../HLSL/SDFGame/SDFCommonDef.hlsl"
#include "../../../HLSL/Noise/NoiseCommonDef.hlsl"

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

float GetObjSDF(int inx, float3 p, in TraceInfo traceInfo)
{
//###
float re = MaxTraceDis + 1; //Make sure default is an invalid SDF
//@@@SDFBakerMgr BeforeObjSDF
//@@@
//@@@SDFBakerMgr ObjSDF
if(inx == 0 )
{
re = min(re, 0 + SDFBox(p, float3(0, -0.5, 0), float3(5, 0.5, 5), float3(0, 0, 0)));
}
else if (inx == 1 )
{
re = min(re, 0 + SDFBox(p, float3(0, 3.98, 5), float3(5, 0.5000001, 5.000001), float3(90, 0, 0)));
}
else if (inx == 2 )
{
re = min(re, 0 + SDFBox(p, float3(-6.25, 1.04, 2.59), float3(0.5, 0.5, 0.5), float3(0, 0, 0)));
}
//@@@

return re;
}

float3 GetObjSDFNormal(int inx, float3 p, in TraceInfo traceInfo, float eplisonScale = 1.0f)
{
	float normalEpsilon = NormalEpsilon;
	//normalEpsilon *= daoScale;
	return normalize(float3(
		GetObjSDF(inx, float3(p.x + NormalEpsilon*eplisonScale, p.y, p.z), traceInfo) - GetObjSDF(inx, float3(p.x - NormalEpsilon*eplisonScale, p.y, p.z), traceInfo),
		GetObjSDF(inx, float3(p.x, p.y + NormalEpsilon*eplisonScale, p.z), traceInfo) - GetObjSDF(inx, float3(p.x, p.y - NormalEpsilon*eplisonScale, p.z), traceInfo),
		GetObjSDF(inx, float3(p.x, p.y, p.z + NormalEpsilon*eplisonScale), traceInfo) - GetObjSDF(inx, float3(p.x, p.y, p.z - NormalEpsilon*eplisonScale), traceInfo)
		));
}

float3 GetObjNormal(int inx, float3 p, in TraceInfo traceInfo)
{
//@@@SDFBakerMgr SpecialObj
if(inx == 0 )
{
}
else if (inx == 1 )
{
}
else if (inx == 2 )
{
}
//@@@
	return GetObjSDFNormal(inx, p, traceInfo);
}


void TraceScene(Ray ray, out HitInfo info)
{
	float traceThre = TraceThre;

	//traceThre *= daoScale;

	Init(info);

	TraceInfo traceInfo;
	Init(traceInfo,MaxSDF);

	float objSDF[OBJNUM];
	bool innerBoundFlag[OBJNUM];
	float innerBoundStepScale[OBJNUM];
	int objInx = -1;
	float sdf = MaxSDF;
	bool bInnerBound = false;

	while (traceInfo.traceCount <= MaxTraceTime)
	{
		objInx = -1;
		sdf = MaxSDF;
		bInnerBound = false;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			innerBoundFlag[inx] = false;
			innerBoundStepScale[inx] = 1;
		}

//@@@SDFBakerMgr CheckInnerBound
//@@@

		if(bInnerBound)
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				if(innerBoundFlag[inx])
				{
					objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo) * innerBoundStepScale[inx];
					if (objSDF[inx] < sdf)
					{
						sdf = objSDF[inx];
						objInx = inx;
					}
				}
			}
		}
		else
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo);
				if (objSDF[inx] < sdf)
				{
					sdf = objSDF[inx];
					objInx = inx;
				}
			}
		}

		if(objInx == -1)
		{
			break;
		}

		if (sdf > MaxTraceDis)
		{
			break;
		}

		if (sdf <= traceThre)
		{
			info.bHit = true;
			info.obj = objInx;
			info.N = GetObjNormal(objInx, ray.pos, traceInfo);
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		Update(traceInfo,sdf);
	}
}

float HardShadow_TraceScene(Ray ray, out HitInfo info)
{
	Init(info);

	TraceInfo traceInfo;
	Init(traceInfo,MaxSDF);

	float objSDF[OBJNUM];
	bool innerBoundFlag[OBJNUM];
	float innerBoundStepScale[OBJNUM];
	int objInx = -1;
	float sdf = MaxSDF;
	bool bInnerBound = false;

	while (traceInfo.traceCount <= MaxTraceTime*0.01)
	{
		objInx = -1;
		sdf = MaxSDF;
		bInnerBound = false;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			innerBoundFlag[inx] = false;
			innerBoundStepScale[inx] = 1;
		}


		if(bInnerBound)
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				if(innerBoundFlag[inx])
				{
					objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo) * innerBoundStepScale[inx];
					if (objSDF[inx] < sdf)
					{
						sdf = objSDF[inx];
						objInx = inx;
					}
				}
			}
		}
		else
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo);
				if (objSDF[inx] < sdf)
				{
					sdf = objSDF[inx];
					objInx = inx;
				}
			}
		}

		if(objInx == -1)
		{
			break;
		}

		if (sdf > MaxTraceDis*0.05)
		{
			break;
		}

		if (sdf <= TraceThre*2)
		{
			info.bHit = true;
			info.obj = objInx;
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		Update(traceInfo,sdf);
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

	TraceInfo traceInfo;
	Init(traceInfo,MaxSDF);
	while (traceInfo.traceCount <= MaxTraceTime*0.2)
	{
		int objInx = -1;
		float objSDF[OBJNUM];
		float sdf = MaxSDF;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo);
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
			info.P = ray.pos;
			break;
		}

		t += clamp(sdf, 0.01*SceneSDFSoftShadowBias, 0.5*SceneSDFSoftShadowBias);

		ray.pos += sdf * ray.dir;
		Update(traceInfo,sdf);
	}

	return saturate(sha);
}

void Indir_TraceScene(Ray ray, out HitInfo info)
{
	float traceThre = TraceThre;

	Init(info);

	TraceInfo traceInfo;
	Init(traceInfo,MaxSDF);

	float objSDF[OBJNUM];
	bool innerBoundFlag[OBJNUM];
	float innerBoundStepScale[OBJNUM];
	int objInx = -1;
	float sdf = MaxSDF;
	bool bInnerBound = false;

	while (traceInfo.traceCount <= 40)
	{
		objInx = -1;
		sdf = MaxSDF;
		bInnerBound = false;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			innerBoundFlag[inx] = false;
			innerBoundStepScale[inx] = 1;
		}

		if(bInnerBound)
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				if(innerBoundFlag[inx])
				{
					objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo) * innerBoundStepScale[inx];
					if (objSDF[inx] < sdf)
					{
						sdf = objSDF[inx];
						objInx = inx;
					}
				}
			}
		}
		else
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo);
				if (objSDF[inx] < sdf)
				{
					sdf = objSDF[inx];
					objInx = inx;
				}
			}
		}

		if(objInx == -1)
		{
			break;
		}

		if (sdf > 100)
		{
			break;
		}

		if (sdf <= traceThre)
		{
			info.bHit = true;
			info.obj = objInx;
			info.N = GetObjNormal(objInx, ray.pos, traceInfo);
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		Update(traceInfo,sdf);
	}
}

void SceneRenderIndirRay(in Ray ray, out float3 re, out HitInfo minHit)
{
	re = 0;
	//---Trace
	Init(minHit);
	Indir_TraceScene(ray, minHit);
	//___Trace

	if (minHit.bHit)
	{
		re = RenderSceneObj(ray, minHit);
	}
}

float3 IndirPointLightRender(float3 P, float3 N, float3 lightColor,float3 lightPos)
{
	float3 Li = lightColor * GetPntlightAttenuation(P,lightPos);
	float3 L = normalize(lightPos - P);
	return Li*saturate(dot(N,L));
}

void SetCheapIndirectColor(inout float3 re, Ray ray, HitInfo minHit)
{
	Ray ray_indirect;
	ray_indirect.pos = minHit.P;
	float3 indir = 0;
	int spp = 8;
	float3 lastV = 10*minHit.P;
	lastV = abs(lastV);
	for(int i=0;i<spp;i++)
	{
		if(true)
		{
			//float2 Xi = Hammersley(i, spp);
			float2 Xi = float2(rand01(100*lastV.zyx),rand01(100*lastV));
			float theta = 2*PI*Xi.x;
			float phi = PI*(2*Xi.y-1);
			float3 randDir = float3(
				sin(phi)*cos(theta),
				sin(phi)*sin(theta),
				cos(phi)
			);
			//lastV = normalize(lastV+randDir);
			randDir.z = abs(randDir.z);
			ray_indirect.dir = Vec2NormalHemisphere(randDir,minHit.N);
			
		}
		{
			//ray_indirect.dir = reflect(ray.dir,minHit.N);
		}
		ray_indirect.pos = minHit.P + ray_indirect.dir*TraceThre*2;
		HitInfo indirHit;
		float3 indirLightColor;
		SceneRenderIndirRay(ray_indirect, indirLightColor, indirHit);
		indir += IndirPointLightRender(minHit.P,minHit.N, indirLightColor, indirHit.P);
	}
	indir /= spp;
	//re = indir;
	re += indir;
	//re = IndirPointLightRender(minHit.P,minHit.N, 1, float3(0,2,0));
}

void SetIndirectColor(inout float3 re, Ray ray, HitInfo minHit)
{
	//SetCheapIndirectColor(re, ray, minHit);
}
