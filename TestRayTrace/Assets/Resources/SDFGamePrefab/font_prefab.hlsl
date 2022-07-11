#ifndef FONT_PREFAB_HLSL
#define FONT_PREFAB_HLSL
#include "../../HLSL/SDFGame/SDFCommonDef.hlsl"
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
#endif