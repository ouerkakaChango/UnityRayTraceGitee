#ifndef COMMONDEF_HLSL
#define COMMONDEF_HLSL

#define PI 3.14159
#define TWOPI 6.2831853
#define MAXFLOAT 3.402823e38

#include "UnityCommonDef.hlsl"

struct Ray
{
	float3 pos;
	float3 dir;
};

struct Vertex
{
	float3 p;
	float3 n;
	float2 uv;
};

struct HitInfo
{
	int bHit;
	int obj;
	float3 N;
	float3 P;
};

struct TraceInfo
{
	int traceCount;
	float traceSum;
	float lastTrace;
};

struct VertHitInfo
{
	int bHit;
	int obj;
	float3 n;
	float3 p;
	float2 uv;
};

struct CastInfo
{
	bool bHit;
	float dis;
};

struct Grid
{
	float3 startPos;
	float3 unitCount;
	float3 unit;
};

void Init(out HitInfo re)
{
	re.bHit = 0;
	re.obj = -1;
	re.N = 0;
	re.P = 0;
}

void Init(out TraceInfo re, float maxSDF = 1000000)
{
	re.traceCount = 0;
	re.traceSum = 0;
	re.lastTrace = maxSDF;
}

void Init(out VertHitInfo re)
{
	re.bHit = 0;
	re.obj = -1;
	re.n = 0;
	re.p = 0;
	re.uv = 0;
}

void Init(out CastInfo re)
{
	re.bHit = false;
	re.dis = 0;
}

void Assgin(out HitInfo re, HitInfo hit)
{
	re.bHit = hit.bHit;
	re.obj = hit.obj;
	re.N = hit.N;
	re.P = hit.P;
}

void Update(inout TraceInfo traceInfo, float sdf)
{
	traceInfo.traceCount += 1;
	traceInfo.traceSum += sdf;
	traceInfo.lastTrace = sdf;
}

bool NearZero(float x)
{
	return abs(x) < 0.000001f;
}

bool gt(float2 a, float2 b)
{
	return a.x > b.x && a.y > b.y;
}

bool gtor(float2 a, float2 b)
{
	return a.x > b.x || a.y > b.y;
}

bool gt(float3 a, float3 b)
{
	return a.x > b.x && a.y > b.y && a.z > b.z;
}

bool lt(float3 a, float3 b)
{
	return a.x < b.x && a.y < b.y && a.z < b.z;
}

bool equal(float a, float b, float tolerance = 0.000001f)
{
	return abs(a - b) < tolerance;
}

bool equal(float3 a, float3 b, float tolerance = 0.000001f)
{
	return equal(a.x, b.x, tolerance) &&
		equal(a.y, b.y, tolerance) &&
		equal(a.z, b.z, tolerance);
}

float smooth3(float t)
{
	return t * t * (3.0 - 2.0 * t);
}

float3 smooth3(float3 t)
{
	return t * t * (3.0 - 2.0 * t);
}

//https://stackoverflow.com/questions/28740544/inverted-smoothstep
float invSmooth3(float x) {
	return x + (x - (x * x * (3.0f - 2.0f * x)));

	//if (x <= 0)return 0;
	//if (x >= 1)return 1;
	//return 0.5f - sin(asin(1 - 2 * x) / 3);
}

int GetTreeDepth(int inx,int maxDepth)
{
	//depht = 2,  >=2^2-1, <=2^3-2
	for (int i = 0; i <= maxDepth; i++)
	{
		int up = (int)pow(2, i + 1) - 2;
		if(inx< up)
		{
			return i;
		}
	}
	return -1;
}

float2 GetUV(RWTexture2D<float4> dst, uint3 id)
{
	uint dstW, dstH;
	dst.GetDimensions(dstW, dstH);
	return float2(
		((float)id.x) / dstW,
		((float)id.y) / dstH);
}

float2 GetUV(Texture2D<float4> dst, uint3 id)
{
	uint dstW, dstH;
	dst.GetDimensions(dstW, dstH);
	return float2(
		((float)id.x) / dstW,
		((float)id.y) / dstH);
}

uint2 GetSize(RWTexture2D<float4> dst)
{
	uint2 size;
	dst.GetDimensions(size.x, size.y);
	return size;
}

uint2 GetSize(Texture2D<float4> dst)
{
	uint2 size;
	dst.GetDimensions(size.x, size.y);
	return size;
}

float Time01(float frequency=1.0f,float phi = 0.0f)
{
	return 0.5*(sin(frequency * _Time.y+phi) + 1);
}
 
bool Is01(float x)
{
	return x > 0 && x < 1;
}

float length2(float2 x)
{
	return dot(x, x);
}

float len2(float x)
{
	return x * x;
}
float cross2D(float2 v1, float2 v2)
{
	return v1.x*v2.y - v1.y*v2.x;
}

float addv(float2 a) { return a.x + a.y; }

float2 TexSafePos(float2 pos, uint2 size)
{
	float2 re = pos;
	if (re.x < 0)
	{
		re.x = 0;
	}
	else if (re.x >= size.x)
	{
		re.x = size.x - 1;
	}

	if (re.y < 0)
	{
		re.y = 0;
	}
	else if (re.y > size.y)
	{
		re.y = size.y - 1;
	}
	return re;
}

SamplerState common_point_repeat_sampler;
SamplerState common_linear_repeat_sampler;
float BilinearR(Texture2D tex, float2 floorPos, float2 fracPart)
{
	uint2 size = GetSize(tex);
	//float x00 = tex[floorPos].r;
	//float x10 = tex[TexSafePos(floorPos + int2(1, 0), size)].r;
	//float x01 = tex[TexSafePos(floorPos + int2(0, 1), size)].r;
	//float x11 = tex[TexSafePos(floorPos + int2(1, 1), size)].r;
	float x00 = tex.SampleLevel(common_point_repeat_sampler, floorPos/size, 0).x;
	float x10 = tex.SampleLevel(common_point_repeat_sampler, TexSafePos(floorPos + int2(1, 0), size) / size, 0).x;
	float x01 = tex.SampleLevel(common_point_repeat_sampler, TexSafePos(floorPos + int2(0, 1), size) / size, 0).x;
	float x11 = tex.SampleLevel(common_point_repeat_sampler, TexSafePos(floorPos + int2(1, 1), size) / size, 0).x;
	float x0 = lerp(x00, x10, fracPart.x);
	float x1 = lerp(x01, x11, fracPart.x);
	return lerp(x0, x1, fracPart.y);
}

//https://www.shadertoy.com/view/wt23Rt
float3 RGBToHSV(float3 c) {
	float4 K = float4(0., -1. / 3., 2. / 3., -1.),
		p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g)),
		q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y),
		e = 1e-10;
	return float3(abs(q.z + (q.w - q.y) / (6.*d + e)), d / (q.x + e), q.x);
}

//https://www.shadertoy.com/view/MsS3Wc
float3 HSVToRGB_iq(in float3 c)
{
	float3 rgb = clamp(abs(fmod(c.x*6.0 + float3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
	rgb = rgb * rgb*(3.0 - 2.0*rgb); // cubic smoothing	
	return c.z * lerp(float3(1,1,1), rgb, c.y);
}

//https://www.shadertoy.com/view/wt23Rt
float3 HSVToRGB(float3 c) {
	float4 K = float4(1., 2. / 3., 1. / 3., 3.);
	return c.z*lerp(K.xxx, saturate(abs(frac(c.x + K.xyz)*6. - K.w) - K.x), c.y);
}

#endif