#define OBJNUM 7

#define MaxSDF 100000
#define MaxTraceDis 100
#define MaxTraceTime 6400
#define TraceThre 0.001
#define NormalEpsilon 0.001

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

float daoScale;

//@@@SDFBakerMgr TexSys
Texture2D<float3> woodTex;
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
	//return 1 / (1 + 0.01*d + 0.005*d*d);
}

float2 Hashv2v2 (float2 p)
{
float2 cHashVA2 = float2 (37., 39.);
return frac (sin (dot (p, cHashVA2) + float2 (0., cHashVA2.x)) * 43758.54);
}

float Noisefv2 (float2 p)
{
float2 t, ip, fp;
ip = floor (p);
fp = frac (p);
fp = fp * fp * (3. - 2. * fp);
t = lerp (Hashv2v2 (ip), Hashv2v2 (ip + float2 (0., 1.)), fp.y);
return lerp (t.x, t.y, fp.x);
}

float3 SampleNTanFromR(Texture2D<float3> tex,float2 uv, float3 vtan, int mip = 0)
{
	uint2 size = GetSize(tex);
	float2 del = 1;//pow(abs(vtan.z),2);
	del/=size;
	float gx = GetRGB(woodTex, uv+del*float2(1,0)).r - GetRGB(woodTex, uv+del*float2(-1,0)).r;
	float gy = GetRGB(woodTex, uv+del*float2(0,1)).r - GetRGB(woodTex, uv+del*float2(0,-1)).r;
	return normalize(float3(gx,gy,0.1));
}
int GetSpecialID(int inx);

Material_PBR GetObjMaterial_PBR(int obj)
{
	Material_PBR re;
	Init(re);

//@@@SDFBakerMgr ObjMaterial
if(obj == 0 )
{
re.albedo = float3(0.5, 0.5, 0.5);
re.metallic = 0.9;
re.roughness = 0.1;
re.reflective = 0.2;
}
else if (obj == 1 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 1;
re.reflective = 0;
}
else if (obj == 2 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 1;
re.reflective = 0;
}
else if (obj == 3 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 1;
re.reflective = 0.5;
}
else if (obj == 4 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 1;
re.reflective = 0;
}
else if (obj == 5 )
{
re.albedo = float3(0.5843138, 0.5568628, 0.4313726);
re.metallic = 0;
re.roughness = 1;
re.reflective = 0;
}
else if (obj == 6 )
{
re.albedo = float3(0.5849056, 0.5552883, 0.4331613);
re.metallic = 0;
re.roughness = 1;
re.reflective = 0;
}
//@@@
	return re;
}

int GetObjRenderMode(int obj)
{
//@@@SDFBakerMgr ObjRenderMode
int renderMode[7];
renderMode[0] = 0;
renderMode[1] = 1000;
renderMode[2] = 0;
renderMode[3] = 0;
renderMode[4] = 0;
renderMode[5] = 0;
renderMode[6] = 0;
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
}
else if (inx == 1 )
{
}
else if (inx == 2 )
{
}
else if (inx == 3 )
{
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
	//@@@

	inx = GetSpecialID(inx);
	if(inx == -1)
	{
		uv = SimpleUVFromPos(minHit.P,minHit.N, float3(0.2,1,0.2));
	}
	else if(inx == -5)
	{
		uv = SimpleUVFromPos(minHit.P,minHit.N, float3(1,1,1));
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
}
if(inx == 1 )
{
}
if(inx == 2 )
{
}
if(inx == 3 )
{
}
if(inx == 4 )
{
}
if(inx == 5 )
{
}
if(inx == 6 )
{
}
//@@@
basis_unstable(minHit.N, T, B);
}

