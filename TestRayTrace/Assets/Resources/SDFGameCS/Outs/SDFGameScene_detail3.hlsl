#define OBJNUM 5

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

//https://iquilezles.org/articles/smin/

float smin( float a, float b, float k=0.1 )
{
float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
return lerp( b, a, h ) - k*h*(1.0-h);
}

float DigSeg (float2 q)
{
return step (abs (q.x), 0.12) * step (abs (q.y), 0.6);
}

#define DSG(q) k = kk; kk = k / 2; if (kk * 2 != k) d += DigSeg (q)

float ShowDig (float2 q, int iv)
{
float d;
int k, kk;
float2 vp = float2 (0.5, 0.5), vm = float2 (-0.5, 0.5), vo = float2 (1., 0.);
if (iv == -1) k = 8;
else if (iv < 2) k = (iv == 0) ? 119 : 36;
else if (iv < 4) k = (iv == 2) ? 93 : 109;
else if (iv < 6) k = (iv == 4) ? 46 : 107;
else if (iv < 8) k = (iv == 6) ? 122 : 37;
else k = (iv == 8) ? 127 : 47;
q = (q - 0.5);
d = 0.;
kk = k;
DSG (q.yx - vo); DSG (q.xy - vp); DSG (q.xy - vm); DSG (q.yx);
DSG (q.xy + vm); DSG (q.xy + vp); DSG (q.yx + vo);
return d;
}

//float2 mfmod(float2 a, float2 b)
//{
// float2 c = frac(abs(a/b))*abs(b);
// return (a < 0) ? -c : c; /* if ( a < 0 ) c = 0-c */
//}

float ShowInt(float2 q, int iv, int maxLen=4)
{
	//!!!
	q.x *= -1;
	int base = 10;
	int tnum = iv;
	int resi;
	float re = 0;
	float2 offset = float2(2,0);
	int i=0;
	if(iv<0)
	{
		tnum = abs(tnum);
	}
	for(;i<maxLen;i++)
	{
		resi = tnum%base;
		re += ShowDig(q - offset*i,resi);
		tnum -= resi;
		tnum /= base;
		if(tnum == 0)
		{
			break;
		}
	}
	if(iv<0)
	{
		re += ShowDig(q - offset*(i+1),-1);
	}
	return re;
}

float Hashfv2(float2 p)
{
	return frac(sin(dot(p, float2(37., 39.))) * 43758.54);
}

float Hashfv3 (float3 p)
{
return frac (sin (dot (p, float3 (37., 39., 41.))) * 43758.54);
}


float3 HsvToRgb (float3 c)
{
return c.z * lerp (1, clamp (abs (frac (c.xxx + float3 (1., 2./3., 1./3.)) * 6. - 3.) - 1., 0., 1.), c.y);
}

float SmoothBump (float lo, float hi, float w, float x)
{
return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
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

float3 GetGridCenter(float3 p, float3 grid, float3 offset = 0)
{
	p -= offset;
	float dis = grid.y;
	float m = round(p.y/dis);
	float centerY = m * dis;
	
	float2 grid2 = grid.xz;
	float2 m1 = floor(p.xz/grid2);
	float2 c = grid2*(m1+0.5);
	return float3(c.x,centerY,c.y)+offset;
}

float3 GetGridCenterWithID(float3 p, float3 grid, out float3 id,float3 offset = 0)
{
	p -= offset;
	float dis = grid.y;
	float m = round(p.y/dis);
	float centerY = m * dis;
	
	float2 grid2 = grid.xz;
	float2 m1 = floor(p.xz/grid2);
	float2 c = grid2*(m1+0.5);

	id = float3(m1.x,m,m1.y);
	return float3(c.x,centerY,c.y)+offset;
}

float2 gmod(float2 a, float2 b)
{
float2 c = frac(abs(a/b))*abs(b);
return c;//(a < 0) ? -c : c; /* if ( a < 0 ) c = 0-c */
}


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
re.roughness = 1;
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
renderMode[0] = 0;
renderMode[1] = 0;
renderMode[2] = 0;
renderMode[3] = 0;
renderMode[4] = 0;
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
	//@@@

	//----------------------------------

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
inx = -3;
}
else if (inx == 4 )
{
inx = -4;
}
	//@@@
	if(inx == -1)
	{
		uv = SimpleUVFromPos(minHit.P,minHit.N, float3(0.2,1,0.2));
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
//@@@
basis_unstable(minHit.N, T, B);
}

