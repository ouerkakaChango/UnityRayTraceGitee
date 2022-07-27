#ifndef FONT_PREFAB_HLSL
#define FONT_PREFAB_HLSL
#include "../../HLSL/SDFGame/SDFCommonDef.hlsl"
#include "../../HLSL/Spline/QuadBezier/QuadBezier.hlsl"
void SDFPrefab_ASCII_65(inout float re, in float3 p)
{
	float d = re;
	float height = 0.1;
	float sizeU = 0.1;
	float sizeV1 = 0.6;
	float sizeV2 = 0.3;
	float footDisToCenter = 0.12;
	float shearStrength = 0.4;
	float disToCenter1 = 0.1f;
	float a1 =  SDFShearZBoxTransform(p, float3(sizeU*0.5, height, sizeV1*0.5),
	shearStrength, 0,
	float3(0.5 - footDisToCenter, height, 0.5));

	float a2 =  SDFShearZBoxTransform(p, float3(sizeU*0.5, height, sizeV1*0.5),
	-shearStrength, 0,
	float3(0.5 + footDisToCenter, height, 0.5));

	float a3 = SDFBox(p, float3(0.5, height, 0.5 - disToCenter1), float3(sizeV2*0.5, height, sizeU*0.5)); 

	d = min(a1,a2);
	d = min(d,a3);

	re = min(re,d);
}

void SDFPrefab_ASCII_66(inout float re, in float3 p)
{
float d6 = re;
d6 = min(d6, 0 + SDFBox(p, float3(0.284, 0.1, 0.5), float3(0.05, 0.1, 0.35), float3(0, 0, 0)));
float d5 = re;
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
FUNC_SDFBoxedQuadBezier(d5, p, spline, 9, trans, box)
float d1 = re;
Init(trans);
trans.pos = float3(0.25, 0.1, 0.15);
trans.rotEuler = float3(0, 180, 180);
FUNC_SDFBoxedQuadBezier(d1, p, spline, 9, trans, box)
re = min(re, d6);
re = min(re, d5);
re = min(re, d1);
}

#endif
