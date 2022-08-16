#ifndef BVHCOMMONDEF_HLSL
#define BVHCOMMONDEF_HLSL
#include "../CommonDef.hlsl"
#include "../RayMath.hlsl"

struct BVHNode
{
	int start;
	int end;
	float3 min;
	float3 max;
};

#define BVHToCheckMaxNum 32
HitInfo BVHTraceLocalRay(in Ray ray, 
	int treeDepth, in StructuredBuffer<BVHNode> bvh,
	in StructuredBuffer<int> tris,
	in StructuredBuffer<float3> vertices,
	in StructuredBuffer<float3> normals
	)
{
	//---Trace
	HitInfo minHit;
	Init(minHit);
	//trace bvh to determin start inx

	uint numStructs, stride;
	tris.GetDimensions(numStructs, stride);
	int triInxNum = (int)numStructs;

	int start = 0, end = (uint)triInxNum / 3 - 1;

	int toCheck[BVHToCheckMaxNum]; //used as a stack
	int iter = 0; //used as a stack helper

	int nowInx = 0;

	while (true)
	{
		bool bLeafDetect = false;
		bool takeFromCheck = false;
		int nowDepth = GetTreeDepth(nowInx, treeDepth);
		{//!!! Error situation
			if (nowDepth == -1 || nowDepth > treeDepth)
			{
				break;
			}
		}
		BVHNode node = bvh[nowInx];
		CastInfo castInfo = CastBBox(ray, node.min, node.max);

		if (!castInfo.bHit)
		{
			takeFromCheck = true;
		}
		else if (castInfo.bHit && nowDepth != treeDepth)
		{
			int leftInx = 2 * nowInx + 1;
			int rightInx = 2 * nowInx + 2;
			CastInfo leftCast = CastBBox(ray, bvh[leftInx].min, bvh[leftInx].max);
			CastInfo rightCast = CastBBox(ray, bvh[rightInx].min, bvh[rightInx].max);
			if (leftCast.bHit && !rightCast.bHit)
			{
				nowInx = leftInx;
			}
			else if (!leftCast.bHit && rightCast.bHit)
			{
				nowInx = rightInx;
			}
			else if (leftCast.bHit && rightCast.bHit)
			{
				if (leftCast.dis <= rightCast.dis)
				{
					nowInx = leftInx;
					toCheck[iter] = rightInx;
					iter++;
				}
				else
				{
					nowInx = rightInx;
					toCheck[iter] = leftInx;
					iter++;
				}
			}
			else
			{
				takeFromCheck = true;
			}
		}
		else if (castInfo.bHit && nowDepth == treeDepth)
		{
			bLeafDetect = true;
			takeFromCheck = true;
		}

		if (bLeafDetect)
		{
			start = bvh[nowInx].start;
			end = bvh[nowInx].end;
			start = 3 * start;
			end = 3 * end + 3;

			//for loop all triangles in leave to trace
			for (int inx = start; inx < end; inx += 3)
			{
				Vertex v1;
				Vertex v2;
				Vertex v3;

				v1.p = vertices[tris[inx]];
				v2.p = vertices[tris[inx + 1]];
				v3.p = vertices[tris[inx + 2]];

				v1.n = normals[tris[inx]];
				v2.n = normals[tris[inx + 1]];
				v3.n = normals[tris[inx + 2]];


				HitInfo hit = RayCastTri(ray, v1, v2, v3);
				if (hit.bHit)
				{
					if (!minHit.bHit)
					{
						Assgin(minHit, hit);
					}
					else if (length(hit.P - ray.pos) < length(minHit.P - ray.pos))
					{
						Assgin(minHit, hit);
					}
				}
			}
			//___循环三角形
			if (minHit.bHit)
			{
				break;
			}
		}//___if bLeafDetect
		if (takeFromCheck)
		{
			if (iter == 0)
			{
				break;
			}
			else
			{
				nowInx = toCheck[iter - 1];
				iter--;
			}
		}
	}
	return minHit;
}


