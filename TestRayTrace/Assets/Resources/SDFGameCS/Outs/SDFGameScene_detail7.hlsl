#define OBJNUM 2

#define MaxSDF 100000
#define MaxTraceDis 100
#define MaxTraceTime 6400
#define TraceThre 0.001
#define NormalEpsilon 0.001
#define SoftShadowK 3

#include "../../../HLSL/PBR/PBRCommonDef.hlsl"
#include "../../../HLSL/PBR/PBR_IBL.hlsl"
#include "../../../HLSL/PBR/PBR_GGX.hlsl"
#include "../../../HLSL/UV/UVCommonDef.hlsl"
#include "../../../HLSL/RayMath.hlsl"

#include "../../../HLSL/Random/RandUtility.hlsl"
#include "../../../HLSL/Noise/NoiseCommonDef.hlsl"
#include "../../../HLSL/Transform/TransformCommonDef.hlsl"
#include "../../../HLSL/SDFGame/SDFCommonDef.hlsl"
#include "../../../HLSL/MatLib/CommonMatLib.hlsl"
#include "../../../HLSL/MatLib/Ocean.hlsl"

//@@@SDFBakerMgr TexSys
Texture3D<float> SDF_terrain;
Texture2D<float4> Arrow;
Texture2D<float3> Rocks_albedo;
Texture2D<float3> Rocks_normal;
Texture2D<float> Rocks_metallic;
Texture2D<float> Rocks_roughness;
Texture2D<float> Rocks_ao;
Texture2D<float> Rocks_height;
Texture2D<float3> mud_ground_albedo;
Texture2D<float3> mud_ground_normal;
Texture2D<float> mud_ground_metallic;
Texture2D<float> mud_ground_roughness;
Texture2D<float> mud_ground_ao;
Texture2D<float> mud_ground_height;
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

int GetSpecialID(int inx);

Material_PBR GetObjMaterial_PBR(int obj)
{
	Material_PBR re;
	Init(re);

//@@@SDFBakerMgr ObjMaterial
if(obj == 0 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 1;
re.roughness = 1;
re.reflective = 0;
re.reflect_ST = float2(0.5, 0.5);
}
else if (obj == 1 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 1;
re.roughness = 1;
re.reflective = 0;
re.reflect_ST = float2(0.5, 0.5);
}
//@@@
	return re;
}

int GetObjRenderMode(int obj)
{
//@@@SDFBakerMgr ObjRenderMode
int renderMode[2];
renderMode[0] = 0;
renderMode[1] = 0;
return renderMode[obj];
//@@@
}

float2 GetObjPreUV(int inx, float3 p)
{
	float2 uv = 0;
	//@@@SDFBakerMgr ObjPreUV
if(inx == 0 )
{
uv = BoxedUV(p, float3(0, 0.776, 0), float3(0.5, 0.5, 0.5), float3(0, 0, 0));
return uv;
}
else if (inx == 1 )
{
}
	//@@@
	//if(inx == 0 )
	//{
	//	uv = BoxedUV(p, float3(0, 1.9, 0), float3(0.5, 0.5, 0.5), float3(0, 0, 0));
	//	return uv;
	//}
return uv;
}

float2 GetObjUV(in HitInfo minHit)
{
	float2 uv = 0;
	int inx = minHit.obj;
	//@@@SDFBakerMgr ObjUV
if(inx == 0 )
{
uv = BoxedUV(minHit.P, float3(0, 0.776, 0), float3(0.5, 0.5, 0.5), float3(0, 0, 0));
return uv;
}
else if (inx == 1 )
{
}
	//@@@

	inx = GetSpecialID(inx);
	if(inx == -1)
	{
		//uv = SimpleUVFromPos(minHit.P,minHit.N, float3(1,1,1));
		uv = minHit.P.xz;
	}
return uv;
}

void GetObjTB(inout float3 T, inout float3 B, in HitInfo minHit)
{
	int inx = minHit.obj;
	T=0;
	B=0;
//@@@SDFBakerMgr ObjTB
if(inx == 0 )
{
BoxedTB(T,B,minHit.P, float3(0, 0.776, 0), float3(0.5, 0.5, 0.5), float3(0, 0, 0));
return;
}
if(inx == 1 )
{
}
//@@@
inx = GetSpecialID(inx);
	if(inx == -1)
	{
		T = float3(1,0,0);
		B = float3(0,0,1);
		return;
	}
basis_unstable(minHit.N, T, B);
}

