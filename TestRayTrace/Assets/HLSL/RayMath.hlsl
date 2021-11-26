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

//三个vert的法线不一定一致
//1.先3p组成平面,其plane.N要和v1.n的dot为正
HitInfo RayCastTri(Ray ray, Vertex v1, Vertex v2, Vertex v3)
{
	HitInfo re;
	re.bHit = 0;
	re.obj = -1;
	re.N = 0;
	re.P = 0;

	Plane plane = FormPlane(v1.p, v2.p, v3.p, v1.n);

	return re;
}