#ifndef TREANDFORMCOMMONDEF_HLSL
#define TREANDFORMCOMMONDEF_HLSL
#include "../CommonDef.hlsl"

//Transform logic based on unity coordinate:x-right, y-up, z-in

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

struct Transform
{
	float3 pos;
	float3 rotEuler;
	float3 scale;
};

void Init(out Transform trans)
{
	trans.pos = float3(0, 0, 0);
	trans.rotEuler = float3(0, 0, 0);
	trans.scale = float3(1, 1, 1);
}

float3 WorldToLocal(in Transform trans, float3 world)
{
	//float3 p = world - trans.pos;
	//p /= trans.scale;
	//p = RotByEuler(p, -trans.rotEuler);
	//return p;
	return world;
}

float3 LocalToWorld(in Transform trans, float3 local)
{
	//float3 p = RotByEuler(local, trans.rotEuler);
	//p *= trans.scale;
	//p += trans.pos;
	//return p;
	return local;
}

//local to world
float3 To3D(in Transform trans, float2 p2d)
{
	return LocalToWorld(trans, float3(p2d.x, 0, p2d.y));
}

//local to world
//assume dir has normalized
float3 DirTo3D(in Transform trans, float2 dir)
{
	float3 re = float3(dir.x, 0, dir.y);
	//return RotByEuler(re, trans.rotEuler);
	return re;
}
#endif