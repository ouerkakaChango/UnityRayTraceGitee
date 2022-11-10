#define OBJNUM 16

#define MaxSDF 100000
#define MaxTraceDis 100
#define MaxTraceTime 6400
#define TraceThre 0.001
#define NormalEpsilon 0.001

#define SceneSDFShadowNormalBias 0.001

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
Texture2D<float3> N_paper;
Texture2D<float4> invi1;
Texture2D<float3> WoodTexture;
Texture2D<float> slice_scene2;
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

void dinnerTable(inout float re, in float3 p)
{
float d3 = re;
float d0 = re;
float d8 = re;
float d2 = re;
float d5 = re;
d3 = smin(d3, 0 + SDFBox(p, float3(3, 0.99, 0.7), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0)));
d0 = smin(d0, 0 + SDFBox(p, float3(-3, 0.99, 0.7), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0)));
d8 = smin(d8, 0 + SDFBox(p, float3(-3, 0.99, -2.2), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0)));
d2 = smin(d2, 0 + SDFBox(p, float3(3, 0.99, -2.2), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0)));
d5 = smin(d5, 0 + SDFBox(p, float3(0, 2.12, -0.75), float3(3.27828, 0.1262217, 1.7315), float3(0, 0, 0)));
re = smin(re, d3);
re = smin(re, d0);
re = smin(re, d8);
re = smin(re, d2);
re = smin(re, d5);
}


