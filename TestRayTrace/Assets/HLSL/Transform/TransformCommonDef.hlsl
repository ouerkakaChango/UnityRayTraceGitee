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

//https://www.gatevidyalay.com/3d-shearing-in-computer-graphics-definition-examples/#:~:text=in%20Computer%20Graphics%2D-,In%20Computer%20graphics%2C,as%20well%20as%20Z%20direction.
float3 ShearX(float3 p, float shy, float shz)
{
	float3x3 m = {
		1,0,0,
		shy,1,0,
		shz,0,1
	};
	return mul(m, p);
}

#endif