void ObjPreRender(inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
int inx = minHit.obj;
//@@@SDFBakerMgr ObjMatLib
if(inx==2)
{
float2 uv = GetObjUV(minHit);
uv = float2(1, 1)*uv+float2(0, 0);
float3 T,B;
	GetObjTB(T,B, minHit);
SetMatLib_Marquetry(mat, minHit, uv, T, B, woodTex, 9.6, 0.123);
}
//@@@

//@@@SDFBakerMgr ObjImgAttach

//@@@

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
inx = -3;
}
else if (inx == 4 )
{
inx = -4;
}
//@@@

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
float s = Hashfv2 (float2 (floor(a), 1. + centerY)); //hash each book,layer
	float bookMaxHeight = 0.6;
	float bookHeightVary = 0.2;
float y = frac (q.y / layHeight) / (bookMaxHeight - bookHeightVary * s);
if (y < 1.) {
a= frac(a);
bookColor = HsvToRgb (float3 (	
				frac (Hashfv3 (cId) + 0.6 * s),
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

float3 RenderSceneObj(Ray ray, inout HitInfo minHit, out Material_PBR mat)
{
	mat = GetObjMaterial_PBR(minHit.obj);
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
else if (mode == 3)
{
	//lightmap mode
	result = mat.albedo;
	//result = pow(result,2.2);
	//result = pow(result,2.2);
}
else if (mode == 333)
{
	float3 lightPos = float3(0,4,0);
	float3 lightColor = float3(1,1,1);
	float3 l = normalize(lightPos - minHit.P);
	result = PBR_GGX(mat, minHit.N, -ray.dir, l, lightColor);
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

int inx = minHit.obj;
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
inx = -3;
}
else if (inx == 4 )
{
inx = -4;
}
//@@@

if(inx <0 && inx>=-3 )
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
	float3 m = floor(minHit.P/grid);
	float3 c = grid*(m+float3(0.5,0,0.5))+offset[i]*grid;
	float3 infLPos = c + float3(0,2,0);
	float3 infL = normalize(infLPos - minHit.P);
	float3 infC = 10*HsvToRgb (float3(
					Hashfv3 (m+float3(3,56,7)),
					1,
					1
				))* GetPntlightAttenuation(minHit.P,infLPos);

	result += PBR_GGX(mat, minHit.N, -ray.dir, infL, infC);
	}
}
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
inx = -3;
}
else if (inx == 4 )
{
inx = -4;
}
//@@@
//-------------------------------
if(inx == -1)
{
if(abs(p.x-eyePos.x)<300 && abs(p.z - eyePos.z)<300)
	{
	float3 grid = float3(30,20,30);
	float3 center = GetGridCenter(p,grid);
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
	float tubeHeight = 3;
	float dCutTube = max(dTube,abs(lp.y)-tubeHeight);

	float sub2BookHeight = 0.6;
	float sub2CutThick = 0.9;
	float sub2BookOffsetFromMid = 0.7;
	float dSub2 = max (max (abs (r - tubeR*0.9) - sub2CutThick, abs (abs ((lp.y-tubeHeight*0.5)) - sub2BookOffsetFromMid) - sub2BookHeight), crossWidth*1.2 - s);

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
		float3 center = GetGridCenter(p,grid);
		float floorBound = 0.1;
		float df1 = abs(p.y - center.y) - floorBound;
		float df2 = abs(p.y - (center.y+grid.y)) - floorBound;
		float dFloor = min(df1, df2);

		float3 center2 = GetGridCenter(p,grid,float3(15,0,15));
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
	float3 center = GetGridCenter(p,float3(30,20,30));
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
	float tubeHeight = 3*0.95;
	float dCutTube = max(dTube,abs(lp.y)-tubeHeight);

	float sub2BookHeight = 0.6;
	float sub2CutThick = 0.9;
	float sub2BookOffsetFromMid = 0.7;
	float dSub2 = max (max (abs (r - tubeR*0.9) - sub2CutThick, abs (abs ((lp.y-tubeHeight*0.5)) - sub2BookOffsetFromMid) - sub2BookHeight), crossWidth*1.2 - s);

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
		float3 center = GetGridCenter(p,float3(30,20,30),float3(0,0,15));
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
	float3 center = GetGridCenter(p,float3(30,20,30),float3(15,10,15));
	Transform trans;
	trans.pos = center+float3(0,0,0);
	trans.rotEuler = float3(0,0,45);
	trans.scale = 1;
	float3 q = WorldToLocal(trans, p);
	//float3 q = p - float3(0,5,0);
	float s = gmod (q.x, sqrt (2.));
	float d = 0.5*max (max (q.y - min (s, sqrt (2.) - s), abs (q.z) - 2.), -0.5 - q.y);
	re = min(re, d);
}
//-------------------------------
//'unbias' stair near each other, cost too heavy
//if(inx == -555)
//{
	//if(abs(p.x-eyePos.x)<300 && abs(p.z - eyePos.z)<300)
	//{
	//	float3 grid = float3(30,20,30);
	//	float3 cId;
	//	float3 center = GetGridCenterWithID(p,grid,cId,float3(15,0,15));
	//	float stAng = 0.5 * PI * floor (4. * Hashfv2 (cId.xz + float2 (27.1, 37.1)));
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
inx = -3;
}
else if (inx == 4 )
{
inx = -4;
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
inx = -3;
}
else if (inx == 4 )
{
inx = -4;
}
//@@@
if(inx == -2)
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
		re = RenderSceneObj(ray, minHit, indirSourceMat);
	}
}