Material_PBR GetObjMaterial_PBR(int obj)
{
	Material_PBR re;
	Init(re);

//@@@SDFBakerMgr ObjMaterial
if(obj == 0 )
{
re.albedo = float3(0.4901961, 0.282353, 0);
re.metallic = 0;
re.roughness = 1;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 1 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0.9;
re.roughness = 0.1;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 2 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 0.4;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 3 )
{
re.albedo = float3(0.4901961, 0.282353, 0);
re.metallic = 0;
re.roughness = 1;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 4 )
{
re.albedo = float3(0.4901961, 0.282353, 0);
re.metallic = 0;
re.roughness = 1;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 5 )
{
re.albedo = float3(0, 0, 0);
re.metallic = 0;
re.roughness = 1;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 6 )
{
re.albedo = float3(0, 0, 0);
re.metallic = 0;
re.roughness = 0.5;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 7 )
{
re.albedo = float3(0.8584906, 0.7477921, 0.3199092);
re.metallic = 0.9;
re.roughness = 0.5;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 8 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 0.3;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 9 )
{
re.albedo = float3(0, 0, 0);
re.metallic = 0;
re.roughness = 0.5;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 10 )
{
re.albedo = float3(0.4901961, 0.282353, 0);
re.metallic = 0;
re.roughness = 1;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 11 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0.9;
re.roughness = 0.1;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 12 )
{
re.albedo = float3(0.8588235, 0.7490196, 0.3215686);
re.metallic = 0.9;
re.roughness = 0.9;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 13 )
{
re.albedo = float3(0.8588235, 0.7490196, 0.3215686);
re.metallic = 0.9;
re.roughness = 0.5;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 14 )
{
re.albedo = float3(0.490566, 0.28254, 0);
re.metallic = 0;
re.roughness = 1;
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
else if (obj == 15 )
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
int renderMode[16];
renderMode[0] = 0;
renderMode[1] = 0;
renderMode[2] = 0;
renderMode[3] = 0;
renderMode[4] = 0;
renderMode[5] = 0;
renderMode[6] = 0;
renderMode[7] = 0;
renderMode[8] = 0;
renderMode[9] = 0;
renderMode[10] = 0;
renderMode[11] = 0;
renderMode[12] = 0;
renderMode[13] = 0;
renderMode[14] = 0;
renderMode[15] = 0;
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
uv = BoxedUV(minHit.P, float3(-3, 0.99, 0.7), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0));
uv = BoxedUV(minHit.P, float3(-3, 0.99, 0.7), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0));
return uv;
}
else if (inx == 1 )
{
uv = BoxedUV(minHit.P, float3(0, 4.14, 4.86), float3(3.33305, 2.025228, 0.475035), float3(0, 0, 0));
uv = BoxedUV(minHit.P, float3(0, 4.14, 4.86), float3(3.33305, 2.025228, 0.475035), float3(0, 0, 0));
return uv;
}
else if (inx == 2 )
{
uv = BoxedUV(minHit.P, float3(0, 9.55, 0), float3(5, 0.5, 5), float3(0, 0, 0));
uv = BoxedUV(minHit.P, float3(0, 9.55, 0), float3(5, 0.5, 5), float3(0, 0, 0));
return uv;
}
else if (inx == 3 )
{
uv = BoxedUV(minHit.P, float3(3, 0.99, -2.2), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0));
uv = BoxedUV(minHit.P, float3(3, 0.99, -2.2), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0));
return uv;
}
else if (inx == 4 )
{
uv = BoxedUV(minHit.P, float3(3, 0.99, 0.7), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0));
uv = BoxedUV(minHit.P, float3(3, 0.99, 0.7), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0));
return uv;
}
else if (inx == 5 )
{
uv = BoxedUV(minHit.P, float3(-2.371201, 2.37087, -1.158671), float3(0.00838451, 0.09840991, 0.007551101), float3(3.093163, 1.942568, 359.1576));
uv = BoxedUV(minHit.P, float3(-2.371201, 2.37087, -1.158671), float3(0.00838451, 0.09840991, 0.007551101), float3(3.093163, 1.942568, 359.1576));
return uv;
}
else if (inx == 6 )
{
uv = BoxedUV(minHit.P, float3(-2.2165, 2.376, -1.2513), float3(0.005697916, 0.09840989, 0.1790531), float3(1.31041, 300.0943, 357.0246));
uv = BoxedUV(minHit.P, float3(-2.2165, 2.376, -1.2513), float3(0.005697916, 0.09840989, 0.1790531), float3(1.31041, 300.0943, 357.0246));
return uv;
}
else if (inx == 7 )
{
uv = BoxedUV(minHit.P, float3(-2.567963, 2.372937, -1.153289), float3(0.185, 0.09, 0.001), float3(3.093163, 1.942568, 359.1576));
uv = BoxedUV(minHit.P, float3(-2.567963, 2.372937, -1.153289), float3(0.185, 0.09, 0.001), float3(3.093163, 1.942568, 359.1576));
return uv;
}
else if (inx == 8 )
{
uv = BoxedUV(minHit.P, float3(0, -0.5, 0), float3(5, 0.5, 5), float3(0, 0, 0));
uv = BoxedUV(minHit.P, float3(0, -0.5, 0), float3(5, 0.5, 5), float3(0, 0, 0));
return uv;
}
else if (inx == 9 )
{
uv = BoxedUV(minHit.P, float3(-2.567901, 2.37376, -1.151844), float3(0.1921598, 0.09840991, 0.001), float3(3.093163, 1.942568, 359.1576));
uv = BoxedUV(minHit.P, float3(-2.567901, 2.37376, -1.151844), float3(0.1921598, 0.09840991, 0.001), float3(3.093163, 1.942568, 359.1576));
return uv;
}
else if (inx == 10 )
{
uv = BoxedUV(minHit.P, float3(0, 2.12, -0.75), float3(3.27828, 0.1262217, 1.7315), float3(0, 0, 0));
uv = BoxedUV(minHit.P, float3(0, 2.12, -0.75), float3(3.27828, 0.1262217, 1.7315), float3(0, 0, 0));
return uv;
}
else if (inx == 11 )
{
}
else if (inx == 12 )
{
uv = BoxedUV(minHit.P, float3(0, 3.98, 5), float3(5, 0.5000001, 5.000001), float3(90, 0, 0));
uv = BoxedUV(minHit.P, float3(0, 3.98, 5), float3(5, 0.5000001, 5.000001), float3(90, 0, 0));
return uv;
}
else if (inx == 13 )
{
uv = BoxedUV(minHit.P, float3(-2.45, 2.88, -0.964), float3(0.20343, 0.20343, 0.20343), float3(0, 0, 0));
uv = BoxedUV(minHit.P, float3(-2.45, 2.88, -0.964), float3(0.20343, 0.20343, 0.20343), float3(0, 0, 0));
return uv;
}
else if (inx == 14 )
{
uv = BoxedUV(minHit.P, float3(-3, 0.99, -2.2), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0));
uv = BoxedUV(minHit.P, float3(-3, 0.99, -2.2), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0));
return uv;
}
else if (inx == 15 )
{
}
	//@@@

	//----------------------------------

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
else if (inx == 8 )
{
}
else if (inx == 9 )
{
}
else if (inx == 10 )
{
}
else if (inx == 11 )
{
}
else if (inx == 12 )
{
}
else if (inx == 13 )
{
}
else if (inx == 14 )
{
}
else if (inx == 15 )
{
}
	//@@@
	if(inx == -2)
	{
		float3 center = float3(-2.81200004,2.68899989,-1.22000003);
		float3 bound = 4*float3(0.07,0.05,0.05);
		uv = BoxedUV(minHit.P, center, bound, float3(0, 0, 0));
	}
	return uv;
}

