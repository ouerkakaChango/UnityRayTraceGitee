#ifndef GRIDMATH_HLSL
#define GRIDMATH_HLSL
#include "CommonDef.hlsl"

int ModInx(float x, float cellLength)
{
	if (x < 0 || cellLength <= 0)
	{
		return -1;
	}
	return (int)((x - fmod(x, cellLength)) / cellLength);
}

float3 ModInx(float3 p, float3 cellLength)
{
	return float3(ModInx(p.x, cellLength.x),
		ModInx(p.y, cellLength.y),
		ModInx(p.z, cellLength.z));
}

//https://github.com/ouerkakaChango/ParticleToy/blob/68351769dbf801c29c796b955336b9cc077d19c3/include/Base/FastGrid.h
int3 GetCellInx(in float3 pntPos, in float3 startPos, in float3 unit, in float3 subDivide)
{
	float3 local = pntPos - startPos;
	int3 inx = ModInx(local, unit);

	//在计算pntPos的cellInx的时候，计算的是cell内的左下方点，
	//但是当p正好在右上方的时候，用Mod已经越过了这个cell，正好在(+1,+1,+1)的左下方点，需要-1处理
	if (equal(inx.x, subDivide.x))
	{
		inx.x -= 1;
	}
	if (equal(inx.y, subDivide.y))
	{
		inx.y -= 1;
	}
	if (equal(inx.z, subDivide.z))
	{
		inx.z -= 1;
	}
	return inx;
}

//7 6
//4 5
//
//3 2 
//0 1
float lerp3D(in float nums[8], float3 uvw)
{
	float lerpx1 = lerp(nums[0], nums[1], uvw.x);
	float lerpx2 = lerp(nums[3], nums[2], uvw.x);
	float lerpy1 = lerp(lerpx1, lerpx2, uvw.y);

	float lerpx3 = lerp(nums[4], nums[5], uvw.x);
	float lerpx4 = lerp(nums[7], nums[6], uvw.x);
	float lerpy2 = lerp(lerpx3, lerpx4, uvw.y);

	float lerpz = lerp(lerpy1, lerpy2, uvw.z);

	return lerpz;
}
#endif