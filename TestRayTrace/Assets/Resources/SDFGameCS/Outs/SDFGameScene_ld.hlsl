#define OBJNUM 2

#define MaxSDF 100000
#define MaxTraceDis 100
#define MaxTraceTime 6400
#define TraceThre 0.001
#define NormalEpsilon 0.01

#define HardShadowExpensive true

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
#include "../../../HLSL/MatLib/CommonMatLib.hlsl"

//@@@SDFBakerMgr TexSys
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

float fastSign(float3 p, float scale = 0.5)
{
	return hash_uint3(abs(p)).x >0.5?-1:1;
}

float mrand01(float3 seed)
{
	seed = abs(seed);
	//uint stat = (uint)(seed.x) * 1973 + (uint)(seed.y) * 9277 + (uint)(seed.z) * 2699 | 1;
	uint stat = (uint)(seed.x) * 197 + (uint)(seed.y) * 927 + (uint)(seed.z) * 269;

	return random_float_01(stat);
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
re.metallic = 0;
re.roughness = 1;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 1 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 1;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
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

float2 GetObjUV(in HitInfo minHit)
{
	float2 uv = 0;
	int inx = minHit.obj;
	//@@@SDFBakerMgr ObjUV
if(inx == 0 )
{
uv = BoxedUV(minHit.P, float3(0, -1.08, 0), float3(10, 0.5, 10), float3(0, 0, 0));
uv = BoxedUV(minHit.P, float3(0, -1.08, 0), float3(10, 0.5, 10), float3(0, 0, 0));
return uv;
}
else if (inx == 1 )
{
uv = BoxedUV(minHit.P, float3(-0.84, 1, 0.99), float3(1.50175, 0.02935212, 3.01255), float3(0, 0, 0));
uv = BoxedUV(minHit.P, float3(-0.84, 1, 0.99), float3(1.50175, 0.02935212, 3.01255), float3(0, 0, 0));
return uv;
}
	//@@@

	inx = GetSpecialID(inx);
	if(inx == -1)
	{
		//uv = SimpleUVFromPos(minHit.P,minHit.N, float3(1,1,1));
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
BoxedTB(T,B,minHit.P, float3(0, -1.08, 0), float3(10, 0.5, 10), float3(0, 0, 0));
return;
}
if(inx == 1 )
{
BoxedTB(T,B,minHit.P, float3(-0.84, 1, 0.99), float3(1.50175, 0.02935212, 3.01255), float3(0, 0, 0));
return;
}
//@@@
basis_unstable(minHit.N, T, B);
}

void ObjPreRender(inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
int inx = minHit.obj;
//@@@SDFBakerMgr ObjMatLib

//@@@

//@@@SDFBakerMgr ObjImgAttach

//@@@

inx = GetSpecialID(inx);
}

void ObjPostRender(inout float3 result, inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
//SmoothWithDither(result, suv);
}

float GetDirHardShadow(float3 lightDir, in HitInfo minHit, float maxLength = MaxSDF);
float GetDirSoftShadow(float3 lightDir, in HitInfo minHit, float maxLength = MaxSDF);

float3 RenderSceneObj(Ray ray, inout HitInfo minHit, inout Material_PBR mat)
{
	int mode = GetObjRenderMode(minHit.obj);
	ObjPreRender(mode, mat, ray, minHit);
	float3 result = 0;
if(mode == 0)
{
	int lightType[2];
	float3 lightPos[2];
	float3 lightDir[2];
	float3 lightColor[2];
	int shadowType[2];
	
	lightType[0] = 0;
	lightPos[0] = 0;
	lightDir[0] = float3(-0.3213938, -0.7660444, 0.5566705);
	lightColor[0] = 1;
	shadowType[0] = 0;

	lightType[1] = 1;
	lightPos[1] = float3(-1, 2, 1.5);
	lightDir[1] = normalize(minHit.P - lightPos[1]);
	lightColor[1] = float3(1,0,0);
	shadowType[1] = 0;

	result.rgb = 0.03 * mat.albedo * mat.ao;

	//$$$
	//lig
	int lightspace = 2;
	int i = lightspace * mrand01(float3(seed.xy,gFrameID));

	float atten = 1;
	if(lightType[i]==1)
	{
		atten = PntLightAtten(minHit.P, lightPos[i]);
	}	
	float3 newLig = atten * PBR_GGX(mat, minHit.N, -ray.dir, -lightDir[i], lightColor[i]);

	//sha
	float maxShadowTraceLength = MaxSDF;
	if(lightType[i]==1)
	{
	 maxShadowTraceLength = length(minHit.P - lightPos[i]);
	}
	float sha = 1;
	if(shadowType[i]==0)
{
sha = GetDirHardShadow(lightDir[i], minHit, maxShadowTraceLength);
}
if(shadowType[i]==1)
{
sha = GetDirSoftShadow(lightDir[i], minHit, maxShadowTraceLength);
}
	newLig *= sha;

	//blend
	float n = frameID;
	result = n / (n + 1)*LastLig[seed.xy] + 1 / (n + 1)*newLig;
	//result = newLig;
}
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
float SoftShadow_TraceScene(Ray ray, out HitInfo info, float maxLength = MaxSDF);

float GetDirHardShadow(float3 lightDir, in HitInfo minHit, float maxLength)
{
	Ray ray;
	ray.pos = minHit.P;
	ray.dir = -lightDir;
	ray.pos += ray.dir*TraceThre*2 + minHit.N*TraceThre*2;
	HitInfo hitInfo;
	return HardShadow_TraceScene(ray, hitInfo, maxLength, HardShadowExpensive);
}

float GetDirSoftShadow(float3 lightDir, in HitInfo minHit, float maxLength)
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
return sha;
}

float3 RenderSceneAdditionalColor(in Ray ray, in HitInfo minHit, in Material_PBR mat)
{
	float3 result = 0;

	//int lightType[1];
	//float3 lightPos[1];
	//float3 lightDirs[1];
	//float3 addLightColors[1];
	//
	//lightType[0] = 1;
	//lightPos[0] = float3(0.42,2.4,-15.048);
	//lightDirs[0] = normalize(minHit.P - lightPos[0]);
	//addLightColors[0] = float3(1,0,0);
	//
	//result.rgb = 0.03 * mat.albedo * mat.ao;
//for(int i=0;i<1;i++)
//{
	//	float atten = 1;
	//	if(lightType[i]==1)
	//	{
	//		atten = PntLightAtten(minHit.P,lightPos[i]);
	//	}
// result.rgb += atten * PBR_GGX(mat, minHit.N, -ray.dir, -lightDirs[i], addLightColors[i]);
//}

	return result;
}

//###################################################################################
#include "../../../HLSL/SDFGame/SDFCommonDef.hlsl"
#include "../../../HLSL/Noise/NoiseCommonDef.hlsl"

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
re = min(re, 0 + SDFBox(p, float3(0, -1.08, 0), float3(10, 0.5, 10), float3(0, 0, 0)));
}
else if (inx == 1 )
{
re = min(re, 0 + SDFBox(p, float3(-0.84, 1, 0.99), float3(1.50175, 0.02935212, 3.01255), float3(0, 0, 0)));
}
//@@@

