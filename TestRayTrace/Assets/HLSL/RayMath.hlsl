#ifndef RAYMATH_HLSL
#define RAYMATH_HLSL
#include "CommonDef.hlsl"
float Dis(Ray ray, float3 p)
{
	float3 v = p - ray.pos;
	float mapLen = dot(v, ray.dir);

	//为防止奇怪问题（while中提前return失败），采用最后return的写法
	float re = -1.0f;
	if (mapLen < 0)
	{
	}
	else
	{
		//sqrt(d2-mapLen2)
		float d = length(p - ray.pos);
		re = sqrt(d*d - mapLen * mapLen);
	}
	return re;
} 

struct Plane
{
	float3 p;
	float3 n;
};

Plane FormPlane(float3 p1, float3 p2, float3 p3, float3 guideN)
{
	float3 v1 = p2 - p1;
	float3 v2 = p3 - p1;
	float3 n = normalize( cross(v1, v2) );
	if (dot(n,guideN)<0)
	{
		n = -n;
	}
	Plane re;
	re.p = p1;
	re.n = n;
	return re;
}

//所谓"重心法"：https://blog.csdn.net/wkl115211/article/details/80215421
bool IsPointInsideTri(float3 pos, float3 p1, float3 p2, float3 p3)
{
	float3 v0 = p3 - p1;
	float3 v1 = p2 - p1;
	float3 v2 = pos - p1;

	float dot00 = dot(v0, v0);
	float dot01 = dot(v0, v1);
	float dot02 = dot(v0, v2);
	float dot11 = dot(v1, v1);
	float dot12 = dot(v1, v2);

	float invDeno = 1 / (dot00*dot11 - dot01 * dot01);

	float u = (dot11*dot02 - dot01 * dot12)*invDeno;
	if (u < 0 || u>1)
	{
		return false;
	}

	float v = (dot00*dot12 - dot01 * dot02)*invDeno;
	if (v < 0 || v>1)
	{
		return false;
	}

	return u + v <= 1;
}

//https://blog.csdn.net/qq_41524721/article/details/103490144
float RayCastPlane(Ray ray, Plane plane)
{
	float dd = dot(ray.dir, plane.n);
	if (NearZero(dd))
	{
		return -12345.0f;
	}
	return -dot(ray.pos - plane.p, plane.n) / dd;
}

//### NormBlend
float3 Tri_P1CInterP2P3(float3 c, Vertex v1, Vertex v2, Vertex v3)
{
	float3 p1 = v1.p;
	float3 p2 = v2.p;
	float3 p3 = v3.p;
	Plane plane1 = FormPlane(v1.p, v2.p, v3.p, v1.n);
	float3 n2 = cross(plane1.n, normalize(p3 - p2));
	Plane plane2;
	plane2.n = n2;
	plane2.p = p2;
	Ray ray;
	ray.pos = c;
	ray.dir = normalize(c - p1);
	float k = RayCastPlane(ray, plane2);
	if (k < 0)
	{
		return c;
	}
	return c + k * ray.dir;
}

//1. 获取p1c与p2p3的交点c2 https://blog.csdn.net/qq_41524721/article/details/121606678
//2. 根据相似，CA:C2P2 = P1C:P1C2 , 求出A
void Tri_ParallelP2P3(out float3 A, out float3 B, float3 c, Vertex v1, Vertex v2, Vertex v3)
{
	float3 p1 = v1.p;
	float3 p2 = v2.p;
	float3 p3 = v3.p;
	float3 c2 = Tri_P1CInterP2P3(c, v1, v2, v3);

	float lenP1C2 = length(p1 - c2);

	if (NearZero(lenP1C2))
	{
		A = p2;
		B = p3;
		return;
	}

	float lenCA = length(p1 - c) * length(p2 - c2) / length(p1 - c2);
	float3 dir1 = normalize(p2 - p3);
	A = c + dir1 * lenCA;

	float lenCB = length(p1 - c) * length(p3 - c2) / length(p1 - c2);
	float3 dir2 = -dir1;
	B = c + dir2 * lenCB;
}

