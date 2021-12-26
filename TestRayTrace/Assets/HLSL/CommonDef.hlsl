#ifndef COMMONDEF_HLSL
#define COMMONDEF_HLSL

#define PI 3.14159f

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

struct CastInfo
{
	bool bHit;
	float dis;
};

void Init(out HitInfo re)
{
	re.bHit = 0;
	re.obj = -1;
	re.N = 0;
	re.P = 0;
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

bool NearZero(float x)
{
	return abs(x) < 0.000001f;
}

bool gt(float3 a, float3 b)
{
	return a.r > b.r&&a.g > b.g&&a.b > b.b;
}

bool lt(float3 a, float3 b)
{
	return a.r < b.r&&a.g < b.g&&a.b < b.b;
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

#endif