if(inx == -1)
{
	float3 outCenter = float3(0, -0.5, 0);
	float3 outBound = float3(10, 0.5, 30);
	if(IsInBBox(p,eyePos - 300,eyePos+300))
	{
		if(IsInBBox(p,outCenter - outBound,outCenter+outBound))
		{
		//3 2
		//0 1

		float3 grid = float3(1,1,0.75);
		float3 c1 = GetCellCenter_MidMode(p,grid);
		float3 q = p - c1;
		
		//float d2d = SDFParallelogram(q.xz,0.45,0.35,0.05);
		float d = SDFBox(q,0,float3(grid.x*0.5,0.03,grid.z*0.5*0.95));//0.5*SDFHeightSlice(q,d2d,0.03);

		d = max(d,-SDFCircleSlice(q-float3(0.15,0.03,0.15),0.04,0.03));
		
		re = min(re, d);
		}
		else
		{
			re = min(re, SDFBox(p, outCenter, outBound)+2*TraceThre);
		}
	}
}
if(inx == -2)
{
	float3 outCenter = float3(0, -0.5, 0);
	float3 outBound = float3(10, 0.5, 30);
	if(IsInBBox(p,outCenter - outBound,outCenter+outBound))
	{
		float3 grid = float3(1,1,0.75);
		float3 c1 = GetCellCenter_MidMode(p,grid);
		float3 q = p - c1;
		float3 ringoffset = float3(0.15,0.03,0.15);
		q-=ringoffset;
		float ringHBound = 0.01;
		float d = SDFCircleSlice(q,0.06,ringHBound);
		d = max(d,-SDFCircleSlice(q,0.04,ringHBound*2));
		re = min(re, d);
	}
}
if(inx == -3)
{
	float3 outCenter = float3(0, -0.5, 0);
	float3 outBound = float3(10, 0.5, 30);
	if(IsInBBox(p,eyePos - 300,eyePos+300))
	{
		if(IsInBBox(p,outCenter - outBound,outCenter+outBound))
		{
		//3 2
		//0 1

		float3 grid = float3(1,1,0.75);
		float3 c1 = GetCellCenter_MidMode(p,grid,grid*float3(1,0,0)*0.5);
		float3 q = p - c1;
		
		float d2d = SDFParallelogram(q.xz,0.15,0.35,0.02);
		float d = 0.5*SDFHeightSlice(q,d2d,0.03);
		
		re = min(re, d);
		}
		else
		{
			re = min(re, SDFBox(p, outCenter, outBound)+2*TraceThre);
		}
	}
}
if(inx == -4)
{
	float3 outCenter = float3(0, -0.5, 0);
	float3 outBound = float3(10, 0.5, 30);
	if(IsInBBox(p,eyePos - 300,eyePos+300))
	{
		if(IsInBBox(p,outCenter - outBound,outCenter+outBound))
		{
		//3 2
		//0 1

		float3 grid = float3(1,1,0.75);
		float3 c1 = GetCellCenter_MidMode(p,grid,grid*float3(-1,0,0)*0.5);
		float3 q = p - c1;
		
		float d2d = SDFParallelogram(q.xz,0.15,0.35,0.02);
		float d = 0.5*SDFHeightSlice(q,d2d,0.03);
		
		re = min(re, d);
		}
		else
		{
			re = min(re, SDFBox(p, outCenter, outBound)+2*TraceThre);
		}
	}
}
re = max(re, -SDFBox(p, float3(0, -3.76, -15.47), float3(2, 7.892302*0.5, 2), float3(0, 0, 0)));