void GetObjTB(inout float3 T, inout float3 B, in HitInfo minHit)
{
	int inx = minHit.obj;
//@@@SDFBakerMgr ObjTB
if(inx == 0 )
{
BoxedTB(T,B,minHit.P, float3(-3, 0.99, 0.7), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0));
return;
}
if(inx == 1 )
{
BoxedTB(T,B,minHit.P, float3(0, 4.14, 4.86), float3(3.33305, 2.025228, 0.475035), float3(0, 0, 0));
return;
}
if(inx == 2 )
{
BoxedTB(T,B,minHit.P, float3(0, 9.55, 0), float3(5, 0.5, 5), float3(0, 0, 0));
return;
}
if(inx == 3 )
{
BoxedTB(T,B,minHit.P, float3(3, 0.99, -2.2), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0));
return;
}
if(inx == 4 )
{
BoxedTB(T,B,minHit.P, float3(3, 0.99, 0.7), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0));
return;
}
if(inx == 5 )
{
BoxedTB(T,B,minHit.P, float3(-2.371201, 2.37087, -1.158671), float3(0.00838451, 0.09840991, 0.007551101), float3(3.093163, 1.942568, 359.1576));
return;
}
if(inx == 6 )
{
BoxedTB(T,B,minHit.P, float3(-2.2165, 2.376, -1.2513), float3(0.005697916, 0.09840989, 0.1790531), float3(1.31041, 300.0943, 357.0246));
return;
}
if(inx == 7 )
{
BoxedTB(T,B,minHit.P, float3(-2.567963, 2.372937, -1.153289), float3(0.185, 0.09, 0.001), float3(3.093163, 1.942568, 359.1576));
return;
}
if(inx == 8 )
{
BoxedTB(T,B,minHit.P, float3(0, -0.5, 0), float3(5, 0.5, 5), float3(0, 0, 0));
return;
}
if(inx == 9 )
{
BoxedTB(T,B,minHit.P, float3(-2.567901, 2.37376, -1.151844), float3(0.1921598, 0.09840991, 0.001), float3(3.093163, 1.942568, 359.1576));
return;
}
if(inx == 10 )
{
BoxedTB(T,B,minHit.P, float3(0, 2.12, -0.75), float3(3.27828, 0.1262217, 1.7315), float3(0, 0, 0));
return;
}
if(inx == 11 )
{
}
if(inx == 12 )
{
BoxedTB(T,B,minHit.P, float3(0, 3.98, 5), float3(5, 0.5000001, 5.000001), float3(90, 0, 0));
return;
}
if(inx == 13 )
{
BoxedTB(T,B,minHit.P, float3(-2.45, 2.88, -0.964), float3(0.20343, 0.20343, 0.20343), float3(0, 0, 0));
return;
}
if(inx == 14 )
{
BoxedTB(T,B,minHit.P, float3(-3, 0.99, -2.2), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0));
return;
}
if(inx == 15 )
{
}
//@@@
}

