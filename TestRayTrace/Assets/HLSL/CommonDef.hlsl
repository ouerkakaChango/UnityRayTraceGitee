#ifndef COMMONDEF_HLSL
#define COMMONDEF_HLSL

struct Ray
{
	float3 pos;
	float3 dir;
};

struct Vertex
{
	float3 p;
	float3 n;
};

struct HitInfo
{
	int bHit;
	int obj;
	float3 N;
	float3 P;
};

void Init(out HitInfo re)
{
	re.bHit = 0;
	re.obj = -1;
	re.N = 0;
	re.P = 0;
}

void Assgin(out HitInfo re, HitInfo hit)
{
	re.bHit = hit.bHit;
	re.obj = hit.obj;
	re.N = hit.N;
	re.P = hit.P;
}

bool NearZero(float x)
{
	return abs(x) < 0.000001f;
}

#endif