//float3 grid = float3(1,1,0.75);
		//float3 p0 = GetCellCenter_MidMode(p,grid);
		//float e = 0.5;
		//p0 = p0 + grid*float3(-e,0,-e);
		//float3 p1 = p0 + grid*float3(1,0,0)*e*2;
		//float3 p2 = p0 + grid*float3(1,0,1)*e*2;
		//float3 p3 = p0 + grid*float3(0,0,1)*e*2;
		//float3 pa1 = p0 - grid*float3(1,0,0)*e*2;
		//float3 pa2 = p3 - grid*float3(1,0,0)*e*2;
		//float3 pb1 = p1 + grid*float3(1,0,0)*e*2;
		//float3 pb2 = p2 + grid*float3(1,0,0)*e*2;
		//
		//
		//float3 c1 = 0.25*(p0+p1+p2+p3);
		//float3 q = p - c1;
		//
		//float3 ca = 0.25*(p0+p3+pa1+pa2);
		//float3 qa = p - ca;
		//
		//float3 cb = 0.25*(p1+p2+pb1+pb2);
		//float3 qb = p - cb;
		//
		//float k = 0.5;
		//float3 delta = k*grid*float3(e,0,0);
		//p0 += fastSign(p0) * delta;
		//p1 += fastSign(p1) * delta;
		//p2 += fastSign(p2) * delta;
		//p3 += fastSign(p3) * delta;
		//pa1 += fastSign(pa1) * delta;
		//pa2 += fastSign(pa2) * delta;
		//pb1 += fastSign(pb1) * delta;
		//pb1 += fastSign(pb1) * delta;
		//
		//float s = 0.9;
		//float3 v0 = lerp(c1,p0,s);
		//float3 v1 = lerp(c1,p1,s);
		//float3 v2 = lerp(c1,p2,s);
		//float3 v3 = lerp(c1,p3,s);
		//
		//float d2d = UDFQuad2D(p,v0,v1,v2,v3);//SDFParallelogram(q.xz,0.7,0.7,0.05);
		//float d = 0.5*SDFHeightSlice(q,d2d,0.03);
		//
		//v0 = lerp(ca,pa1,s);
		//v1 = lerp(ca,p0,s);
		//v2 = lerp(ca,p3,s);
		//v3 = lerp(ca,pa2,s);
		//d2d = UDFQuad2D(p,v0,v1,v2,v3);
		//float da = 0.5*SDFHeightSlice(qa,d2d,0.03);
		//
		//v0 = lerp(cb,p1,s);
		//v1 = lerp(cb,pb1,s);
		//v2 = lerp(cb,pb2,s);
		//v3 = lerp(cb,p2,s);
		//d2d = UDFQuad2D(p,v0,v1,v2,v3);
		//float db = 0.5*SDFHeightSlice(qb,d2d,0.03);
		//
		//d = min(d,da);
		//d = min(d,db);
		//

