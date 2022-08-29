#define OBJNUM 10

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
#include "../SDFGamePrefab/font_prefab.hlsl"

//@@@SDFBakerMgr TexSys
Texture2D<float> slice_whiteboardText;
//@@@

//@@@SDFBakerMgr DyValSys
float dy_radius;
float test2;
//@@@

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
re.albedo = float3(0, 0, 0);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 2 )
{
re.albedo = float3(1, 0, 0);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 3 )
{
re.albedo = float3(0.7254902, 0.4784314, 0.3411765);
re.metallic = 0;
re.roughness = 1;
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
re.albedo = float3(0, 1, 0.1720126);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 7 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 0.2;
}
else if (obj == 8 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 1;
}
else if (obj == 9 )
{
re.albedo = float3(0.8587747, 0, 1);
re.metallic = 0;
re.roughness = 1;
}
	//@@@
	return re;
}

int GetObjRenderMode(int obj)
{
//@@@SDFBakerMgr ObjRenderMode
int renderMode[10];
renderMode[0] = 2;
renderMode[1] = 0;
renderMode[2] = 0;
renderMode[3] = 0;
renderMode[4] = 2;
renderMode[5] = 2;
renderMode[6] = 0;
renderMode[7] = 0;
renderMode[8] = 2;
renderMode[9] = 0;
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
inx = -3;
}
else if (inx == 7 )
{
}
else if (inx == 8 )
{
}
else if (inx == 9 )
{
inx = -4;
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
//else if(mode == 3)
//{//???
//	float3 pos = minHit.P;
//	float3 boxPos = float3(-55,0.6,-52);
//	float3 boxBound = 0.5;
//	//float3 boxPos = float3(0,2,0);
//	float2 uv = BoxedUV(pos,boxPos, boxBound, float3(0, 0, 0));
//
//	//mat.albedo = minHit.N;
//	mat.albedo *= woodPBR_albedo[4096*uv].rgb;
//	float3 N = minHit.N;
//	float3 T,B;
//	BoxedTB(T,B, pos,boxPos, boxBound, float3(0, 0, 0));
//	minHit.N = NormalMapToWorld(woodPBR_normal[4096*uv].rgb*2-1,T,B,N);
//	//minHit.N = NormalMapToWorld(float3(0,0,1),T,B,N);
//
//	//mat.albedo = woodPBR_normal[4096*uv].rgb;
//	mat.metallic *= woodPBR_metallic[4096*uv].r;
//	mat.roughness *= woodPBR_roughness[4096*uv].r;
//	mat.ao = woodPBR_ao[4096*uv].r;
//
//	mode = 0;
//}

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
//###
float re = MaxTraceDis + 1; //Make sure default is an invalid SDF
//@@@SDFBakerMgr BeforeObjSDF
if(inx == 7||inx == 4||inx == 5||inx == 0||inx == 8||inx == 1)
{
if (!IsInBBox(p, float3(-56.05, -1.65, -58.16), float3(-52.05, 2.35, -54.16)))
{
return SDFBox(p, float3(-54.05, 0.35, -56.16), float3(2, 2, 2)) + 0.1;
}
}
//@@@
//@@@SDFBakerMgr ObjSDF
if(inx == 0 )
{
re = min(re, 0 + SDFBox(p, float3(-53.40586, -0.02504057, -55.8854), float3(0.07071168, 1.511707, 0.0646275), float3(338.16, 349.3067, -2.989319E-06)));
}
else if (inx == 1 )
{
float3 localp = WorldToLocal(p, float3(-54.065, 0.378, -56.136), float3(291.8169, 168.0358, 1.048534), float3(1.5, 1.5, 1.5));
float dh = abs(localp.y) - 0.03;
dh = dh > 0 ? dh : 0;
dh *= 1.5;

float d = re;
float d2d = re;
float2 picBound = float2(0.5, 0.5) * 1.5;
float2 p2d = localp.xz * 1.5;
if (gtor(abs(p2d), picBound))
{
d2d = SDFBox(p2d, 0, picBound) + TraceThre * 2;
d = sqrt(d2d * d2d + dh * dh);
}
else
{
float2 uv = p2d / picBound;
uv = (uv + 1) * 0.5;
uint2 picSize = GetSize(slice_whiteboardText);
float sdfFromPic = slice_whiteboardText.SampleLevel(common_linear_repeat_sampler, uv, 0).r;
sdfFromPic /= picSize.x * 0.5 * sqrt(2) * 1.5;
sdfFromPic *= picBound.x;
d2d = sdfFromPic;
d2d += 0;
d2d = max(d2d,0);
d = sqrt(d2d * d2d + dh * dh);
d += 0;
}
re = min(re, d);
}
else if (inx == 2 )
{
re = min(re, 0 + SDFBox(p, float3(-53.6709, 0.016, -55.9093), float3(0.04, 0.005, 0.0136015), float3(338.16, 349.307, 90)));
}
else if (inx == 3 )
{
inx = -2;
}
else if (inx == 4 )
{
re = min(re, 0 + SDFBox(p, float3(-53.255, -0.1510001, -56.684), float3(0.07071169, 1.511707, 0.06462751), float3(10.90515, 349.3067, -2.608424E-06)));
}
else if (inx == 5 )
{
re = min(re, 0 + SDFBox(p, float3(-54.646, -0.1510001, -56.947), float3(0.07071169, 1.511707, 0.06462751), float3(10.90515, 349.3067, -2.608424E-06)));
}
else if (inx == 6 )
{
inx = -3;
}
else if (inx == 7 )
{
re = min(re, 0 + SDFBox(p, float3(-54.05, 0.35, -56.16), float3(0.745, 1.11, 0.025), float3(338.16, 349.3067, -2.989319E-06)));
}
else if (inx == 8 )
{
re = min(re, 0 + SDFBox(p, float3(-54.76603, -0.02504051, -56.14224), float3(0.07071168, 1.511707, 0.0646275), float3(338.16, 349.3067, -2.989319E-06)));
}
else if (inx == 9 )
{
inx = -4;
}
//@@@
if(inx == -1)
{
	//float trunkBox = SDFBox(p, float3(0, 2, 0), float3(0.2, 2, 0.2), float3(0, 0, 0));
	//float sbox = SDFBox(p, float3(0, 2, 0), float3(1, 1, 1), float3(0, 0, 0));
	//re = min(re, sbox );
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
else if (inx == -4)
{
	//float dy_radius = Time01();
	float r = dy_radius;
	float d = SDFSphere(p,float3(-60.05, 0.35, -56.16),r);
	re = min(re, d);
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
inx = -3;
}
else if (inx == 7 )
{
}
else if (inx == 8 )
{
}
else if (inx == 9 )
{
inx = -4;
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


void TraceScene(Ray ray, out HitInfo info)
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
//bool bInGrassRange = false;
//if(abs(ray.pos.x-eyePos.x)<300 && abs(ray.pos.z - eyePos.z)<300)
//{
//	float terrain = CosFBM(ray.pos.xz);
//	terrain = abs(ray.pos.y - terrain);
//	if(terrain<0.1)
//	{
//		bInGrassRange = true;
//	}
//}
//if (bInGrassRange)
//{
//	bInnerBound = true;
//	innerBoundFlag[2] = true;
//	innerBoundFlag[0] = true;
//}

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