void ObjPreRender(inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
int inx = minHit.obj;
//@@@SDFBakerMgr ObjMatLib
if(inx==1)
{
	float2 uv = GetObjUV(minHit);
uv = float2(1, 1)*uv+float2(0, 0);
	mat.albedo *= SampleRGB(woodTex, uv);
}
if(inx==2)
{
float2 uv = GetObjUV(minHit);
uv = float2(1, 1)*uv+float2(0, 0);
float3 T,B;
	GetObjTB(T,B, minHit);
SetMatLib_Marquetry(mat, minHit, uv, T, B, woodTex, 9.6, 0.123);
}
//@@@
//???
if(inx == 1)
{
	float2 uv = GetObjUV(minHit);
	float3 n0 = SampleNTanFromR(woodTex, uv, 1);
	//float del = 1.0/1024;
	//int mip = 0;
	//float gx = SampleRGB(woodTex, uv+float2(del,0),mip).r - SampleRGB(woodTex, uv-float2(del,0),mip).r;
	//float gy = SampleRGB(woodTex, uv+float2(0,del),mip).r - SampleRGB(woodTex, uv-float2(0,del),mip).r;

	//easy AA, thinking from https://www.shadertoy.com/view/4sfSzf --xc
	float3 T,B;
	GetObjTB(T,B, minHit);
	float3 vtan = WorldDirToTangent(ray.dir,minHit.N,T,B);

	float scale = 1;
	float2 dis = scale * 1.0/GetSize(woodTex);
	//
	float wx = abs(vtan.x);
	float3 n1 = SampleNTanFromR(woodTex, uv+dis*(1,0)*wx,vtan);
	float3 n2 = SampleNTanFromR(woodTex, uv+dis*(-1,0)*wx,vtan);
	
	float wy = abs(vtan.y);
	float3 n3 = SampleNTanFromR(woodTex, uv+dis*(0,1)*wy,vtan);
	float3 n4 = SampleNTanFromR(woodTex, uv+dis*(0,-1)*wy,vtan);
	float3 nAA = (n1+n2+n3+n4)/4;//lerp(lerp(n1,n2,0.5),lerp(n3,n4,0.5),0.5);
	//float3 nAA = SampleNTanFromR(woodTex, uv, vtan);

	//float3 n_tan = n0;//normalize(float3(gx,gy,0.1));
	//float3 n_tan = lerp(n0,nAA,0.5);
	//float3 n_tan = lerp(n0,minHit.N,wx*wy);

	//minHit.N = ApplyNTangent(n_tan,minHit.N,T,B);
	mat.albedo = nAA;
}

//@@@SDFBakerMgr ObjImgAttach

//@@@

inx = GetSpecialID(inx);

//book shelf center
float grid = 30;
float2 m1 = floor(minHit.P.xz/grid);
float2 c = grid*(m1+0.5);
float dis = 20;
float m = floor(minHit.P.y/dis);
float centerY = m * dis;
float3 center = float3(c.x,centerY,c.y);
float3 cId = float3(m1.x,m,m1.y);
float3 h_bookShelf = 3.0;
float h_lift = 0.2;
float3 q = minHit.P - center - float3(0,h_lift,0);


//--- inx:-3 infibiteBooks shade
if(inx == -3)
{
	float r = length (q.xz);
float a = (r > 0) ? (atan2 (q.z, q.x) / PI + 1)*0.5 : 0;

	float3 bookColor = 0;
	float layHeight = (h_bookShelf - h_lift)*0.5;
	float bookNum = 256;
	a *= bookNum;
float s = hash_f2 (float2 (floor(a), 1. + centerY)); //hash each book,layer
	float bookMaxHeight = 0.6;
	float bookHeightVary = 0.2;
float y = frac (q.y / layHeight) / (bookMaxHeight - bookHeightVary * s);
if (y < 1.) {
a= frac(a);
bookColor = HSVToRGB (float3 (	
				frac (hash_f3 (cId) + 0.6 * s),
				0.7,
				0.7 * (0.5 + 0.5 * SmoothBump (0.05, 0.95, 0.02, a))
			));
	 float3 c_bookLine = float3(173,163,111)/256.0;
	 float3 c_bookName = c_bookLine*0.8;
	 float k_bookLine = SmoothBump (0.2, 0.25, 0.01, y);
	 float k_bookName = step (abs (y - 0.5), 0.15) *
			step (abs (a - 0.5), 0.25) *
			step (0.5, Noisefv2 (cId.xz * float2 (19., 31.) + floor (float2 (16. * a, 80. * q.y))));
bookColor = lerp (
		lerp (bookColor, c_bookLine, k_bookLine),
c_bookName,
		 k_bookName
		 );
		 mat.roughness = lerp (
		lerp (mat.roughness, 0.1, k_bookLine),
0.1,
		 k_bookName
		 );
		 mat.metallic = lerp (
		lerp (mat.metallic, 0.9, k_bookLine),
0.9,
		 k_bookName
		 );
minHit.N.xz = rotate (minHit.N.xz, 0.5 * PI * (a - 0.5)); //bend norm for each book
}
	else
	{
		mat.metallic = 1;
		mat.roughness = 0;
	}

	mat.albedo = bookColor;
}
//___

//--- Attach Floor Number

if(ShowInt(q.xz,m))
{
	mat.albedo = float3(0,1,0);
}
//___ Attach Floor Number

}