return re;
}

float3 GetObjSDFNormal(int inx, float3 p, in TraceInfo traceInfo, float eplisonScale = 1.0f)
{
	float normalEpsilon = NormalEpsilon;

	return normalize(float3(
		GetObjSDF(inx, float3(p.x + NormalEpsilon*eplisonScale, p.y, p.z), traceInfo) - GetObjSDF(inx, float3(p.x - NormalEpsilon*eplisonScale, p.y, p.z), traceInfo),
		GetObjSDF(inx, float3(p.x, p.y + NormalEpsilon*eplisonScale, p.z), traceInfo) - GetObjSDF(inx, float3(p.x, p.y - NormalEpsilon*eplisonScale, p.z), traceInfo),
		GetObjSDF(inx, float3(p.x, p.y, p.z + NormalEpsilon*eplisonScale), traceInfo) - GetObjSDF(inx, float3(p.x, p.y, p.z - NormalEpsilon*eplisonScale), traceInfo)
		));
}

float3 GetObjNormal(int inx, float3 p, in TraceInfo traceInfo)
{
	inx = GetSpecialID(inx);
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
float SoftShadow_TraceScene(Ray ray, out HitInfo info, float maxLength)
{
	Init(info);
	float sha = 1.0;
	float t = 0.005 * 0.1; //一个非0小值，会避免极其细微的多余shadow

	TraceInfo traceInfo;
	Init(traceInfo);
	float3 oriPos = ray.pos;

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
		traceInfo.traceSum = length(ray.pos - oriPos);

		if(traceInfo.traceSum>maxLength)
		{
			break;
		}
	}

	return saturate(sha);
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
		reflectSourceMat = GetObjMaterial_PBR(reflectHit.obj);
		float atten = PntLightAtten(minHit.P,reflectHit.P);
		atten = saturate(mat.reflect_ST.x*atten+mat.reflect_ST.y);
		re = atten * RenderSceneObj(ray, reflectHit, reflectSourceMat);
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
	//SetCheapIndirectColor(re, seed, ray, minHit, mat);
}

int GetSpecialID(int inx)
{
//@@@SDFBakerMgr SpecialObj
if(inx == 0 )
{
}
else if (inx == 1 )
{
}
//@@@
return inx;
}
