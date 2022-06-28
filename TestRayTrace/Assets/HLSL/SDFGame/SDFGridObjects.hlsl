#ifndef SDFGRIDOBJECTS_HLSL
#define SDFGRIDOBJECTS_HLSL

#define Fast_MAXSDFTraceCount 256
#define Fast_SDFTraceThre 0.001

#include "../Transform/TransformCommonDef.hlsl"
#include "../Random/RandUtility.hlsl"
#include "../Noise/NoiseCommonDef.hlsl"

float SDFGridGrass(float3 p, float3 center, float grid)
{
	//float randK = rand01(float3(34, 23, 123) * 50 + center * 5);
	float randK = RandFast(center.xz);

	//float randK2 = rand01(float3(43, 32, 127) * 50 + center * 50);
	//float randK3 = rand01(float3(34, 23, 123) * 50 + center * 50);
	float randK2 = RandFast(float2(43,127) + center.xz);
	float randK3 = RandFast(float2(43, 341) + center.xz);

	{
		//return max(0, SDFBox(p, center, 0.05 + float3(0, randK2, 0)));
	}

	float2 offset = grid * 0.5 * (2 * float2(randK2, randK3) - 1);
	center += float3(offset.x, 0, offset.y);

	//center.y += rand01(float3(34, 23, 123)*50 + center * 5) * 2 * Time01(1, center.y);
	//return max(0, SDFBox(p, center, 0.05));
	//???
	float2 windDir = float2(1, 1);
	float windStrength = 0.1 * cos(dot(windDir, 0.1*center.xz) + 2 * PI*frac(_Time.y / 5.0f));
	float2 wdir2d = windStrength * windDir;
	float3 tipDir = normalize(float3(0, 1, 0) + float3(wdir2d.x, 0, wdir2d.y));

	float3 t = float3(1, 0, 0);
	float3 n = float3(0, 0, 1);
	float3 b = float3(0, 1, 0);
	
	//???
	t = float3(cos(2 * PI*randK), 0, sin(2 * PI*randK));
	b = tipDir;
	n = normalize(cross(t, b));
	t = cross(b, n);

	Coord2D coord;
	coord.origin = center + float3(0, 0.4, 0);
	coord.T = t;
	coord.B = b;
	coord.N = n;
	float2 p2d;
	float projDis;
	ProjToCoord2D(p2d, projDis, p, coord);

	//$$$
	//float sdf2d = max(length(p2d) - 0.5,0);
	//float sdf2d = max(SDFBox(p2d,0,0.5),0);
	//randK = normalDistribution(0.01, 1, float3(34, 23, 123) * 50 + center*5, float3(43, 42, 112) * 50 + center*5);
	float grassLen = 0.2 + 0.8 *  randK;

	float2 tip = float2(0, grassLen);
	float sdf2d = SDFTriangle2D(p2d, tip, float2(-0.1, -0.5), float2(0.1, -0.5));

	float d = sqrt(projDis*projDis + sdf2d * sdf2d);
	return d;
}

//### grid sphere
//float grid = 4.0;
//float2 m = floor(p.xz/grid);
//float2 c = grid*(m+0.5);
//float3 center = float3(c.x,CosFBM(c),c.y);
//center.y += rand01(float3(34,23,123)+center*0.1)*2 * Time01(5,center.y);
//float r =0.5;
//float d = max(length(p-center)- r, 0);
//re = min(re,d);

#endif