VertHitInfo BVHVertTraceLocalRay(in Ray ray,
	int treeDepth, in StructuredBuffer<BVHNode> bvh,
	in StructuredBuffer<int> tris,
	in StructuredBuffer<float3> vertices,
	in StructuredBuffer<float3> normals,
	in StructuredBuffer<float2> uvs
)
{
	//---Trace
	VertHitInfo minHit;
	Init(minHit);
	//trace bvh to determin start inx

	uint numStructs, stride;
	tris.GetDimensions(numStructs, stride);

	int start = 0, end = numStructs / 3 - 1;

	int toCheck[BVHToCheckMaxNum]; //used as a stack
	int iter = 0; //used as a stack helper

	int nowInx = 0;

	while (true)
	{
		bool bLeafDetect = false;
		bool takeFromCheck = false;
		int nowDepth = GetTreeDepth(nowInx, treeDepth);
		{//!!! Error situation
			if (nowDepth == -1 || nowDepth > treeDepth)
			{
				break;
			}
		}
		BVHNode node = bvh[nowInx];
		CastInfo castInfo = CastBBox(ray, node.min, node.max);

		if (!castInfo.bHit)
		{
			takeFromCheck = true;
		}
		else if (castInfo.bHit && nowDepth != treeDepth)
		{
			int leftInx = 2 * nowInx + 1;
			int rightInx = 2 * nowInx + 2;
			CastInfo leftCast = CastBBox(ray, bvh[leftInx].min, bvh[leftInx].max);
			CastInfo rightCast = CastBBox(ray, bvh[rightInx].min, bvh[rightInx].max);
			if (leftCast.bHit && !rightCast.bHit)
			{
				nowInx = leftInx;
			}
			else if (!leftCast.bHit && rightCast.bHit)
			{
				nowInx = rightInx;
			}
			else if (leftCast.bHit && rightCast.bHit)
			{
				if (leftCast.dis <= rightCast.dis)
				{
					nowInx = leftInx;
					toCheck[iter] = rightInx;
					iter++;
				}
				else
				{
					nowInx = rightInx;
					toCheck[iter] = leftInx;
					iter++;
				}
			}
			else
			{
				takeFromCheck = true;
			}
		}
		else if (castInfo.bHit && nowDepth == treeDepth)
		{
			bLeafDetect = true;
			takeFromCheck = true;
		}

		if (bLeafDetect)
		{
			start = bvh[nowInx].start;
			end = bvh[nowInx].end;
			start = 3 * start;
			end = 3 * end + 3;

			//for loop all triangles in leave to trace
			for (int inx = start; inx < end; inx += 3)
			{
				Vertex v1;
				Vertex v2;
				Vertex v3;

				v1.p = vertices[tris[inx]];
				v2.p = vertices[tris[inx + 1]];
				v3.p = vertices[tris[inx + 2]];

				v1.n = normals[tris[inx]];
				v2.n = normals[tris[inx + 1]];
				v3.n = normals[tris[inx + 2]];

				v1.uv = uvs[tris[inx]];
				v2.uv = uvs[tris[inx + 1]];
				v3.uv = uvs[tris[inx + 2]];


				VertHitInfo hit = RayCastVertTri(ray, v1, v2, v3);
				if (hit.bHit)
				{
					if (!minHit.bHit)
					{
						minHit = hit;
					}
					else if (length(hit.p - ray.pos) < length(minHit.p - ray.pos))
					{
						minHit = hit;
					}
				}
			}
			//___循环三角形
			if (minHit.bHit)
			{
				break;
			}
		}//___if bLeafDetect
		if (takeFromCheck)
		{
			if (iter == 0)
			{
				break;
			}
			else
			{
				nowInx = toCheck[iter - 1];
				iter--;
			}
		}
	}
	return minHit;
}

#endif