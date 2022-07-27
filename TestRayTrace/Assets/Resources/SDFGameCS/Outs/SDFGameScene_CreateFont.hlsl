#define OBJNUM 8

#define MaxSDF 100000
#define MaxTraceDis 100
#define MaxTraceTime 6400
#define TraceThre 0.001
#define NormalEpsilon 0.001

#define SceneSDFShadowNormalBias 0.2

#define SceneSDFSoftShadowBias 0.1
#define SceneSDFSoftShadowK 16

#include "../../../HLSL/PBR/PBRCommonDef.hlsl"
#include "../../../HLSL/PBR/PBR_IBL.hlsl"
#include "../../../HLSL/PBR/PBR_GGX.hlsl"

#include "../../../HLSL/Spline/SplineCommonDef.hlsl"
#include "../../../HLSL/Noise/WoodNoise.hlsl"
#include "../../../HLSL/Noise/TerrainNoise.hlsl"
#include "../../../HLSL/UV/UVCommonDef.hlsl"
#include "../../../HLSL/TransferMath/TransferMath.hlsl"
#include "../../../HLSL/Random/RandUtility.hlsl"
#include "../../../HLSL/Transform/TransformCommonDef.hlsl"
#include "../../../HLSL/SDFGame/SDFCommonDef.hlsl"
#include "../../../HLSL/SDFGame/SDFGridObjects.hlsl"
#include "../../../HLSL/Spline/QuadBezier/QuadBezier.hlsl"
#include "../../SDFGamePrefab/font_prefab.hlsl"

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
re.albedo = float3(1, 0, 0);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 1 )
{
re.albedo = float3(0, 0, 1);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 2 )
{
re.albedo = float3(0.6037736, 0.6037736, 0.6037736);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 3 )
{
re.albedo = float3(0, 0.311419, 1);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 4 )
{
re.albedo = float3(1, 0, 0);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 5 )
{
re.albedo = float3(0, 0, 1);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 6 )
{
re.albedo = float3(1, 0, 0);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 7 )
{
re.albedo = float3(0, 0, 1);
re.metallic = 0;
re.roughness = 1;
}
	//@@@
	return re;
}

int GetObjRenderMode(int obj)
{
//@@@SDFBakerMgr ObjRenderMode
int renderMode[8];
renderMode[0] = 0;
renderMode[1] = 0;
renderMode[2] = 4;
renderMode[3] = 0;
renderMode[4] = 0;
renderMode[5] = 0;
renderMode[6] = 0;
renderMode[7] = 0;
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
inx = -1;
}
else if (inx == 3 )
{
inx = -2;
}
else if (inx == 4 )
{
}
else if (inx == 5 )
{
}
else if (inx == 6 )
{
}
else if (inx == 7 )
{
}
//@@@
if(inx == -1)
{
	float2 pos = minHit.P.xz;
	int2 grid = floor(pos);
	if(abs(grid.x%2) == abs(grid.y%2))
	{
		mat.albedo *= 0.5;
	}
}
}

void ObjPostRender(inout float3 result, inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
result = result / (result + 1.0);
result = pow(result, 1/2.2);
}

float3 RenderSceneObj(Texture2DArray envSpecTex2DArr, Ray ray, HitInfo minHit)
{
	Material_PBR mat = GetObjMaterial_PBR(minHit.obj);
	int mode = GetObjRenderMode(minHit.obj);
	ObjPreRender(mode, mat, ray, minHit);
	float3 result = 0;
//@@@SDFBakerMgr ObjRender
if(mode==0)
{
float3 lightDirs[1];
float3 lightColors[1];
lightDirs[0] = float3(-0.3213938, -0.7660444, 0.5566705);
lightColors[0] = float3(1, 0.9568627, 0.8392157);
result = 0.03 * mat.albedo * mat.ao;
for(int i=0;i<1;i++)
{
result += PBR_GGX(mat, minHit.N, -ray.dir, -lightDirs[i], lightColors[i]);
}
}
//@@@
else if (mode == 1)
{
	result = PBR_IBL(envSpecTex2DArr, mat, minHit.N, -ray.dir);
}
else if (mode == 3)
{
	float3 lightPos = float3(0,4,0);
	float3 lightColor = float3(1,1,1);
	float3 l = normalize(lightPos - minHit.P);
	result = PBR_GGX(mat, minHit.N, -ray.dir, l, lightColor);
}
else if (mode == 4)
{
	result = mat.albedo;
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
float3 lightDirs[1];
lightDirs[0] = float3(-0.3213938, -0.7660444, 0.5566705);
for(int i=0;i<1;i++)
{
	sha *= GetDirHardShadow(ray, lightDirs[i], minHit);
}
//@@@
}
sha = saturate(0.2 + sha);
return sha;
}

//###################################################################################
//void SDFPrefab_ASCII_65(inout float re, in float3 p)
//{
//	float d = re;
//	float height = 0.1;
//	float sizeU = 0.1;
//	float sizeV1 = 0.6;
//	float sizeV2 = 0.3;
//	float footDisToCenter = 0.12;
//	float shearStrength = 0.4;
//	float disToCenter1 = 0.1f;
//	float a1 = SDFShearZBoxTransform(p, float3(sizeU*0.5, height, sizeV1*0.5),
//	shearStrength, 0,
//	float3(0.5 - footDisToCenter, height, 0.5));
//
//	float a2 = SDFShearZBoxTransform(p, float3(sizeU*0.5, height, sizeV1*0.5),
//	-shearStrength, 0,
//	float3(0.5 + footDisToCenter, height, 0.5));
//
//	float a3 = SDFBox(p, float3(0.5, height, 0.5 - disToCenter1), float3(sizeV2*0.5, height, sizeU*0.5));
//
//	d = min(a1,a2);
//	d = min(d,a3);
//
//	re = min(re,d);
//}