void ObjPreRender(inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
int inx = minHit.obj;
//@@@SDFBakerMgr ObjMatLib
if(inx==0)
{
	float2 uv = GetObjUV(minHit);
uv = float2(1, 1)*uv+float2(0, 0);
	mat.albedo *= SampleRGB(Rocks_albedo, uv);
	mat.ao *= SampleR(Rocks_ao, uv);
	mat.metallic *= SampleR(Rocks_metallic, uv);
	mat.roughness *= SampleR(Rocks_roughness, uv);
float3 T,B;
	GetObjTB(T,B, minHit);
	minHit.N = SampleNormalMap(Rocks_normal, uv, minHit.N,T,B,1);
}
if(inx==1)
{
	float2 uv = GetObjUV(minHit);
uv = float2(0.1, 0.1)*uv+float2(0, 0);
	mat.albedo *= SampleRGB(mud_ground_albedo, uv);
	mat.ao *= SampleR(mud_ground_ao, uv);
	mat.metallic *= SampleR(mud_ground_metallic, uv);
	mat.roughness *= SampleR(mud_ground_roughness, uv);
float3 T,B;
	GetObjTB(T,B, minHit);
	minHit.N = SampleNormalMap(mud_ground_normal, uv, minHit.N,T,B,1);
}
//@@@


inx = GetSpecialID(inx);
if(inx== -1)
{
	float2 uv = 0.1*minHit.P.xz;
			float tr = SampleR(perlinNoise1,uv);
			if(tr<0.2)
			{
				mat.albedo = 0.1;
				mat.roughness = 1;
				mat.metallic = 0;
			}
}
//@@@SDFBakerMgr ObjImgAttach

//@@@

inx = GetSpecialID(inx);

}

void ObjPostRender(inout float3 result, inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
}