void ObjPreRender(inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
int inx = minHit.obj;
//@@@SDFBakerMgr ObjMatLib
if(inx==6)
{
	float2 uv = GetObjUV(minHit);
float3 T,B;
	GetObjTB(T,B, minHit);
	minHit.N = SampleNormalMap(N_paper, float2(3, 3)*uv+float2(0, 0), minHit.N,T,B,1);
}
if(inx==7)
{
	float2 uv = GetObjUV(minHit);
	SetMatLib_BrushedMetal(mat,uv, 0);
}
if(inx==8)
{
float2 uv = GetObjUV(minHit);
uv = float2(5, 5)*uv+float2(0, 0);
float3 T,B;
	GetObjTB(T,B, minHit);
SetMatLib_Marquetry(mat, minHit, uv, T, B, WoodTexture);
}
if(inx==9)
{
	float2 uv = GetObjUV(minHit);
float3 T,B;
	GetObjTB(T,B, minHit);
	minHit.N = SampleNormalMap(N_paper, float2(3, 3)*uv+float2(0, 0), minHit.N,T,B,1);
}
if(inx==10)
{
	float2 uv = GetObjUV(minHit);
uv = float2(5, 5)*uv+float2(0, 0);
	mat.albedo *= SampleRGB(WoodTexture, uv);
}
if(inx==12)
{
float2 uv = GetObjUV(minHit);
float3 T,B;
	GetObjTB(T,B, minHit);
SetMatLib_SwirlGold(mat, minHit, uv, T, B, 0.5, 30);
}
if(inx==13)
{
float2 uv = GetObjUV(minHit);
float3 T,B;
	GetObjTB(T,B, minHit);
SetMatLib_SwirlGold(mat, minHit, uv, T, B, 0.5, 10);
}
//@@@

//@@@SDFBakerMgr ObjImgAttach
if (inx == 7)
{
float2 uv = GetObjUV(minHit);
if (IsInBBox(uv, float2(0.1, 0.1), float2(0.9, 0.9)))
{
float2 uv2 = RemapUV(uv, float2(0, 0) ,float2(1, 1) ,float2(0.1, 0.1) ,float2(0.9, 0.9));
float4 co = SampleRGBA(invi1, uv2);
mat.albedo = lerp(mat.albedo,co.rgb,co.a);
}
}
//@@@

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
else if (inx == 8 )
{
}
else if (inx == 9 )
{
}
else if (inx == 10 )
{
}
else if (inx == 11 )
{
}
else if (inx == 12 )
{
}
else if (inx == 13 )
{
}
else if (inx == 14 )
{
}
else if (inx == 15 )
{
}
//@@@

	//if(inx == 0)
	//{
	//	float2 uv = BoxedUV(minHit.P, float3(0, -0.5, 0), float3(5, 0.5, 5), float3(0, 0, 0));
	//	float3 color = lightmap_ground.SampleLevel(common_linear_clamp_sampler, uv, 0).rgb;
	//	SmoothWithDither(color,uv);
	//	mat.albedo = float4(color,1);
	//}
	if(inx == -2)
	{
		float2 uv = GetObjUV(minHit);
		////change from https://www.shadertoy.com/view/tldfD8
		//float brushPower = 0.15;
		//float g = 0.1, l=0.;
		//g += -0.5+SampleR(grayNoiseMedium, uv*float2(.06,4.18));
		//l += brushPower;
		//l = exp(4.*l-1.5);
		//g = exp(1.2*g-1.5);
		//float v = .1*g+.2*l+2.*g*l;
		//mat.metallic = saturate(v*2);
		//mat.roughness = saturate((1-v)*0.5);
		SetMatLib_BrushedMetal(mat,uv);
	}

	//if(inx==3)
	//{
	//	float2 uv = GetObjUV(minHit);
	//	if(IsInBBox(uv,float2(0.2,0.2),float2(0.6,0.8)))
	//	{
	//		float2 uv2 = RemapUV(uv,float2(0.2,0.2),float2(0.6,0.8));
	//		mat.albedo = SampleRGB(blueNoise,uv2);
	//	}
	//}
	//mat.albedo = float3(GetObjUV(minHit),0);
	//if(inx == 2)
	//{
	//	float2 uv = GetObjUV(minHit);
	//	float3 T,B;
	//	GetObjTB(T,B, minHit);
	//	minHit.N = SampleNormalMap(N_paper, 4*uv, minHit.N,T,B,1.3);
	//}
	//if(inx == 13)
	//{
	//	float2 uv = GetObjUV(minHit);
	//	float3 T,B;
	//	GetObjTB(T,B, minHit);
	//	SetMatLib_SwirlGold(mat,minHit,uv,T,B);
	//}
}

