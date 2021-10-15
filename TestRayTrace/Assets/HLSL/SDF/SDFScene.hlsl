#define OBJNUM 7

#define TraceThre 0.01
#define StartLen 0.1

float SDFBox(float3 p, float3 center, float3 bound)
{
	float3 q = abs(p - center) - bound;
	return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float GetObjSDF(int inx, float3 p)
{
	float xDis = 2.0;

	if (inx == 0)
	{//球
		//sphere center(0, 0, -5), radius 1
		return length(p - float3(0, 0, -5)) - 1;
	}
	else if (inx == 1)
	{//地面
		//box center(0, -1.2, -5), bound(5, 0.1, 5)
		return SDFBox(p, float3(0, -1.2, -5), float3(5, 0.1, 5));
	}
	else if (inx == 2)
	{//上
		return SDFBox(p, float3(0.0, 4.05, -5.0), float3(8.0, 0.1, 8.0));
	}
	else if (inx == 3)
	{//左
		return SDFBox(p, float3(-xDis, 0.0, -5.0), float3(0.1, 5.0, 5.0));
	}
	else if (inx == 4)
	{//右
		return SDFBox(p, float3(xDis, 0.0, -5.0), float3(0.1, 5.0, 5.0));
	}
	else if (inx == 5)
	{//后
		return SDFBox(p, float3(0.0, 0.0, -6.5), float3(8.0, 8.0, 0.1));
	}
	else if (inx == 6)
	{//lightBox
		return SDFBox(p, float3(0.0, 3.9, -5.0), float3(0.8, 0.08, 0.8));
	}
	else
	{
		return -1;
	}
}

float3 GetObjSDFNormal(int inx, float3 p)
{
	float epsilon = 0.0001f;
	return normalize(float3(
		GetObjSDF(inx, float3(p.x + epsilon, p.y, p.z)) - GetObjSDF(inx, float3(p.x - epsilon, p.y, p.z)),
		GetObjSDF(inx, float3(p.x, p.y + epsilon, p.z)) - GetObjSDF(inx, float3(p.x, p.y - epsilon, p.z)),
		GetObjSDF(inx, float3(p.x, p.y, p.z + epsilon)) - GetObjSDF(inx, float3(p.x, p.y, p.z - epsilon))
		));
}

float3 GetObjNormal(int inx, float3 p)
{
	if (inx == 0)
	{
		//sphere center(0, 0, -5), radius 1
		return normalize(p - float3(0, 0, -5));
	}
	else
	{
		return GetObjSDFNormal(inx, p);
	}
}

void SDFScene(inout Ray ray,out HitInfo info)
{
	float maxTraceDis = 20.0f;

	float traceDis = -1.0f;
	int objInx = -1;

	ray.pos += ray.dir*StartLen;
	while (true)
	{
		float objSDF[OBJNUM];
		float sdf = 1000; //a very large,can be larger than maxTraceDis
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			objSDF[inx] = GetObjSDF(inx, ray.pos);
			if (objSDF[inx] < sdf)
			{
				sdf = objSDF[inx];
				objInx = inx;
			}
		}

		if (sdf > maxTraceDis)
		{
			break;
		}
		else if (sdf <= TraceThre)
		{
			traceDis = sdf;
			info.bHit = 1;
			info.obj = objInx;
			info.N = GetObjNormal(objInx, ray.pos);
			info.P = ray.pos;
			break;
		}
		ray.pos += ray.dir*sdf;
	}
}

float3 GetObjEmissive(int obj)
{
	if (obj == 6)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}