float3 RenderSceneObj(Ray ray, inout HitInfo minHit, inout Material_PBR mat)
{
	int mode = GetObjRenderMode(minHit.obj);
	ObjPreRender(mode, mat, ray, minHit);
	float3 result = 0;
//@@@SDFBakerMgr ObjRender
if(mode==0)
{
float3 lightDirs[1];
float3 dirLightColors[1];
lightDirs[0] = float3(-0.3213938, -0.7660444, 0.5566705);
dirLightColors[0] = float3(8, 8, 8);
result.rgb = 0.03 * mat.albedo * mat.ao;
for(int i=0;i<1;i++)
{
result.rgb += PBR_GGX(mat, minHit.N, -ray.dir, -lightDirs[i], dirLightColors[i]);
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
	//bool isPNGEnv=false;
	//Texture2DArray tempEnv;
	//GetEnvTexArrByObj(minHit.obj, isPNGEnv, tempEnv);
	//if(isPNGEnv)
	//{
	//	result = PBR_IBL(tempEnv, mat, minHit.N, -ray.dir,1,1,true,true);
	//}
	//else
	//{
	//	result = PBR_IBL(tempEnv, mat, minHit.N, -ray.dir);
	//}
}
else if (mode == 333)
{
	float3 lightPos = float3(0,4,0);
	float3 lightColor = float3(1,1,1);
	float3 l = normalize(lightPos - minHit.P);
	result = PBR_GGX(mat, minHit.N, -ray.dir, l, lightColor);
}
else if (mode == 1000)
{
	result = mat.albedo;
}
else if (mode == 1001)
{
	result = minHit.N;
}
else if (mode == 1002)
{
	float3 T,B;
	GetObjTB(T, B, minHit);
	result = T;
}
else
{
	result = float3(1,0,1);
}

int inx = GetSpecialID(minHit.obj);

	ObjPostRender(result, mode, mat, ray, minHit);
	return result;
}


float HardShadow_TraceScene(Ray ray, out HitInfo info, float maxLength = MaxSDF, bool expensive = false);
float SoftShadow_TraceScene(Ray ray, out HitInfo info, float maxLength = MaxSDF, int method = 1);

float GetDirHardShadow(float3 lightDir, in HitInfo minHit, float maxLength = MaxSDF)
{
	Ray ray;
	ray.pos = minHit.P;
	ray.dir = -lightDir;
	ray.pos += ray.dir*TraceThre*2 + minHit.N*TraceThre*2;
	HitInfo hitInfo;
	return HardShadow_TraceScene(ray, hitInfo, maxLength, false);
}

float GetDirSoftShadow(float3 lightDir, in HitInfo minHit, float maxLength = MaxSDF)
{
	Ray ray;
	ray.pos = minHit.P;
	ray.dir = -lightDir;
	ray.pos += ray.dir*TraceThre*2 + minHit.N*TraceThre*2;
	HitInfo hitInfo;
	return SoftShadow_TraceScene(ray, hitInfo, maxLength);
}

float RenderSceneSDFShadow(HitInfo minHit)
{
	float sha = 1;
int inx = GetSpecialID(minHit.obj);
if(true)
{
//@@@SDFBakerMgr DirShadow
int lightType[1];
lightType[0] = 0;
float3 lightPos[1];
lightPos[0] = float3(0, 3, 0);
float3 lightDirs[1];
lightDirs[0] = float3(-0.3213938, -0.7660444, 0.5566705);
int shadowType[1];
shadowType[0] =1;
float lightspace = 1;
float maxLength = MaxSDF;
float tsha = 1;
for (int i = 0; i < 1; i++)
{
float maxLength = MaxSDF;
if(lightType[i]==0)
{
maxLength = MaxSDF;
}
if(lightType[i]==1)
{
maxLength = length(minHit.P - lightPos[i]);
}
if(lightType[i]<0)
{
tsha = 1;
}
else
{
if(shadowType[i]==0)
{
tsha = GetDirHardShadow(lightDirs[i], minHit, maxLength);
}
if(shadowType[i]==1)
{
tsha = GetDirSoftShadow(lightDirs[i], minHit, maxLength);
}
}
lightspace -= (1 - tsha);
}
lightspace /= 1;
sha = lightspace;
//@@@
}
return sha;
}

float3 RenderSceneAdditionalColor(in Ray ray, in HitInfo minHit, in Material_PBR mat)
{
	float3 result = 0;
//@@@SDFBakerMgr FullAddLightInfo
const static int lightType[1] = {1};
const static float3 lightColor[1] = {float3(0, 5.362015, 20)};
const static float3 lightPos[1] = {float3(-3.88, 1.53, 0.17)};
const static float3 lightDirs[1] = {float3(0, 0, 0)};
const static int shadowType[1] = {-2};
const static float lightspace = 1;
//@@@
	result.rgb = 0.03 * mat.albedo * mat.ao;
for(int i=0;i<lightspace;i++)
{
		float atten = 1;
		float3 lightDir = lightDirs[i];
		if(lightType[i]==1)
		{
			atten = PntLightAtten(minHit.P,lightPos[i]);
			lightDir = normalize(minHit.P - lightPos[i]);
		}
result.rgb += atten * PBR_GGX(mat, minHit.N, -ray.dir, -lightDir, lightColor[i]);
}

	return result;
}

//###################################################################################
#include "../../../HLSL/SDFGame/SDFCommonDef.hlsl"
#include "../../../HLSL/Noise/NoiseCommonDef.hlsl"

//tutorial: iq modeling https://www.youtube.com/watch?v=-pdSjBPH3zM

//change from https://iquilezles.org/articles/distfunctions/
float3 opCheapBend_XY( float3 p , in float3 center, float k=10.0f)
{
	p -= center;
float c = cos(k*p.x);
float s = sin(k*p.x);
float2x2 m = {c,-s,s,c};
return float3(mul(m,p.xy),p.z)+center;
}

float opSmoothSubtraction( float d1, float d2, float k =1.0f) {
float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
return lerp( d2, -d1, h ) + k*h*(1.0-h); }

float GetObjSDF(int inx, float3 p, in TraceInfo traceInfo)
{
//###
float re = MaxTraceDis + 1; //Make sure default is an invalid SDF
//@@@SDFBakerMgr BeforeObjSDF
//@@@
//@@@SDFBakerMgr ObjSDF
if(inx == 0 )
{
float3 center = float3(0, 0.776, 0);
float3 bound = float3(0.5, 0.5, 0.5);
float3 rot = float3(0, 0, 0);
float offset = 0;
offset = -0.08*SampleR(Rocks_height, GetObjPreUV(inx,p));
float d = offset + SDFBox(p,center,bound, rot);
d*=0.2;
re = min(re,d);
}
else if (inx == 1 )
{
inx = -1;
}
//@@@

if(inx == -1)
{
	if(IsInBBox(p,eyePos - 300,eyePos+300))
	{
		//float height = 3*sin(p.x);
		float height =0;
		float k=0.5;
		if(traceInfo.lastTrace<1.5)
		{
			float2 uv = 0.1*p.xz;
			//height += 0.2*SampleR(mud_ground_height,uv,0);
			float tr = SampleR(perlinNoise1,uv);
			if(tr<0.2)
			{
				height += clamp(0.8*SampleR(Rocks_height, uv, 0),0.01,0.3);
				k=0.1;
			}
			else
			{
				height += 0.2*SampleR(mud_ground_height,uv,0);
			}
		}

		//re = 0.5*abs(p.y-height);
		//SDF_terrain
		float mainh = 4*sin(0.01*p.x)+2*sin(0.02*p.z);
		mainh += 2*sin(0.02*p.x)+1*sin(0.04*p.z);
		mainh += 1*sin(0.04*p.x)+0.5*sin(0.08*p.z);
		mainh += 0.5*sin(0.08*p.x)+0.25*sin(0.16*p.z);
		//float mainh = 5*fbm4(float3(p.x,0,p.z));
		re = abs(p.y - mainh);//abs(p.y);//SDFTex3D(p,0,25,0, SDF_terrain, TraceThre);
		re = re - height;
		re *=k;
	}
}

return re;
}

//https://iquilezles.org/articles/normalsSDF/
float3 GetObjSDFNormal(int inx, float3 p, in TraceInfo traceInfo, float eplisonScale = 1.0f)
{
	float normalEpsilon = NormalEpsilon;

	//return normalize(float3(
	//	GetObjSDF(inx, float3(p.x + NormalEpsilon*eplisonScale, p.y, p.z), traceInfo) - GetObjSDF(inx, float3(p.x - NormalEpsilon*eplisonScale, p.y, p.z), traceInfo),
	//	GetObjSDF(inx, float3(p.x, p.y + NormalEpsilon*eplisonScale, p.z), traceInfo) - GetObjSDF(inx, float3(p.x, p.y - NormalEpsilon*eplisonScale, p.z), traceInfo),
	//	GetObjSDF(inx, float3(p.x, p.y, p.z + NormalEpsilon*eplisonScale), traceInfo) - GetObjSDF(inx, float3(p.x, p.y, p.z - NormalEpsilon*eplisonScale), traceInfo)
	//	));

	float h = NormalEpsilon*eplisonScale; // replace by an appropriate value
const float2 k = float2(1,-1);
return normalize( k.xyy*GetObjSDF(inx, p + k.xyy*h, traceInfo) +
k.yyx*GetObjSDF(inx, p + k.yyx*h, traceInfo) +
k.yxy*GetObjSDF(inx, p + k.yxy*h, traceInfo) +
k.xxx*GetObjSDF(inx, p + k.xxx*h, traceInfo) );
}

float3 GetObjNormal(int inx, float3 p, in TraceInfo traceInfo)
{
	inx = GetSpecialID(inx);
	//@@@SDFBakerMgr ObjNormal
if(inx == 0 )
{
}
else if (inx == 1 )
{
}
	//@@@
	if(inx == -1)
	{
		//return GetObjSDFNormal(inx, p, traceInfo, 1000);
	}
	return GetObjSDFNormal(inx, p, traceInfo);
}


void TraceScene(Ray ray, out HitInfo info)
{
	float traceThre = TraceThre;



	Init(info);

	TraceInfo traceInfo;
	Init(traceInfo);
	float3 oriPos = ray.pos;

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
		traceInfo.traceSum = length(ray.pos - oriPos);
	}
}

