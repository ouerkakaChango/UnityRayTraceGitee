#ifndef COMMONDEF_HLSL
#define COMMONDEF_HLSL

#define PI 3.14159f
#define MAXFLOAT 3.402823e38

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

bool NearZero(float x)
{
	return abs(x) < 0.000001f;
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

#endif