float3 IndirPointLightRender(float3 P, float3 N, float3 lightColor,float3 lightPos)
{
	float3 Li = lightColor * saturate(1*GetPntlightAttenuation(P,lightPos));
	float3 L = normalize(lightPos - P);
	return Li*saturate(dot(N,L));
}

float3 Sample_MIS_H(float3 Xi, float3 N, in Material_PBR mat, float p_diffuse) {
//float r_diffuse = (1.0 - material.metallic);
//float r_specular = 1.0;
//float r_sum = r_diffuse + r_specular;
	//
//float p_diffuse = r_diffuse / r_sum;
//float p_specular = r_specular / r_sum;

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
	float m_NL = saturate(dot(minHit.N,L));
	float pdf_diffuse = m_NL / PI;

	float pdf_GGX = 0;
	float a = mat.roughness;
	a = max(0.001f, a*a);
	
	//float3 H = normalize(-ray.dir+L);
	float m_NH = saturate(dot(minHit.N, H));
	float nomi = a * a * m_NH;
	float m_NH2 = m_NH * m_NH;
	
	float denom = (m_NH2 * (a*a - 1.0) + 1.0);
	denom = PI * denom * denom;
	pdf_GGX = nomi / denom;
	pdf_GGX /= 4 * dot(L, H);	
	pdf_GGX = max(pdf_GGX, 0.001f);
	float pdf_specular = pdf_GGX;

	float pdf = p_diffuse * pdf_diffuse
				+ p_specular * pdf_specular;
	pdf = max(0.001f, pdf);
	indirLightColor /= pdf;
	if(indirSourceMat.roughness<0.5 && mat.roughness>0.2)
	{
		indirLightColor = 0;
	}
	//___

	{
		//re = IndirPointLightRender(minHit.P,minHit.N, indirLightColor, indirHit.P);
	}
	float3 Li = indirLightColor * GetPntlightAttenuation(minHit.P,indirHit.P);
	re = PBR_GGX(mat, minHit.N, -ray.dir, L, Li);
	re = max(re,0);
}

void SetIndirectColor(inout float3 re, float3 seed, Ray ray, HitInfo minHit, Material_PBR mat)
{
	SetCheapIndirectColor(re, seed, ray, minHit, mat);
}