float HardShadow_TraceScene(Ray ray, out HitInfo info, float maxLength, bool expensive)
{
	Init(info);

	TraceInfo traceInfo;
	Init(traceInfo);
	float3 oriPos = ray.pos;

	float objSDF[OBJNUM];
	bool innerBoundFlag[OBJNUM];
	float innerBoundStepScale[OBJNUM];
	int objInx = -1;
	float sdf = MaxSDF;
	bool bInnerBound = false;

	while (traceInfo.traceCount <= MaxTraceTime*(expensive?1:0.01))
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
				if(GetSpecialID(inx)<0)
				{
					continue;
				}
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

		if (sdf > MaxTraceDis*(expensive?1:0.1))
		{
			return 1;
			break;
		}

		if (sdf <= TraceThre)
		{
			info.bHit = true;
			info.obj = objInx;
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		Update(traceInfo,sdf);
		traceInfo.traceSum = length(ray.pos - oriPos);

		if(traceInfo.traceSum>maxLength)
		{
			break;
		}
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
//https://www.shadertoy.com/view/lsKcDD
float SoftShadow_TraceScene(Ray ray, out HitInfo info, float maxLength,int method)
{
	Init(info);
	static float sha = 1.0;
	static float t = 0;
	static float ph = 1e10;

	static TraceInfo traceInfo;
	Init(traceInfo);
	float3 oriPos = ray.pos;

	static int objInx = -1;
	static float objSDF[OBJNUM];
	static float sdf = MaxSDF;

	while (traceInfo.traceCount <= MaxTraceTime)
	{
		objInx = -1;
		sdf = MaxSDF;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo);
			if (objSDF[inx] < sdf)
			{
				sdf = objSDF[inx];
				objInx = inx;
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
			sha = 0;
			info.bHit = true;
			info.obj = objInx;
			info.P = ray.pos;
			break;
		}

		if(method == 0)
		{
			sha = min(sha, 4 * sdf / t);
			t += clamp(sdf, 0.1*0.01, 0.1*0.5);
		}
		else if(method == 1)
		{
			float h = sdf;
			float y = traceInfo.traceCount ==0 ? 0 : h*h/(2.0*ph);
			float d = sqrt(h*h-y*y);
			sha = min( sha, SoftShadowK * d/max(0.0,t-y));
			ph = h;
			t += h;
		}

		ray.pos += sdf * ray.dir;
		Update(traceInfo,sdf);
		traceInfo.traceSum = length(ray.pos - oriPos);

		if(traceInfo.traceSum>maxLength)
		{
			break;
		}
	}
	sha = saturate(sha);
	return sha * sha *(3-2*sha);
}

void Indir_TraceScene(Ray ray, out HitInfo info)
{
	float traceThre = TraceThre;

	Init(info);

	TraceInfo traceInfo;
	Init(traceInfo);
	float3 oriPos = ray.pos;

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
		traceInfo.traceSum = length(ray.pos - oriPos);
	}
}