void ObjPostRender(inout float3 result, inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
SmoothWithDither(result, suv);
if(camGammaMode == 1)
{
	
}
else{
	//gamma
	//result = result / (result + 1.0);
	//result = pow(result, 1/2.2);
}
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
float3 lightColors[1];
lightDirs[0] = float3(-0.3213938, -0.7660444, 0.5566705);
lightColors[0] = float3(1, 1, 1);
result = 0.003 * mat.albedo * mat.ao;
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


if(inx <0 &&inx!=-5 && inx!=-6)
{
	//fake infinite pointLight
	float3 offset[5];
	offset[0] = 0;
	offset[1] = float3(1,0,0);
	offset[2] = float3(-1,0,0);
	offset[3] = float3(0,0,1);
	offset[4] = float3(0,0,-1);
	for(int i=0;i<1;i++)
	{
	//book shelf center
	float3 grid = float3(30,20,30);
	//float3 m = floor(minHit.P/grid);
	//float3 c = grid*(m+float3(0.5,0,0.5))+offset[i]*grid;
	float3 m;
	float3 c = GetGridCenterWithID_MidMode(minHit.P, grid, m, offset[i]);
	float3 infLPos = c + float3(0,2,0);
	float3 infL = normalize(infLPos - minHit.P);
	float3 infC = 10*HSVToRGB (float3(
					hash_f3 (m+float3(3,56,7)),
					1,
					1
				))* GetPntlightAttenuation(minHit.P,infLPos);

	result += PBR_GGX(mat, minHit.N, -ray.dir, infL, infC);
	}
}
//???
//---Ceiling Light
if(inx == -6 || inx == -4)
{
	float3 grid = float3(30,20,30);
	float3 c = GetGridCenter_MidMode(minHit.P, grid);
	float3 infLPos = c + float3(0,19.4,0);
	float3 infL = normalize(infLPos - minHit.P);
	float3 infC = 300* GetPntlightAttenuation(minHit.P,infLPos);
	result += PBR_GGX(mat, minHit.N, -ray.dir, infL, infC);
}
//___Ceiling Light
	ObjPostRender(result, mode, mat, ray, minHit);
	return result;
}


float HardShadow_TraceScene(Ray ray, out HitInfo info, float maxLength = MaxSDF);
float Expensive_HardShadow_TraceScene(Ray ray, out HitInfo info, float maxLength = MaxSDF);
float SoftShadow_TraceScene(Ray ray, out HitInfo info, float maxLength = MaxSDF);

