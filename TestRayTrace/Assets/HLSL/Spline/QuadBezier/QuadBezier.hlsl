#ifndef QUADBEZIER_HLSL
#define QUADBEZIER_HLSL
#include "../SplineCommonDef.hlsl"

//https://www.shadertoy.com/view/XdB3Ww
//float calculateDistanceToQuadraticBezier(float2 p, float2 a, float2 b, float2 c)
//{
//	b += lerp(float2(1e-4, 1e-4), float2(0, 0), abs(sign(b * 2.0 - a - c)));
//	float2 A = b - a;
//	float2 B = c - b - A;
//	float2 C = p - a;
//	float2 D = A * 2.;
//	float2 T = clamp(solveCubic2(float3(-3. * dot(A, B), dot(C, B) - 2. * length2(A), dot(C, A)) / -length2(B)), 0., 1.);
//	return sqrt(min(length2(C - (D + B * T.x) * T.x), length2(C - (D + B * T.y) * T.y)));
//}

float2 QuadBezierGet(float t, float2 a, float2 b, float2 c)
{
	return (1 - t) * (1 - t) * a + 2 * (1 - t) * t * b + t * t * c;
}

//!!! whether move to math.hlsl
float2 solveCubic2(float3 a)
{
	float p = a.y - a.x * a.x / 3.;
	float p3 = p * p * p;
	float q = a.x * (2. * a.x * a.x - 9. * a.y) / 27. + a.z;
	float d = q * q + 4. * p3 / 27.;
	if (d > .0)
	{
		float2 x = (float2(1, -1) * sqrt(d) - q) * .5;
		float tt = addv(sign(x) * pow(abs(x), float2(1 / 3.0, 1 / 3.0))) - a.x / 3.0;
		return float2(tt, tt);
	}
	float v = acos(-sqrt(-27. / p3) * q * .5) / 3.;
	float m = cos(v);
	float n = sin(v) * 1.732050808;
	return float2(m + m, -n - m) * sqrt(-p / 3.) - a.x / 3.;
}

SplineProjInfo ProjectQuadBezierBody(float3 p3d, float2 a, float2 b, float2 c, Transform trans)
{
	SplineProjInfo info;
	Init(info); 

	p3d = WorldToLocal(trans, p3d);
	float2 p = p3d.xz;
	//###
	b += lerp(float2(1e-4, 1e-4), float2(0, 0), abs(sign(b * 2.0 - a - c)));
	float2 A = b - a;
	float2 B = c - b - A;
	float2 C = p - a;
	float2 D = A * 2.;
	float2 T = solveCubic2(float3(-3. * dot(A, B), dot(C, B) - 2. * length2(A), dot(C, A)) / -length2(B));

	if (Is01(T.x) && Is01(T.y))
	{
		info.flag = 1;
		float d1_2 = length2(C - (D + B * T.x) * T.x);
		float d2_2 = length2(C - (D + B * T.y) * T.y);
		if (d1_2 < d2_2)
		{
			info.dis = sqrt(d1_2);
			float2 local2d = QuadBezierGet(T.x, a, b, c);
			//info.projPnt = LocalToWorld(trans, float3(local2d.x, 0, local2d.y));
			info.projPnt2D = local2d;
		}
		else
		{
			info.dis = sqrt(d2_2);
			float2 local2d = QuadBezierGet(T.y, a, b, c);
			//info.projPnt = LocalToWorld(trans, float3(local2d.x, 0, local2d.y));
			info.projPnt2D = local2d;
		}
	}
	else if (Is01(T.x))
	{
		info.flag = 1;
		float d1_2 = length2(C - (D + B * T.x) * T.x);
		info.dis = sqrt(d1_2);
		float2 local2d = QuadBezierGet(T.x, a, b, c);
		//info.projPnt = LocalToWorld(trans, float3(local2d.x, 0, local2d.y));
		info.projPnt2D = local2d;
	}
	else if (Is01(T.y))
	{
		info.flag = 1;
		float d2_2 = length2(C - (D + B * T.y) * T.y);
		info.dis = sqrt(d2_2);
		float2 local2d = QuadBezierGet(T.y, a, b, c);
		//info.projPnt = LocalToWorld(trans, float3(local2d.x, 0, local2d.y));
		info.projPnt2D = local2d;
	}

	return info; 
}

SplineProjInfo PreProjQuadBezierCap(float3 p3d, int flag, float2 T, float2 G, in Transform trans)
{
	SplineProjInfo info;
	Init(info);
	info.flag = flag;
	//info.projPnt = To3D(trans, T);
	info.projPnt2D = T;
	//info.extra = DirTo3D(trans, normalize(T - G));
	info.extra2D = normalize(T - G);
	return info;
}

#define FUNC_SDFBoxedQuadBezier(re, p, spline, pntNum, trans, box) \
{\
	int segNum = (pntNum-1)/2;\
	SplineProjInfo bodyInfo;\
	Init(bodyInfo);\
	for (int i = 0; i < segNum; i++)\
	{\
		UpdateInfo(bodyInfo, ProjectQuadBezierBody(p, spline[2 * i], spline[2 * i + 1], spline[2 * i + 2], trans));\
	}\
	SplineProjInfo headInfo = PreProjQuadBezierCap(p, 0, spline[0], spline[1], trans);\
	SplineProjInfo tailInfo = PreProjQuadBezierCap(p, 2, spline[2 * segNum], spline[2 * segNum - 1], trans);\
	re = SDFBoxedSpline(p, trans, box, bodyInfo, headInfo, tailInfo);\
}
#endif