float4 GetQuadColor(int inx, float2 uv, float2 bound)
{
	if(inx == 0)
	{
		uv.x*=bound*4;
		uv.x+= -_Time.y;
		return SampleRGBA(Arrow,uv);
	}
	return 0;
}

float4 TraceQuadScene(Ray ray, out HitInfo info)
{
	Init(info);
	//@@@SDFBakerMgr BakedQuads
const static float3 pos[1] = {float3(5.57, 0.54, 0.04)};
const static float3 norm[1] = {float3(0, 1, 0)};
const static float3 udir[1] = {float3(1, 0, 0)};
const static float2 bound[1] = {float2(4.492649, 0.19793)};
const static int quadNum = 1;
	//@@@
	int minD = MAXFLOAT;
	int inx = -1;
	for(int i=0;i<quadNum;i++)
	{
		static Plane plane;
		plane.p = pos[i];
		plane.n = norm[i];
		static float d;
		d = RayCastPlane(ray, plane);
		static float3 u;
		u = udir[i];
		static float3 w;
		w = plane.n;
		static float3 v;
		v = cross(w,u);
		if(d>=0 && d<minD)
		{
			float3 hit = ray.pos+d*ray.dir;
			if(abs(dot(hit - plane.p,u))<bound[i].x&&
				abs(dot(hit - plane.p,v))<bound[i].y)
				{
					info.bHit = true;
					info.obj = i;
					info.N = plane.n;
					info.P = hit;
					inx = i;
				}
		}
	}
	if(info.bHit)
	{
		float2 uv = float2(
		dot(info.P - pos[inx],udir[inx]),
		dot(info.P - pos[inx],cross(norm[i],udir[inx]))
		);
		uv = 0.5*uv/bound[inx];
		uv = uv+0.5;
		return GetQuadColor(inx,uv, bound[inx]);
	}
	else
	{
		return 0;
	}
}


