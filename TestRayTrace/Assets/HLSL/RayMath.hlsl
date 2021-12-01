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
	return -dot(ray.pos - plane.p, plane.n) / dot(ray.dir, plane.n);
}

float3 GetTriBlendedNorm(float3 pos, Vertex v1, Vertex v2, Vertex v3)
{
	//???
	return v1.n;
}

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