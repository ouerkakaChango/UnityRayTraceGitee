#ifndef COMMONMATLIB_HLSL
#define COMMONMATLIB_HLSL
#include "../PBR/PBRCommonDef.hlsl"
//#include "../PBR/PBR_IBL.hlsl"
//#include "../PBR/PBR_GGX.hlsl"
#include "../UV/UVCommonDef.hlsl"
#include "../Noise/NoiseCommonDef.hlsl"

void SetMatLib_BrushedMetal(inout Material_PBR mat, float2 uv, float brushPower = 0.15)
{
	//change from https://www.shadertoy.com/view/tldfD8
	float g = 0.1, l=0.;
	g += -0.5+SampleR(greyNoiseMedium, uv*float2(.06,4.18));
	l += brushPower;
	l = exp(4.*l-1.5);
	g = exp(1.2*g-1.5);
	float v = .1*g+.2*l+2.*g*l;
	mat.metallic = saturate(v*2);
	mat.roughness = saturate((1-v)*0.5);
}

#endif