float3 SceneRenderReflect(Ray ray,in HitInfo minHit,in Material_PBR mat)
{
	float3 re = 0;
	ray.dir = reflect(ray.dir,minHit.N);
	ray.pos = minHit.P + ray.dir*TraceThre*2 + minHit.N*TraceThre*2;
	Material_PBR reflectSourceMat;
	Init(reflectSourceMat);
	HitInfo reflectHit;
	Init(reflectHit);
	TraceScene(ray, reflectHit);
	if (reflectHit.bHit)
	{
		//reflectSourceMat = GetObjMaterial_PBR(reflectHit.obj);
		//float atten = PntLightAtten(minHit.P,reflectHit.P);
		//atten = saturate(mat.reflect_ST.x*atten+mat.reflect_ST.y);
		//re = atten * RenderSceneObj(ray, reflectHit, reflectSourceMat);
		//!!! has problem now,might be zero just for now
		//re*=RenderSceneSDFShadow(minHit);
	}
	else
	{
		re = CommonBg_WaterSky(ray, seed.xy, float2(w,h), float2(0.5,0.5*(1+sin(0.1*_Time.y))));
	}
	return re;
}

void SceneRenderIndirRay(in Ray ray, out float3 re, out HitInfo minHit, out Material_PBR indirSourceMat)
{
	re = 0;
	//---Trace
	Init(minHit);
	TraceScene(ray, minHit);
	//Indir_TraceScene(ray, minHit);
	//___Trace

	if (minHit.bHit)
	{
		indirSourceMat = GetObjMaterial_PBR(minHit.obj);
		re = RenderSceneObj(ray, minHit, indirSourceMat);
	}
}

float3 Sample_MIS_H(float3 Xi, float3 N, in Material_PBR mat, float p_diffuse) {
float rd = Xi.z;

if(rd <= p_diffuse) {
return IS_SampleDiffuseH(N,mat.roughness,Xi.x,Xi.y);
}
	else
	{
		return IS_SampleSpecularH(N,mat.roughness,Xi.x,Xi.y);
	}
return 0;
}

void SetCheapIndirectColor(inout float3 re, float3 seed, Ray ray, HitInfo minHit, Material_PBR mat)
{
	Ray ray_indirect;
	ray_indirect.pos = minHit.P;
	float3 Xi = float3(rand01(seed),rand01(seed.zxy),rand01(seed.zyx));

	float r_diffuse = saturate(1.0 - mat.metallic);
	float r_specular = saturate(1.0);
	float r_sum = r_diffuse + r_specular;
	float p_diffuse = r_diffuse / r_sum;
	float p_specular = r_specular / r_sum;

	float3 H = Sample_MIS_H(Xi, minHit.N, mat,p_diffuse);
	ray_indirect.dir = reflect(ray.dir,H);
	{
		//float3 d1 = Vec2NormalHemisphere(randDir,minHit.N);
		//float3 d2 = reflect(ray.dir,minHit.N);
		//ray_indirect.dir = lerp(d2, d1, mat.roughness);
		//ray_indirect.dir = reflect(ray.dir,minHit.N);
		//ray_indirect.dir = toNormalHemisphere(randP_hemiRound(seed), minHit.N);
	}
	//minHit.N*TraceThre*2 ensure escape from 'judging surface'
	ray_indirect.pos = minHit.P + ray_indirect.dir*TraceThre*2 + minHit.N*TraceThre*2;
	HitInfo indirHit;
	float3 indirLightColor;
	Material_PBR indirSourceMat;
	SceneRenderIndirRay(ray_indirect, indirLightColor, indirHit, indirSourceMat);
	indirLightColor *= RenderSceneSDFShadow(indirHit);
	//---
	float3 L = ray_indirect.dir;
	float pdf_diffuse = IS_DiffusePDF(L,minHit);
	float pdf_specular = IS_SpecularPDF(L,H,mat,minHit);

	float pdf = p_diffuse * pdf_diffuse
				+ p_specular * pdf_specular;
	pdf = max(0.001f, pdf);
	indirLightColor /= pdf;
	if(indirSourceMat.roughness<0.5 && mat.roughness>0.2)
	{
		indirLightColor = 0;
	}
	//___
	float3 Li = indirLightColor * PntLightAtten(minHit.P,indirHit.P);
	re = PBR_GGX(mat, minHit.N, -ray.dir, L, Li);
	re = max(re,0);
}

void SetIndirectColor(inout float3 re, float3 seed, Ray ray, HitInfo minHit, Material_PBR mat)
{
	SetCheapIndirectColor(re, seed, ray, minHit, mat);
}

int GetSpecialID(int inx)
{
//@@@SDFBakerMgr SpecialObj
if(inx == 0 )
{
}
else if (inx == 1 )
{
inx = -1;
}
//@@@
return inx;
}
