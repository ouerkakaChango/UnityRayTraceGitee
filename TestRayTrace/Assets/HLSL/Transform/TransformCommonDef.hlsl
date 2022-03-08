#ifndef TREANDFORMCOMMONDEF_HLSL
#define TREANDFORMCOMMONDEF_HLSL
#include "../CommonDef.hlsl"

float3 RotByEuler(float3 p, float3 eulerAngle)
{
	float a = eulerAngle.x/180.0f*PI;
	float b = eulerAngle.y/180.0f*PI;
	float c = eulerAngle.z/180.0f*PI;
	float3x3 rotM = {
	cos(b)*cos(c), sin(a)*sin(b)*cos(c)-cos(a)*sin(c), cos(a)*sin(b)*cos(c)+sin(a)*sin(c),
	cos(b)*sin(c), sin(a)*sin(b)*sin(c)+cos(a)*cos(c), cos(a)*sin(b)*sin(c)-sin(a)*cos(c),
	-sin(b), sin(a)*cos(b), cos(a)*cos(b)
	};
	return mul(rotM, p);
}

#endif