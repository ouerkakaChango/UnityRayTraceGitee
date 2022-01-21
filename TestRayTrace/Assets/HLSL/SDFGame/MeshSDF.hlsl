#ifndef MESHSDF_HLSL
#define MESHSDF_HLSL
#include "../CommonDef.hlsl"
#include "../GridMath.hlsl"
#include "../RayMath.hlsl"

#define MAXMeshSDFTrace 660

float GetMeshSDFByInx(int3 inx, in Grid grid, in StructuredBuffer<float> sdfArr)
{
	return sdfArr[inx.x + inx.y *(grid.unitCount.x) + inx.z*(grid.unitCount.x*grid.unitCount.y)];
}

float GetMeshSDF(in float3 p, in Grid grid, in StructuredBuffer<float> sdfArr)
{
	//1.根据p-startPos，再除unit，得到当前位置i,j,k
	int3 inx = GetCellInx(p, grid.startPos, grid.unit, grid.unitCount - 1);
	float arr[8];
	arr[0] = GetMeshSDFByInx(inx + int3(0, 0, 0), grid, sdfArr);
	arr[1] = GetMeshSDFByInx(inx + int3(1, 0, 0), grid, sdfArr);
	arr[2] = GetMeshSDFByInx(inx + int3(1, 1, 0), grid, sdfArr);
	arr[3] = GetMeshSDFByInx(inx + int3(0, 1, 0), grid, sdfArr);
										
	arr[4] = GetMeshSDFByInx(inx + int3(0, 0, 1), grid, sdfArr);
	arr[5] = GetMeshSDFByInx(inx + int3(1, 0, 1), grid, sdfArr);
	arr[6] = GetMeshSDFByInx(inx + int3(1, 1, 1), grid, sdfArr);
	arr[7] = GetMeshSDFByInx(inx + int3(0, 1, 1), grid, sdfArr);

	float3 cellStart = grid.startPos + grid.unit * inx;
	float3 uvw = (p - cellStart) / grid.unit;
	//???
	uvw = saturate(uvw);
	float re = lerp3D(arr, uvw);

	//inspired by iq ,although down the precision, but solve the hole problem
	return re * 0.5f;
}

float3 GetMeshSDFNormal(float3 p, in Grid grid, in StructuredBuffer<float> sdfArr)
{
	float k = 0.5;
	return normalize(float3(
		GetMeshSDF(float3(p.x + grid.unit.x*k, p.y, p.z), grid, sdfArr) - GetMeshSDF(float3(p.x - grid.unit.x*k, p.y, p.z), grid, sdfArr),
		GetMeshSDF(float3(p.x, p.y + grid.unit.y*k, p.z), grid, sdfArr) - GetMeshSDF(float3(p.x, p.y - grid.unit.y*k, p.z), grid, sdfArr),
		GetMeshSDF(float3(p.x, p.y, p.z + grid.unit.z*k), grid, sdfArr) - GetMeshSDF(float3(p.x, p.y, p.z - grid.unit.z*k), grid, sdfArr)
		));
}

void TraceMeshSDFInBox(Ray ray, out HitInfo info,
	in Grid grid, in StructuredBuffer<float> sdfArr)
{
	Init(info);

	float3 boxMin = grid.startPos;
	float3 boxMax = grid.startPos + (grid.unitCount - 1) * grid.unit;

	int traceCount = 0;
	while (traceCount <= MAXMeshSDFTrace)
	{
		if (!IsInBBox(ray.pos, boxMin, boxMax))
		{
			break;
		}

		//get sdf at now pos
		float sdf = GetMeshSDF(ray.pos, grid, sdfArr);

		if (sdf <= length(grid.unit)*0.5)
		{
			info.bHit = true;
			//!!!
			info.obj = 0;
			info.N = GetMeshSDFNormal(ray.pos, grid, sdfArr);
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		traceCount++;
	}
}

void TraceMeshSDFLocal(Ray ray, out HitInfo info,
	in Grid grid, in StructuredBuffer<float> sdfArr)
{
	Init(info);

	Ray sampleRay = ray;
	bool needTrace = true;
	float3 boxMin = grid.startPos;
	float3 boxMax = grid.startPos + (grid.unitCount - 1) * grid.unit;
	if (!IsInBBox(ray.pos, boxMin, boxMax))
	{
		CastInfo castInfo = CastBBox(ray, boxMin, boxMax);
		if (castInfo.bHit)
		{
			//!!! offset 0.00..1f is a must!
			sampleRay.pos += sampleRay.dir * (castInfo.dis + 0.0001f);
		}
		else
		{
			needTrace = false;
		}
	}
	//盒子内和会打到盒子的ray都需要进行SDFSphereTrace
	if (needTrace)
	{
		TraceMeshSDFInBox(sampleRay, info, grid, sdfArr);
	}
}

//###############################################################################
float SoftShadow_TraceMeshSDFInBox(Ray ray, out HitInfo info, float softK, float3 ori,
	in Grid grid, in StructuredBuffer<float> sdfArr) 
{
	float sha = 1.0f;
	float tempDis = 0.001f;

	Init(info);

	float3 boxMin = grid.startPos;
	float3 boxMax = grid.startPos + (grid.unitCount - 1) * grid.unit;

	int traceCount = 0;
	while (traceCount <= MAXMeshSDFTrace)
	{
		if (!IsInBBox(ray.pos, boxMin, boxMax))
		{ 
			break;
		}

		//get sdf at now pos
		float sdf = GetMeshSDF(ray.pos, grid, sdfArr);

		sha = min(sha, softK * sdf / tempDis);
		if (sdf < 0.001f)
		{
			sha = 0;
			break;
		}

		if (sdf <= length(grid.unit)*0.5)
		{
			info.bHit = true;
			//!!!
			info.obj = 0;
			//info.N = GetMeshSDFNormal(ray.pos, grid, sdfArr);
			info.P = ray.pos;
			//break;
			return 0;
		}

		//0.5解决薄处sdf跃过问题
		ray.pos += sdf * ray.dir*0.5f;
		tempDis += clamp(sdf,0.05,0.1);
		traceCount++;
	}

	return sha;
}

float SoftShadow_TraceMeshSDFLocal(Ray ray, out HitInfo info, float softK,
	in Grid grid, in StructuredBuffer<float> sdfArr)
{
	Init(info);

	Ray sampleRay = ray;
	bool needTrace = true;
	float3 boxMin = grid.startPos;
	float3 boxMax = grid.startPos + (grid.unitCount - 1) * grid.unit;
	if (!IsInBBox(ray.pos, boxMin, boxMax))
	{
		CastInfo castInfo = CastBBox(ray, boxMin, boxMax);
		if (castInfo.bHit)
		{
			//!!! offset 0.00..1f is a must!
			sampleRay.pos += sampleRay.dir * (castInfo.dis + 0.001f);
		}
		else
		{
			needTrace = false;
		}
	}
	//盒子内和会打到盒子的ray都需要进行SDFSphereTrace
	if (needTrace)
	{
		return SoftShadow_TraceMeshSDFInBox(sampleRay, info, softK, ray.pos,
			grid, sdfArr);
	}
	else
	{
		return 1;
	}
}
#endif