//根据A lerp(n1,n2)，根据B lerp(n1,n3)，根据c lerp(nA, nB)
float3 GetTriBlendedNorm(float3 c, Vertex v1, Vertex v2, Vertex v3)
{
	float3 p1 = v1.p;
	float3 p2 = v2.p;
	float3 p3 = v3.p;

	float lenP2P1 = length(p2 - p1);
	float lenP3P1 = length(p3 - p1);

	if (NearZero(lenP2P1))
	{
		return lerp(v1.n, v3.n, 0.5f);
	}
	if (NearZero(lenP3P1))
	{
		return lerp(v1.n, v2.n, 0.5f);
	}

	float3 A, B;
	Tri_ParallelP2P3(A, B, c, v1, v2, v3);

	float kA = length(A - p1) / lenP2P1;
	float3 nA = lerp(v1.n, v2.n, kA);

	float kB = length(B - p1) / lenP3P1;
	float3 nB = lerp(v1.n, v3.n, kB);
	
	float lenAB = length(B - A);
	float kC=0;
	if (NearZero(lenAB))
	{
		kC = 0.5f;
	}
	else
	{
		kC = length(c - A) / lenAB;
	}
	return lerp(nA, nB, kC);
}
//### NormBlend

bool FrontFace(float3 pos, Plane plane)
{
	return dot(pos-plane.p,plane.n) >= 0;
}

//(三个vert的法线不一定一致)
//1.先3p组成平面,其plane.N要和v1.n的dot为正
//2.得到与平面交点，判断是否在三角形内（重心法）
//3.根据位置Blend三个vert的N
HitInfo RayCastTri(Ray ray, Vertex v1, Vertex v2, Vertex v3)
{
	HitInfo re;
	re.bHit = 0;
	re.obj = -1;
	re.N = 0;
	re.P = 0;

	Plane plane = FormPlane(v1.p, v2.p, v3.p, v1.n);

	if (!FrontFace(ray.pos, plane))
	{
		return re;
	}

	float k = RayCastPlane(ray, plane);

	//如果屏幕在射线反方向
	if (k < 0)
	{
		return re;
	}

	re.P = ray.pos + ray.dir*k;
	re.bHit = IsPointInsideTri(re.P, v1.p, v2.p, v3.p);

	//如果打点在三角形之外
	if (!re.bHit)
	{
		return re;
	}

	//Blend三个顶点的Normal
	re.N = GetTriBlendedNorm(re.P, v1, v2, v3);

	return re;
}

//x: phi [0,2PI)
//y: theta [0,PI]
//z: r
float3 CartesianToSpherical(in float3 xyz)
{
	float r = length(xyz);
	xyz *= 1.f / r;
	float theta = acos(xyz.z);

	float phi = atan2(xyz.y, xyz.x); //atan [-PI,PI]
	phi += PI;

	return float3(phi, theta, r);
}

float3 XYZ_StandardFromUnity(float3 p)
{
	p.z = -p.z;
	p.xyz = p.xzy;
	return p;
}

float2 EquirectangularToUV(float3 dir)
{
	float2 uv = 0;
	dir = normalize(dir);
	dir = XYZ_StandardFromUnity(dir);
	//!!!
	//由于转球系是需要有x,y,z规定的，
	//所以要先转成标准方向
	// get theta phi from x, y comp (phi [0,2PI) theta [0,PI] )
	float3 sphereCoord = CartesianToSpherical(dir);
	uv.x = sphereCoord.x;
	uv.x /= 2 * PI;

	uv.y = sphereCoord.y;
	uv.y /= PI;

	uv = saturate(uv);
	uv.y = 1 - uv.y;
	return uv;
}

#endif