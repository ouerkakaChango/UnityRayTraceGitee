#ifndef RAYMATH_HLSL
#define RAYMATH_HLSL
#include "CommonDef.hlsl"

float Dis(Ray ray, float3 p)
{
	float3 v = p - ray.pos;
	float mapLen = dot(v, ray.dir);

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
		if (NearZero(dot(ray.pos - plane.p, plane.n)))
		{//rayPos is in plane,consider ray dis is 0
			return 0;
		}
		else 
		{//not cast,infinite intersection
			return -12345;
		}
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

float3 Tri_P1CInterP2P3(float3 c, float3 p1, float3 p2, float3 p3, float3 guideN)
{
	Plane plane1 = FormPlane(p1, p2, p3, guideN);
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

//1. 获取p1c与p2p3的交点c2 https://blog.csdn.net/qq_41524721/article/details/121606678
//2. 根据相似，CA:C2P2 = P1C:P1C2 , 求出A
void Tri_ParallelP2P3(out float3 A, out float3 B, float3 c, float3 p1, float3 p2, float3 p3, float3 guideN)
{
	float3 c2 = Tri_P1CInterP2P3(c, p1, p2, p3, guideN);

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

float3 GetTriKForBlend(float3 c, float3 p1, float3 p2, float3 p3, float3 guideN)
{
	float lenP2P1 = length(p2 - p1);
	float lenP3P1 = length(p3 - p1);

	float3 A, B;
	Tri_ParallelP2P3(A, B, c, p1, p2, p3, guideN);


	float kA, kB;
	if (NearZero(lenP2P1))
	{
		kA = 0.5f;
	}
	else
	{
		kA = length(A - p1) / lenP2P1;
	}
	if (NearZero(lenP3P1))
	{
		kB = 0.5f;
	}
	else
	{
		kB = length(B - p1) / lenP3P1;
	}

	float lenAB = length(B - A);
	float kC = 0;
	if (NearZero(lenAB))
	{
		kC = 0.5f;
	}
	else
	{
		kC = length(c - A) / lenAB;
	}
	return float3(kA, kB, kC);
}

float3 GetTriBlended(float3 triK,float3 val1, float3 val2, float3 val3)
{
	float3 nA = lerp(val1, val2, triK.x);
	float3 nB = lerp(val1, val3, triK.y);
	return lerp(nA, nB, triK.z);
}

float2 GetTriBlended(float3 triK, float2 val1, float2 val2, float2 val3)
{
	float2 nA = lerp(val1, val2, triK.x);
	float2 nB = lerp(val1, val3, triK.y);
	return lerp(nA, nB, triK.z);
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

VertHitInfo RayCastVertTri(Ray ray, Vertex v1, Vertex v2, Vertex v3)
{
	VertHitInfo re;
	Init(re);

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

	re.p = ray.pos + ray.dir*k;
	re.bHit = IsPointInsideTri(re.p, v1.p, v2.p, v3.p);

	//如果打点在三角形之外
	if (!re.bHit)
	{
		return re;
	}

	float3 triK = GetTriKForBlend(re.p, v1.p, v2.p, v3.p, v1.n);
	re.n = GetTriBlended(triK, v1.p, v2.p, v3.n);
	re.uv = GetTriBlended(triK, v1.uv, v2.uv, v3.uv);

	return re;
}
//###############################################################################
//默认该Normalize的已经normalize
//Plane是quad所在plane,plane.p是quad的某顶点
//size是quad的大小，v1,v2是以plane.p为起点，两边的方向向量，和size顺序对应
bool IsRayQuad_Corner(Ray ray, Plane plane, float2 size, float3 v1, float3 v2)
{
	if (dot(ray.dir, plane.n) >= 0)
	{
		return false;
	}

	float dis = RayCastPlane(ray, plane);
	if (dis < 0)
	{
		return false;
	}
	float3 hitP = ray.pos + dis * ray.dir;
	float3 center = plane.p + v1 * size.x / 2 + v2 * size.y / 2;
	float3 dv = hitP - center;
	return
		(abs(dot(dv, v1)) <= (size.x / 2)) &&
		(abs(dot(dv, v2)) <= (size.y / 2));
}

//默认该Normalize的已经normalize
//Plane是quad所在plane,plane.p是quad的某顶点
//size是quad的大小，v1,v2是以plane.p为起点，两边的方向向量，和size顺序对应
CastInfo CastQuad_Corner(in Ray ray, in Plane plane, in float2 size, in float3 v1, in float3 v2)
{
	CastInfo re;
	Init(re);

	if (dot(ray.dir, plane.n) >= 0)
	{
		return re;
	}

	re.dis = RayCastPlane(ray, plane);
	if (re.dis < 0)
	{
		return re;
	}
	float3 hitP = ray.pos + re.dis * ray.dir;
	float3 center = plane.p + v1 * size.x / 2 + v2 * size.y / 2;
	float3 dv = hitP - center;
	re.bHit = (abs(dot(dv, v1)) <= (size.x / 2)) &&
		(abs(dot(dv, v2)) <= (size.y / 2));
	return re;
}

//1.从x,y,z方向，每两个平面和ray测交点
//只要有一个交点在bbox内，则返回true
CastInfo CastBBox(in Ray ray, in float3 min, in float3 max)
{
	CastInfo re;
	Init(re);

	if (gt(ray.pos, min) && lt(ray.pos, max))
	{
		re.bHit = true;
		return re;
	}

	//1.x方向
	Plane plane;
	plane.p = min;
	plane.n = float3(-1, 0, 0);
	float2 quadSize = max.yz - min.yz;
	re = CastQuad_Corner(ray, plane, quadSize, float3(0, 1, 0), float3(0, 0, 1));
	if (re.bHit)
	{
		return re;
	}

	plane.p = max;
	plane.n = float3(1, 0, 0);
	re = CastQuad_Corner(ray, plane, quadSize, float3(0, -1, 0), float3(0, 0, -1));
	if (re.bHit)
	{
		return re;
	}

	//2.y方向
	plane.p = min;
	plane.n = float3(0, -1, 0);
	quadSize = max.xz - min.xz;
	re = CastQuad_Corner(ray, plane, quadSize, float3(1, 0, 0), float3(0, 0, 1));
	if (re.bHit)
	{
		return re;
	}

	plane.p = max;
	plane.n = float3(0, 1, 0);
	re = CastQuad_Corner(ray, plane, quadSize, float3(-1, 0, 0), float3(0, 0, -1));
	if (re.bHit)
	{
		return re;
	}

	//3.z方向
	plane.p = min;
	plane.n = float3(0, 0, -1);
	quadSize = max.xy - min.xy;
	re = CastQuad_Corner(ray, plane, quadSize, float3(1, 0, 0), float3(0, 1, 0));
	if (re.bHit)
	{
		return re;
	}

	plane.p = max;
	plane.n = float3(0, 0, 1);
	re = CastQuad_Corner(ray, plane, quadSize, float3(-1, 0, 0), float3(0, -1, 0));
	if (re.bHit)
	{
		return re;
	}

	return re;
}

//https://blog.csdn.net/Qinhaifu/article/details/102629742
//bool IsRayAABB(in Ray ray, float3 min, float3 max)
//{
//	float lowt = 0.0f;
//	float t;
//	bool hit = false;
//	float3 hitpoint;
//	
//	/**
//	*   点在包围盒里面
//	*/
//	if (gt(ray.pos,min) && lt(ray.pos,max))
//	{
//		return true;
//	}
//	
//	// Check each face in turn, only check closest 3
//	// Min x
//	if (ray.pos.x <= min.x && ray.dir.x > 0)
//	{
//		t = (min.x - ray.pos.x) / ray.dir.x;
//		if (t >= 0)
//		{
//			// Substitute t back into ray and check bounds and dist
//			hitpoint = ray.pos + ray.dir * t;
//			if (hitpoint.y >= min.y &&
//				hitpoint.y <= max.y &&
//				hitpoint.z >= min.z &&
//				hitpoint.z <= max.z
//				)
//			{
//				return true;
//			}
//		}
//	}
//	// Max x
//	if (ray.pos.x >= max.x && ray.dir.x < 0)
//	{
//		t = (max.x - ray.pos.x) / ray.dir.x;
//		if (t >= 0)
//		{
//			// Substitute t back into ray and check bounds and dist
//			hitpoint = ray.pos + ray.dir * t;
//			if (hitpoint.y >= min.y &&
//				hitpoint.y <= max.y &&
//				hitpoint.z >= min.z &&
//				hitpoint.z <= max.z 
//				)
//			{
//				return true;
//			}
//		}
//	}
//	// Min y
//	if (ray.pos.y <= min.y && ray.dir.y > 0)
//	{
//		t = (min.y - ray.pos.y) / ray.dir.y;
//		if (t >= 0)
//		{
//			// Substitute t back into ray and check bounds and dist
//			hitpoint = ray.pos + ray.dir * t;
//			if (hitpoint.x >= min.x &&
//				hitpoint.x <= max.x &&
//				hitpoint.z >= min.z &&
//				hitpoint.z <= max.z 
//				)
//			{
//				return true;
//			}
//		}
//	}
//	// Max y
//	if (ray.pos.y >= max.y && ray.dir.y < 0)
//	{
//		t = (max.y - ray.pos.y) / ray.dir.y;
//		if (t >= 0)
//		{
//			// Substitute t back into ray and check bounds and dist
//			hitpoint = ray.pos + ray.dir * t;
//			if (hitpoint.x >= min.x &&
//				hitpoint.x <= max.x &&
//				hitpoint.z >= min.z &&
//				hitpoint.z <= max.z 
//				)
//			{
//				return true;
//			}
//		}
//	}
//	// Min z
//	if (ray.pos.z <= min.z && ray.dir.z > 0)
//	{
//		t = (min.z - ray.pos.z) / ray.dir.z;
//		if (t >= 0)
//		{
//			// Substitute t back into ray and check bounds and dist
//			hitpoint = ray.pos + ray.dir * t;
//			if (hitpoint.x >= min.x &&
//				hitpoint.x <= max.x &&
//				hitpoint.y >= min.y &&
//				hitpoint.y <= max.y
//				)
//			{
//				return true;
//			}
//		}
//	}
//	// Max z
//	if (ray.pos.z >= max.z && ray.dir.z < 0)
//	{
//		t = (max.z - ray.pos.z) / ray.dir.z;
//		if (t >= 0)
//		{
//			// Substitute t back into ray and check bounds and dist
//			hitpoint = ray.pos + ray.dir * t;
//			if (hitpoint.x >= min.x &&
//				hitpoint.x <= max.x &&
//				hitpoint.y >= min.y &&
//				hitpoint.y <= max.y 
//				)
//			{
//				return true;
//			}
//		}
//	}
//	return false;
//}

bool IsInBBox(in float3 pos, in float3 boxMin, in float3 boxMax)
{
	return gt(pos, boxMin) && lt(pos, boxMax);
}

#endif