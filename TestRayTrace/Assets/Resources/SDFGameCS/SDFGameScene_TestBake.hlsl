#define OBJNUM 7

#define MaxSDF 100000
#define MaxTraceDis 1000
#define MaxTraceTime 640
#define TraceThre 0.0001
#define NormalEpsilon 0.01

#define SceneSDFSoftShadowBias 0.1
#define SceneSDFShadowNormalBias 0.001
#define SceneSDFSoftShadowK 16

#include "../../HLSL/PBR/PBRCommonDef.hlsl"
#include "../../HLSL/PBR/PBR_IBL.hlsl"
#include "../../HLSL/PBR/PBR_GGX.hlsl"

#include "../../HLSL/Spline/SplineCommonDef.hlsl"
#include "../../HLSL/Noise/WoodNoise.hlsl"
#include "../../HLSL/UV/UVCommonDef.hlsl"
#include "../../HLSL/TransferMath/TransferMath.hlsl"
Texture2D pbrTex0albedo;
Texture2D pbrTex0normal;
Texture2D pbrTex0metallic;
Texture2D pbrTex0roughness;
Texture2D pbrTex0ao;

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
re.metallic = 1;
re.roughness = 0.4;
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
else if (obj == 5 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 6 )
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
int renderMode[7];
renderMode[0] = 3;
renderMode[1] = 2;
renderMode[2] = 0;
renderMode[3] = 0;
renderMode[4] = 2;
renderMode[5] = 2;
renderMode[6] = 2;
return renderMode[obj];
//@@@
}

void ObjPreRender(inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
if(mode == 2)
{
	//mat.albedo *= WoodColor(5*minHit.P);
	//minHit.N += float3(100,0,0);//WoodDisplacement(minHit.P);
	//minHit.N = float3(0,0,0);//normalize(minHit.N);
	//mat.albedo = WoodDisplacement(5*minHit.P);

	float3 pos = minHit.P;
	float3 tile = float3(1,1,1);
	float woodNEpsilon = NormalEpsilon;
	float3 T = float3(1,0,0);
	float3 B = float3(0,1,0);
	float3 N = float3(0,0,1);
	
	float3 woodN = normalize(float3(
		WoodDisplacement(tile * pos + woodNEpsilon*T) - WoodDisplacement(tile * pos - woodNEpsilon*T),
		WoodDisplacement(tile * pos + woodNEpsilon*B) - WoodDisplacement(tile * pos - woodNEpsilon*B),
		WoodDisplacement(tile * pos + woodNEpsilon*N) - WoodDisplacement(tile * pos - woodNEpsilon*N)
		));

	float normalIntensity = 0.2;
	woodN = normalize(normalIntensity * woodN + minHit.N);

	mat.albedo *= WoodColor(tile*pos);
	minHit.N = woodN;

	mode = 0;
}
else if(mode == 3)
{
	float3 pos = minHit.P;
	float2 uv = BoxedUV(pos,float3(0, 2, 0), float3(1, 1, 1), float3(0, 0, 0));
	//uv = frac(uv*5);

	mat.albedo *= pbrTex0albedo[4096*uv].rgb;
	float3 N = minHit.N;
	float3 T,B;
	//basis(N,T,B);
	BoxedTB(T,B, pos,float3(0, 2, 0), float3(1, 1, 1), float3(0, 0, 0));
	minHit.N = NormalMapToWorld(pbrTex0normal[4096*uv].rgb,T,B,N);
	//mat.albedo = minHit.N;
	mat.metallic *= pbrTex0metallic[4096*uv].r;
	mat.roughness *= pbrTex0roughness[4096*uv].r;
	mat.ao = pbrTex0ao[4096*uv].r;

	mode = 0;
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
lightDirs[0] = float3(-0.302018, -0.8447005, 0.4418894);
lightColors[0] = float3(1, 1, 1);
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
lightDirs[0] = float3(-0.302018, -0.8447005, 0.4418894);
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
else if (inx == 5 )
{
re = min(re, 0 + SDFBox(p, float3(-0.321, 1.74, -4.38), float3(0.07071167, 1.511707, 0.06462751), float3(7.817626, 71.39999, -1.723566E-06)));
}
else if (inx == 6 )
{
re = min(re, 0 + SDFBox(p, float3(0.14, 1.74, -5.75), float3(0.07071167, 1.511707, 0.06462751), float3(7.817626, 71.39999, -1.723566E-06)));
}
	//@@@
	if(inx == -1)
	{
		//float trunkBox = SDFBox(p, float3(0, 2, 0), float3(0.2, 2, 0.2), float3(0, 0, 0));
		float sbox = SDFBox(p, float3(0, 2, 0), float3(1, 1, 1), float3(0, 0, 0));
		re = min(re, sbox );
		//re = min(re, trunkBox );
		//re = min(re, SDFSphere(p, float3(0, 2, 0), 1) );
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
	while (traceCount <= MaxTraceTime*0.25)
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
