#define OBJNUM 8

#define TraceThre 0.01
#define TraceStart 0.05

float SDFBox(float3 p, float3 center, float3 bound)
{
	float3 q = abs(p - center) - bound;
	return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float GetObjSDF(int inx, float3 p)
{
	float xDis = 2.0;
	float height = 4.0;
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
		return SDFBox(p, float3(0.0, height, -5.0), float3(8.0, 0.1, 8.0));
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
		return SDFBox(p, float3(0.0, height-0.1, -5.0), float3(0.8, 0.08, 0.8));
		//return SDFBox(p, float3(0.0, 3.9, -5.0), float3(1.5, 0.08, 1.5));
		//return length(p - float3(0, 3.5, -5)) - 0.2;
	}
	else if (inx == 7)
	{//前（封光）
		return SDFBox(p, float3(0.0, 0.0, 1.1), float3(8.0, 8.0, 0.1));
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
	float maxTraceDis = 100.0f;

	float traceDis = -1.0f;
	int objInx = -1;
	float objSDF[OBJNUM];
	float sdf = 1000; //a very large,can be larger than maxTraceDis

	//old错误方法：ray.pos += ray.dir*TraceStart;
	//new方法：向N方向走出去
	int c1 = 0;
	while (c1<10000)
	{
		sdf = 1000;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			objSDF[inx] = GetObjSDF(inx, ray.pos);
			if (objSDF[inx] < sdf)
			{
				sdf = objSDF[inx];
				objInx = inx;
			}
		}
		if (sdf >= TraceStart)
		{
			break;
		}

		ray.pos += GetObjNormal(objInx, ray.pos)*TraceStart;
		c1 += 1;
	}
	
	int c2 = 0;
	while (c2<10000)
	{
		sdf = 1000; //a very large,can be larger than maxTraceDis
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
			info.P = ray.pos;
			info.N = GetObjNormal(objInx, ray.pos);
			//int count = 1;
			//while (length(info.N)<0.001)
			//{
			//	info.N = GetObjNormal(objInx, info.P - ray.dir*0.001*count);
			//	count++;
			//}
			break;
		}
		ray.pos += ray.dir*sdf;
		c2 += 1;
	}
	if (c2 > 10000)
	{
		info.bHit = -1;
	}
}