void ObjPostRender(inout float3 result, inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
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
float3 lightDirs[6];
float3 lightColors[6];
lightDirs[0] = normalize(minHit.P - float3(-0.07, 8.15, 3.42));
lightColors[0] = float3(2, 2, 2) * GetPntlightAttenuation(minHit.P, float3(-0.07, 8.15, 3.42));
lightDirs[1] = normalize(minHit.P - float3(-1.713, 2.707, -2.17));
lightColors[1] = float3(1.5, 1.5, 1.5) * GetPntlightAttenuation(minHit.P, float3(-1.713, 2.707, -2.17));
lightDirs[2] = normalize(minHit.P - float3(-3.526, 2.707, -2.17));
lightColors[2] = float3(1.5, 1.5, 1.5) * GetPntlightAttenuation(minHit.P, float3(-3.526, 2.707, -2.17));
lightDirs[3] = normalize(minHit.P - float3(0.04, 8.15, -3.29));
lightColors[3] = float3(2, 2, 2) * GetPntlightAttenuation(minHit.P, float3(0.04, 8.15, -3.29));
lightDirs[4] = normalize(minHit.P - float3(3.357384, 8.15, 0));
lightColors[4] = float3(2, 2, 2) * GetPntlightAttenuation(minHit.P, float3(3.357384, 8.15, 0));
lightDirs[5] = normalize(minHit.P - float3(-3.83, 8.15, 0));
lightColors[5] = float3(2, 2, 2) * GetPntlightAttenuation(minHit.P, float3(-3.83, 8.15, 0));
result.rgb = 0 * mat.albedo * mat.ao;
for(int i=0;i<6;i++)
{
result.rgb += PBR_GGX(mat, minHit.N, -ray.dir, -lightDirs[i], lightColors[i]);
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
else if(mode == 444)
{
float3 lightDirs[6];
float3 lightColors[6];
lightDirs[0] = normalize(minHit.P - float3(-0.07, 8.15, 3.42));
lightColors[0] = float3(2, 2, 2) * GetPntlightAttenuation(minHit.P, float3(-0.07, 8.15, 3.42));
lightDirs[1] = normalize(minHit.P - float3(-1.713, 2.707, -2.17));
lightColors[1] = float3(1.5, 1.5, 1.5) * GetPntlightAttenuation(minHit.P, float3(-1.713, 2.707, -2.17));
lightDirs[2] = normalize(minHit.P - float3(-3.526, 2.707, -2.17));
lightColors[2] = float3(1.5, 1.5, 1.5) * GetPntlightAttenuation(minHit.P, float3(-3.526, 2.707, -2.17));
lightDirs[3] = normalize(minHit.P - float3(0.04, 8.15, -3.29));
lightColors[3] = float3(2, 2, 2) * GetPntlightAttenuation(minHit.P, float3(0.04, 8.15, -3.29));
lightDirs[4] = normalize(minHit.P - float3(3.357384, 8.15, 0));
lightColors[4] = float3(2, 2, 2) * GetPntlightAttenuation(minHit.P, float3(3.357384, 8.15, 0));
lightDirs[5] = normalize(minHit.P - float3(-3.83, 8.15, 0));
lightColors[5] = float3(2, 2, 2) * GetPntlightAttenuation(minHit.P, float3(-3.83, 8.15, 0));
result = 0 * mat.albedo * mat.ao;
for(int i=0;i<6;i++)
{
result += MPBR_GGX(mat, minHit.N, -ray.dir, -lightDirs[i], lightColors[i]);
}
}
else
{
	result = float3(1,0,1);
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
if(false)
{
//@@@SDFBakerMgr DirShadow
int lightType[6];
lightType[0] = 1;
lightType[1] = 1;
lightType[2] = 1;
lightType[3] = 1;
lightType[4] = 1;
lightType[5] = 1;
float3 lightPos[6];
lightPos[0] = float3(-0.07, 8.15, 3.42);
lightPos[1] = float3(-1.713, 2.707, -2.17);
lightPos[2] = float3(-3.526, 2.707, -2.17);
lightPos[3] = float3(0.04, 8.15, -3.29);
lightPos[4] = float3(3.357384, 8.15, 0);
lightPos[5] = float3(-3.83, 8.15, 0);
float3 lightDirs[6];
lightDirs[0] = normalize(minHit.P - float3(-0.07, 8.15, 3.42));
lightDirs[1] = normalize(minHit.P - float3(-1.713, 2.707, -2.17));
lightDirs[2] = normalize(minHit.P - float3(-3.526, 2.707, -2.17));
lightDirs[3] = normalize(minHit.P - float3(0.04, 8.15, -3.29));
lightDirs[4] = normalize(minHit.P - float3(3.357384, 8.15, 0));
lightDirs[5] = normalize(minHit.P - float3(-3.83, 8.15, 0));
int shadowType[6];
shadowType[0] =1;
shadowType[1] =1;
shadowType[2] =1;
shadowType[3] =1;
shadowType[4] =1;
shadowType[5] =1;
float lightspace = 6;
float maxLength = MaxSDF;
float tsha = 1;
for (int i = 0; i < 6; i++)
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
lightspace /= 6;
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

float GetObjSDF(int inx, float3 p, in TraceInfo traceInfo)
{
//###
float re = MaxTraceDis + 1; //Make sure default is an invalid SDF
//@@@SDFBakerMgr BeforeObjSDF
//@@@
//@@@SDFBakerMgr ObjSDF
if(inx == 0 )
{
re = min(re, 0 + SDFBox(p, float3(-3, 0.99, 0.7), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0)));
}
else if (inx == 1 )
{
re = min(re, 0 + SDFBox(p, float3(0, 4.14, 4.86), float3(3.33305, 2.025228, 0.475035), float3(0, 0, 0)));
}
else if (inx == 2 )
{
re = min(re, 0 + SDFBox(p, float3(0, 9.55, 0), float3(5, 0.5, 5), float3(0, 0, 0)));
}
else if (inx == 3 )
{
re = min(re, 0 + SDFBox(p, float3(3, 0.99, -2.2), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0)));
}
else if (inx == 4 )
{
re = min(re, 0 + SDFBox(p, float3(3, 0.99, 0.7), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0)));
}
else if (inx == 5 )
{
re = min(re, 0 + SDFBox(p, float3(-2.371201, 2.37087, -1.158671), float3(0.00838451, 0.09840991, 0.007551101), float3(3.093163, 1.942568, 359.1576)));
}
else if (inx == 6 )
{
re = min(re, 0 + SDFBox(p, float3(-2.2165, 2.376, -1.2513), float3(0.005697916, 0.09840989, 0.1790531), float3(1.31041, 300.0943, 357.0246)));
}
else if (inx == 7 )
{
re = min(re, 0 + SDFBox(p, float3(-2.567963, 2.372937, -1.153289), float3(0.185, 0.09, 0.001), float3(3.093163, 1.942568, 359.1576)));
}
else if (inx == 8 )
{
re = min(re, 0 + SDFBox(p, float3(0, -0.5, 0), float3(5, 0.5, 5), float3(0, 0, 0)));
}
else if (inx == 9 )
{
re = min(re, 0 + SDFBox(p, float3(-2.567901, 2.37376, -1.151844), float3(0.1921598, 0.09840991, 0.001), float3(3.093163, 1.942568, 359.1576)));
}
else if (inx == 10 )
{
re = min(re, 0 + SDFBox(p, float3(0, 2.12, -0.75), float3(3.27828, 0.1262217, 1.7315), float3(0, 0, 0)));
}
else if (inx == 11 )
{
re = min(re, 0 + SDFSphere(p, float3(-0.845, 2.679, -1.433), 0.5));
}
else if (inx == 12 )
{
re = min(re, 0 + SDFBox(p, float3(0, 3.98, 5), float3(5, 0.5000001, 5.000001), float3(90, 0, 0)));
}
else if (inx == 13 )
{
re = min(re, 0 + SDFBox(p, float3(-2.45, 2.88, -0.964), float3(0.20343, 0.20343, 0.20343), float3(0, 0, 0)));
}
else if (inx == 14 )
{
re = min(re, 0 + SDFBox(p, float3(-3, 0.99, -2.2), float3(0.1663568, 1.028534, 0.1951089), float3(0, 0, 0)));
}
else if (inx == 15 )
{
float d = SDFSlice(p, float3(-2.797, 2.721, 4.276), float3(270, 0, 0), float3(1, 1, 1), slice_scene2, 0.03, TraceThre, 0, 0);
re = min(re, d);
}
//@@@

if(inx == -1)
{
float d = MaxSDF;
dinnerTable(d,p);
//d-=0.2;
re = min(re,d);
}
if (inx == -2)
{

float3 center = float3(-2.81200004,2.68899989,-1.22000003);
//float3 p2 = opCheapBend_XY(p,center,1);
float d = SDFBox(p,center,4*float3(0.07,0.05,0.05));
re = min(re,d);
}

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
else if (inx == 7 )
{
}
else if (inx == 8 )
{
}
else if (inx == 9 )
{
}
else if (inx == 10 )
{
}
else if (inx == 11 )
{
}
else if (inx == 12 )
{
}
else if (inx == 13 )
{
}
else if (inx == 14 )
{
}
else if (inx == 15 )
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

float HardShadow_TraceScene(Ray ray, out HitInfo info, float maxLength)
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

float Expensive_HardShadow_TraceScene(Ray ray, out HitInfo info, float maxLength)
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
}

void SetIndirectColor(inout float3 re, float3 seed, Ray ray, HitInfo minHit, Material_PBR mat)
{
	SetCheapIndirectColor(re, seed, ray, minHit, mat);
}
