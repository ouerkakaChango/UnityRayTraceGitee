#define OBJNUM 8

#define MaxSDF 100000
#define MaxTraceDis 100
#define MaxTraceTime 6400
#define TraceThre 0.001
#define NormalEpsilon 0.001

#define SceneSDFShadowNormalBias 0.2

#define SceneSDFSoftShadowBias 0.1
#define SceneSDFSoftShadowK 16

#include "../../HLSL/PBR/PBRCommonDef.hlsl"
#include "../../HLSL/PBR/PBR_IBL.hlsl"
#include "../../HLSL/PBR/PBR_GGX.hlsl"

#include "../../HLSL/Spline/SplineCommonDef.hlsl"
#include "../../HLSL/Noise/WoodNoise.hlsl"
#include "../../HLSL/Noise/TerrainNoise.hlsl"
#include "../../HLSL/UV/UVCommonDef.hlsl"
#include "../../HLSL/TransferMath/TransferMath.hlsl"
#include "../../HLSL/Random/RandUtility.hlsl"
#include "../../HLSL/Transform/TransformCommonDef.hlsl"
#include "../../HLSL/SDFGame/SDFCommonDef.hlsl"
#include "../../HLSL/SDFGame/SDFGridObjects.hlsl"
#include "../../HLSL/Spline/QuadBezier/QuadBezier.hlsl"
Texture2D woodPBR_albedo;
Texture2D woodPBR_normal;
Texture2D woodPBR_metallic;
Texture2D woodPBR_roughness;
Texture2D woodPBR_ao;

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
re.roughness = 1;
}
else if (obj == 1 )
{
re.albedo = float3(0.7254902, 0.4784314, 0.3411765);
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
re.roughness = 1;
}
else if (obj == 4 )
{
re.albedo = float3(0, 1, 0.1720126);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 5 )
{
re.albedo = float3(0, 0.3212323, 1);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 6 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 0.2;
}
else if (obj == 7 )
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
int renderMode[8];
renderMode[0] = 2;
renderMode[1] = 0;
renderMode[2] = 2;
renderMode[3] = 2;
renderMode[4] = 0;
renderMode[5] = 0;
renderMode[6] = 0;
renderMode[7] = 2;
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
inx = -2;
}
else if (inx == 2 )
{
}
else if (inx == 3 )
{
}
else if (inx == 4 )
{
inx = -3;
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
{//???
	float3 pos = minHit.P;
	float3 boxPos = float3(-55,0.6,-52);
	float3 boxBound = 0.5;
	//float3 boxPos = float3(0,2,0);
	float2 uv = BoxedUV(pos,boxPos, boxBound, float3(0, 0, 0));

	//mat.albedo = minHit.N;
	mat.albedo *= woodPBR_albedo[4096*uv].rgb;
	float3 N = minHit.N;
	float3 T,B;
	BoxedTB(T,B, pos,boxPos, boxBound, float3(0, 0, 0));
	minHit.N = NormalMapToWorld(woodPBR_normal[4096*uv].rgb*2-1,T,B,N);
	//minHit.N = NormalMapToWorld(float3(0,0,1),T,B,N);

	//mat.albedo = woodPBR_normal[4096*uv].rgb;
	mat.metallic *= woodPBR_metallic[4096*uv].r;
	mat.roughness *= woodPBR_roughness[4096*uv].r;
	mat.ao = woodPBR_ao[4096*uv].r;

	mode = 0;
}

//??? grass color vary
if(inx == -3)
{
	//### grid grass
	float grid = 0.1;
	float2 m = floor(minHit.P.xz/grid);
	float2 c = grid*(m+0.5);

	int pattern = 1;
	if(pattern == 1)
	{
		//tube shape,2 colors
		float randK = perlinNoiseFromTex(0.005 * c);//cos(dot(float2(-1,0.5), 0.01*c)+PI);//rand01(float3(34, 23, 123) * 50 + float3(c.x,0,c.y) * 5);
		float ori = randK;
		randK = pow(randK,4.5);
		randK = randK<0.1 ? 0:1;
		float3 c1 = float3(1,0,0);
		float3 c2 = float3(1,1,0);
		mat.albedo = lerp(c1,c2,randK);
	}
	else if (pattern == 2)
	{
		float randK = cos(dot(float2(-1,0.5), 10*c)+PI) * cos(dot(float2(0.5,-1), 10*c)+PI); //perlinNoiseFromTex(0.005 * c);//
		//randK = pow(randK,2);
		float3 color = HSVToRGB(float3(randK,1,1));
		mat.albedo = color;
	}
	else if (pattern == 3)
	{
		float randK = voronoiNoiseFromTex(0.005 * c);
		randK = pow(randK,4);
		randK = randK<0.2 ? 0:1;
		float3 c1 = float3(1,0,0);
		float3 c2 = float3(1,1,0);
		mat.albedo = lerp(c1,c2,randK);
	}
	else if (pattern ==4)
	{
		float3 color = HSVToRGB(float3(frac(_Time.y*2),1,1));
		mat.albedo = color;
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
lightDirs[0] = float3(0.3534208, -0.4141579, -0.8387889);
lightColors[0] = float3(1, 1, 1);
result = 0.04 * mat.albedo * mat.ao;
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
if(true)
{
//@@@SDFBakerMgr DirShadow
float3 lightDirs[1];
lightDirs[0] = float3(0.3534208, -0.4141579, -0.8387889);
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

float GetObjSDF(int inx, float3 p, in TraceInfo traceInfo)
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
re = min(re, 0 + SDFBox(p, float3(-53.40586, -0.02504057, -55.8854), float3(0.07071168, 1.511707, 0.0646275), float3(338.16, 349.3067, -2.989319E-06)));
}
else if (inx == 1 )
{
inx = -2;
}
else if (inx == 2 )
{
re = min(re, 0 + SDFBox(p, float3(-53.255, -0.1510001, -56.684), float3(0.07071169, 1.511707, 0.06462751), float3(10.90515, 349.3067, -2.608424E-06)));
}
else if (inx == 3 )
{
re = min(re, 0 + SDFBox(p, float3(-54.646, -0.1510001, -56.947), float3(0.07071169, 1.511707, 0.06462751), float3(10.90515, 349.3067, -2.608424E-06)));
}
else if (inx == 4 )
{
inx = -3;
}
else if (inx == 5 )
{
float d = re;
float2 box = float2(0.1, 0.05);
Transform trans;
Init(trans);
trans.pos = float3(-54.05, 0.35, -55.925);
trans.rotEuler = float3(357.9441, 89.12995, 68.08731);
float2 spline[3];
spline[0] = float2(0, 0);
spline[1] = float2(0.24, 0.63);
spline[2] = float2(0.53, 0);
FUNC_SDFBoxedQuadBezier(d, p, spline, 3, trans, box)
re = min(re,d);
}
else if (inx == 6 )
{
re = min(re, 0 + SDFBox(p, float3(-54.05, 0.35, -56.16), float3(0.745, 1.11, 0.025), float3(338.16, 349.3067, -2.989319E-06)));
}
else if (inx == 7 )
{
re = min(re, 0 + SDFBox(p, float3(-54.76603, -0.02504051, -56.14224), float3(0.07071168, 1.511707, 0.0646275), float3(338.16, 349.3067, -2.989319E-06)));
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
	else if(inx == -2)
	{
		float terrain = 100000;
		if(abs(p.x-eyePos.x)<300 && abs(p.z - eyePos.z)<300)
		{
			//### fbm flaw effect.###
			//###can only used for low height effect,and no sdf shadow, because trace it by height func is not right.
			//###but for low height effect, this flaw may be accepted
			//terrain -= 0.1*smoothstep(0.4f, 0.8f, fbm4(float3(p.xz+0.3,0)));

			//terrain = abs(p.y);

			//Terrain Main
			terrain = CosFBM(p.xz);

			//Detail
			if(traceInfo.lastTrace<0.15)
			{
				terrain -= 0.1 * fbm4(float3(5 * p.xz,0));
				//terrain -= 0.1*smoothstep(0.4f, 0.8f, fbm4(float3(5 * p.xz,0)));
				//terrain -= 0.0001 * CosFBM(1000 * p.xz);
				//terrain -= 25 * TerrainDetailNoise(p.xz);
				//terrain -= 0.01 * TerrainDetailNoise(1000*p.xz);
			}

			terrain = abs(p.y - terrain);
			terrain *= 0.5;
		}
		re = min(re, terrain );
	}
	else if(inx == -3)
	{
		if(abs(p.x-eyePos.x)<300 && abs(p.z - eyePos.z)<300 && traceInfo.lastTrace<5)
		{
			//### grid grass
			float grid = 0.1;
			float2 m = floor(p.xz/grid);
			float2 c = grid*(m+0.5);
			float3 center = float3(c.x,CosFBM(c),c.y);
			float d = SDFGridGrass(p,center,grid);
			re = min(re,d);

			//### near dir
			//float2 c2 = c+grid*float2(1,0);
			//center = float3(c2.x,CosFBM(c2),c2.y);
			//d = SDFGridGrass(p,center, grid);
			//re = min(re,d);
			//
			//c2 = c+grid*float2(-1,0);
			//center = float3(c2.x,CosFBM(c2),c2.y);
			//d = SDFGridGrass(p,center, grid);
			//re = min(re,d);
			//
			//c2 = c+grid*float2(0,1);
			//center = float3(c2.x,CosFBM(c2),c2.y);
			//d = SDFGridGrass(p,center, grid);
			//re = min(re,d);
			//
			//c2 = c+grid*float2(0,-1);
			//center = float3(c2.x,CosFBM(c2),c2.y);
			//d = SDFGridGrass(p,center, grid);
			//re = min(re,d);
			//
			//c2 = c+grid*float2(1,1);
			//center = float3(c2.x,CosFBM(c2),c2.y);
			//d = SDFGridGrass(p,center, grid);
			//re = min(re,d);
			//
			//c2 = c+grid*float2(1,-1);
			//center = float3(c2.x,CosFBM(c2),c2.y);
			//d = SDFGridGrass(p,center, grid);
			//re = min(re,d);
			//
			//c2 = c+grid*float2(-1,1);
			//center = float3(c2.x,CosFBM(c2),c2.y);
			//d = SDFGridGrass(p,center, grid);
			//re = min(re,d);
			//
			//c2 = c+grid*float2(-1,-1);
			//center = float3(c2.x,CosFBM(c2),c2.y);
			//d = SDFGridGrass(p,center, grid);
			//re = min(re,d);
			
			//re *= 0.2;
		}
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
inx = -2;
}
else if (inx == 2 )
{
}
else if (inx == 3 )
{
}
else if (inx == 4 )
{
inx = -3;
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
if (inx == -2)
{//???
	return GetObjSDFNormal(inx, p, traceInfo);
	float2 dxy = CosFBM_Dxy(p.xz);
	return normalize(float3(-dxy.x,1,-dxy.y));
}
else if (inx == -3)
{
//???
	//return float3(0,1,0);
	return GetObjSDFNormal(inx, p, traceInfo);
	//float grid = 0.1.0;
	//float2 m = floor(p.xz/grid);
	//float2 c = grid*m+grid*0.5;
	//float3 center = float3(c.x,CosFBM(c),c.y);
	//float3 ori = center;
	//center.y += rand01(float3(34,23,123)+ori*0.1)*2 * Time01(5,ori.y);
	//return normalize(p-center);
}
else
{
	return GetObjSDFNormal(inx, p, traceInfo);
}
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