float GetObjSDF(int inx, float3 p, in TraceInfo traceInfo)
{
float re = MaxTraceDis + 1; //Make sure default is an invalid SDF

//if(inx == 3)
//{
//	//1.check p is is the boundingBox
//	//2.if not ,just 'return re'
//	//3.if in, do nothing,wait for following calculating SDF
//	float3 center = float3(1.5,0,0.5);
//	float3 bound = float3(0.5,0.5,0.5);
//	float scale = 20;
//	if(!IsInBBox(p,center - scale*bound,center+scale*bound))
//	{
//		return re;
//	}
//}

//@@@SDFBakerMgr BeforeObjSDF
if(inx == 6 )
{
if (!IsInBBox(p, float3(-8.5, -10, -9.5), float3(11.5, 10, 10.5)))
{
return re;
}
}
//@@@
//___
//@@@SDFBakerMgr ObjSDF
if(inx == 0 )
{
re = min(re, 0 + SDFBox(p, float3(0, 0, 0), float3(0.05, 0.05, 0.05), float3(0, 0, 0)));
}
else if (inx == 1 )
{
float d = re;
float2 box = float2(0.05, 0.1);
Transform trans;
Init(trans);
trans.pos = float3(0.25, 0.1, 0.15);
trans.rotEuler = float3(0, 180, 180);
float2 spline[9];
spline[0] = float2(-0.05, 0);
spline[1] = float2(0.1, 0);
spline[2] = float2(0.4, 0);
spline[3] = float2(0.5, 0);
spline[4] = float2(0.5, -0.2);
spline[5] = float2(0.5, -0.35);
spline[6] = float2(0.36, -0.35);
spline[7] = float2(0.13, -0.3499999);
spline[8] = float2(0, -0.35);
FUNC_SDFBoxedQuadBezier(d, p, spline, 9, trans, box)
re = min(re,d);
}
else if (inx == 2 )
{
inx = -1;
}
else if (inx == 3 )
{
inx = -2;
}
else if (inx == 4 )
{
re = min(re, 0 + SDFBox(p, float3(1, 0, 1), float3(0.05, 0.05, 0.05), float3(0, 0, 0)));
}
else if (inx == 5 )
{
float d = re;
float2 box = float2(0.05, 0.1);
Transform trans;
Init(trans);
trans.pos = float3(0.25, 0.1, 0.85);
trans.rotEuler = float3(0, 0, 0);
float2 spline[9];
spline[0] = float2(-0.05, 0);
spline[1] = float2(0.1, 0);
spline[2] = float2(0.4, 0);
spline[3] = float2(0.5, 0);
spline[4] = float2(0.5, -0.2);
spline[5] = float2(0.5, -0.35);
spline[6] = float2(0.36, -0.35);
spline[7] = float2(0.13, -0.3499999);
spline[8] = float2(0, -0.35);
FUNC_SDFBoxedQuadBezier(d, p, spline, 9, trans, box)
re = min(re,d);
}
else if (inx == 6 )
{
p = WorldToLocal(p,float3(1, 0, 0),float3(0, 0, 0),float3(1, 1, 1));
float d = re;
SDFPrefab_ASCII_66(d,p);
d *= 1;
re = min(re,d);
}
else if (inx == 7 )
{
re = min(re, 0 + SDFBox(p, float3(0.284, 0.1, 0.5), float3(0.05, 0.1, 0.35), float3(0, 0, 0)));
}
//@@@
if(inx == -1)
{
	if(abs(p.x-eyePos.x)<300 && abs(p.z - eyePos.z)<300)
	{
		float d = abs(p.y);
		re = min(re,d);
	}
}
if(inx == -2)
{
	//idea:(us .cs to implement)
	//1.when a 'special' need to be Baked as a SDFPrefab
	//2.make sure autoCS has compiled, find ###BLOCK ObjSDF block where 'inx == specialID'
	//3.expcet comments, make sure only has one line code, find the funcName(SDFPrefab_ASCII_65),copy its source to SDFPrefabBaker,
	//make sure func params are in standard form
	//SDFPrefab_ASCII_65(re,p);
}

return re;
}

float3 GetObjSDFNormal(int inx, float3 p, in TraceInfo traceInfo, float eplisonScale = 1.0f)
{
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
inx = -1;
}
else if (inx == 3 )
{
inx = -2;
}
else if (inx == 4 )
{
}
else if (inx == 5 )
{
}
else if (inx == 6 )
{
}
else if (inx == 7 )
{
}
//@@@

return GetObjSDFNormal(inx, p, traceInfo);
}


float TraceScene(Ray ray, out HitInfo info)
{
	Init(info);

	TraceInfo traceInfo;
	Init(traceInfo,MaxSDF);
	while (traceInfo.traceCount <= MaxTraceTime)
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

		if (sdf > MaxTraceDis)
		{
			break;
		}

		if (sdf <= TraceThre)
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

	TraceInfo traceInfo;
	Init(traceInfo,MaxSDF);
	while (traceInfo.traceCount <= MaxTraceTime*0.01)
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