float GetDirHardShadow(float3 lightDir, in HitInfo minHit, float maxLength = MaxSDF)
{
	Ray ray;
	ray.pos = minHit.P;
	ray.dir = -lightDir;
	ray.pos += ray.dir*TraceThre*2 + minHit.N*TraceThre*2;
	HitInfo hitInfo;
	return HardShadow_TraceScene(ray, hitInfo, maxLength);
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
if(inx == -6)
{
	return 1;
}
if(true)
{
//@@@SDFBakerMgr DirShadow
int lightType[1];
lightType[0] = -1;
float3 lightPos[1];
lightPos[0] = float3(0, 3, 0);
float3 lightDirs[1];
lightDirs[0] = float3(-0.3213938, -0.7660444, 0.5566705);
int shadowType[1];
shadowType[0] =0;
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
inx = -2;
}
else if (inx == 1 )
{
inx = -5;
}
else if (inx == 2 )
{
inx = -1;
}
else if (inx == 3 )
{
re = min(re, 0 + SDFSphere(p, float3(0, 4, 0), 2));
}
else if (inx == 4 )
{
inx = -3;
}
else if (inx == 5 )
{
inx = -4;
}
else if (inx == 6 )
{
inx = -6;
}
//@@@
//-------------------------------
if(inx == -1)
{
if(abs(p.x-eyePos.x)<300 && abs(p.z - eyePos.z)<300)
	{
	float3 grid = float3(30,20,30);
	float3 center = GetGridCenter_DownMode(p,grid,float3(0,1.5,0));
	float3 lp = p - center;
	float r = length(lp.xz);
	float s = min(abs(lp.x),abs(lp.z));
	float crossWidth = 1.5;
	float dCross = s-crossWidth;

	float2 dir1 = normalize(float2(1,1));
	float d2 = dot(lp.xz,dir1);
	float dSub1 = sqrt(r*r - d2*d2);
	float cutWidth = 2.5;
	dSub1 -= cutWidth;

	float tubeThick = 0.5;
	float tubeR = 5;
	float dTube = abs(r-tubeR)-tubeThick;
	float tubeHeight = 1.5;
	float dCutTube = max(dTube,abs(lp.y)-tubeHeight);

	float sub2BookHeight = 0.6;
	float sub2CutThick = 0.9;
	float sub2BookOffsetFromMid = 0.7;
	float dSub2 = max (max (abs (r - tubeR*0.9) - sub2CutThick, abs (abs ((lp.y-tubeHeight*0.0)) - sub2BookOffsetFromMid) - sub2BookHeight), crossWidth*1.2 - s);

	float d = dCutTube;
	d = max(d,-dCross);
	d = max(d,-dSub2);
	re = min(re, d);
	}
}
//-------------------------------
if(inx == -2)
{
	if(abs(p.x-eyePos.x)<300 && abs(p.z - eyePos.z)<300)
	{
		float3 grid = float3(30,20,30);
		float3 center = GetGridCenter_DownMode(p,grid);
		float floorBound = 0.1;
		float df1 = abs(p.y - center.y) - floorBound;
		float df2 = abs(p.y - (center.y+grid.y)) - floorBound;
		float dFloor = min(df1, df2);

		float3 center2 = GetGridCenter_DownMode(p,grid,float3(15,0,15));
		float dPillar = length(p.xz-center2.xz) - 8;

		//if(length(p.xz)>10)
		//{//don't sub (0,0,0), there's floor number
			dFloor = max(dFloor, -dPillar);
		//}
		re = min(re,dFloor);
	}
}
//-------------------------------
if(inx == -3)
{
	if(abs(p.x-eyePos.x)<300 && abs(p.z - eyePos.z)<300)
	{
	float3 center = GetGridCenter_DownMode(p,float3(30,20,30),float3(0,1.5,0));
	float3 lp = p - center;
	float r = length(lp.xz);
	float s = min(abs(lp.x),abs(lp.z));
	float crossWidth = 1.5*1.2;
	float dCross = s-crossWidth;

	float2 dir1 = normalize(float2(1,1));
	float d2 = dot(lp.xz,dir1);
	float dSub1 = sqrt(r*r - d2*d2);
	float cutWidth = 2.5;
	dSub1 -= cutWidth;

	float tubeThick = 0.1;
	float tubeR = 5;
	float dTube = abs(r-tubeR)-tubeThick;
	float tubeHeight = 1.5*0.95;
	float dCutTube = max(dTube,abs(lp.y)-tubeHeight);

	float sub2BookHeight = 0.6;
	float sub2CutThick = 0.9;
	float sub2BookOffsetFromMid = 0.7;
	float dSub2 = max (max (abs (r - tubeR*0.9) - sub2CutThick, abs (abs ((lp.y-tubeHeight*0.0)) - sub2BookOffsetFromMid) - sub2BookHeight), crossWidth*1.2 - s);

	float d = dCutTube;
	d = max(d,-dCross);
	//d = max(d,-dSub2);
	re = min(re, d);
	}
}
//-------------------------------
if(inx == -4)
{
	if(abs(p.x-eyePos.x)<300 && abs(p.z - eyePos.z)<300)
	{
		float3 center = GetGridCenter_DownMode(p,float3(30,20,30),float3(0,0,15));
		float3 lp = p-center;
		float r = 0.5;
		float disToCenter = 12.5;
		float dis = length(abs(lp.xz)-disToCenter);
		float dinfPillar = dis - r;
		re = min(re, dinfPillar);
	}
}
//-------------------------------
if(inx == -5)
{//'unbias' stair like -555,but change distance from each other,so this 'config' make stair don't affect each other's SDF
	float3 cId;
	float3 center = GetGridCenterWithID_DownMode(p,float3(30,20,30),cId, float3(15,10,15));
	Transform trans;
	trans.pos = center+float3(0,0,0);
	float stAng = 90 * floor (4. * hash_f2 (cId.xz + float2 (27.1, 37.1)));
	trans.rotEuler = float3(0,stAng,45);
	trans.scale = 1;
	float3 q = WorldToLocal(trans, p);
	//float3 q = p - float3(0,5,0);
	float s = gmod (q.x, sqrt (2.));
	float d = 0.5*max (max (q.y - min (s, sqrt (2.) - s), abs (q.z) - 2.), -0.5 - q.y);
	re = min(re, d);
}
//-------------------------------
if(inx == -6)
{
	float3 grid = float3(30,20,30);
		float3 center = GetGridCenter_DownMode(p,grid,float3(0,19.5,0));
		float floorBound = 0.01;
		float d = abs(p.y - center.y) - floorBound;
		float3 center2 = GetGridCenter_DownMode(p,grid,float3(15,0,15));
		float dPillar = length(p.xz-center2.xz) - 8;
		re = min(re, d);
		re = max(re,-dPillar);
}
//-------------------------------
//'unbias' stair near each other, cost too heavy
//if(inx == -555)
//{
	//if(abs(p.x-eyePos.x)<300 && abs(p.z - eyePos.z)<300)
	//{
	//	float3 grid = float3(30,20,30);
	//	float3 cId;
	//	float3 center = GetGridCenterWithID_DownMode(p,grid,cId,float3(15,0,15));
	//	float stAng = 0.5 * PI * floor (4. * hash_f2 (cId.xz + float2 (27.1, 37.1)));
	//	float dStair = re;
	//	float3 offsets[9];
	//	offsets[0] = 0;
	//	offsets[1] = float3(0,grid.y,grid.z);
	//	offsets[2] = float3(0,-grid.y,-grid.z);
	//	offsets[3] = float3(0,grid.y,0);
	//	offsets[4] = float3(0,-grid.y,0);
	//	offsets[5] = float3(grid.x,0,0);
	//	offsets[6] = float3(-grid.x,0,0);
	//	offsets[7] = float3(grid.x,grid.y,0);
	//	offsets[8] = float3(-grid.x,-grid.y,0);
	//	for(int i=0;i<9;i++)
	//	{
	//		float3 q = p - (center+offsets[i]);
	//		//q.xz = rotate (q.xz, stAng);
	//		q.xy = rotate (q.xy, 0.25 * PI);
	//		float s = gmod (q.x, sqrt (2.));
	//		//float d = 0.5*max (max (q.y - min (s, sqrt (2.) - s), abs (q.z) - 2.), -0.5 - q.y);
	//		float d = 0.5*max (max (q.y - min (s, sqrt (2.) - s), abs (q.z) - 2.), -0.5 - q.y);
	//		//float d = SDFBox(q,0,0.5);//SDFSphere(q,0,1);
	//		dStair = min(dStair,d);
	//	}
	//	re = min(re, dStair);
	//}
//}

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
	inx = GetSpecialID(inx);
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

float HardShadow_TraceScene(Ray ray, out HitInfo info, float maxLength)
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

	while (traceInfo.traceCount <= MaxTraceTime*0.1)
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
int ori = inx;
inx = GetSpecialID(inx);
if(inx == -2 || inx == -6)
{
	inx = ori;
	continue;
}
else
{
	inx = ori;
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

		if (sdf > MaxTraceDis*0.01)
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

float Expensive_HardShadow_TraceScene(Ray ray, out HitInfo info, float maxLength)
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
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		Update(traceInfo,sdf);
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


float3 SceneRenderReflect(Ray ray,in HitInfo minHit)
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
		re = RenderSceneObj(ray, reflectHit, reflectSourceMat);
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
	float3 Li = indirLightColor * GetPntlightAttenuation(minHit.P,indirHit.P);
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
inx = -2;
}
else if (inx == 1 )
{
inx = -5;
}
else if (inx == 2 )
{
inx = -1;
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
inx = -4;
}
else if (inx == 6 )
{
inx = -6;
}
//@@@
return inx;
}
