#define OBJNUM 2

#define MaxSDF 100000
#define MaxTraceDis 1000
#define MaxTraceTime 640
#define TraceThre 0.001
#define NormalEpsilon 0.0001

#define SceneSDFSoftShadowBias 0.1
#define SceneSDFShadowNormalBias 0.001
#define SceneSDFSoftShadowK 16

#include "../../HLSL/PBR/PBRCommonDef.hlsl"
#include "../../HLSL/PBR/PBR_IBL.hlsl"
#include "../../HLSL/PBR/PBR_GGX.hlsl"

Material_PBR GetObjMaterial_PBR(int obj)
{
	Material_PBR re;
	re.albedo = float3(1, 1, 1);
	re.metallic = 0.0f;
	re.roughness = 0.8f;

	if (obj == 0)
	{		
re.albedo = float3(0, 1 ,0);
		re.metallic = 0.1f;
		re.roughness = 0.8f;
	}
	else if (obj == 1)
	{		
re.albedo = 0.5f;
		re.metallic = 0.1f;
		re.roughness = 0.8f;
	}
	return re;
}

float3 RenderSceneObj(Texture2DArray envSpecTex2DArr, Ray ray, HitInfo minHit)
{
	Material_PBR mat = GetObjMaterial_PBR(minHit.obj);

//if(minHit.obj==0)
//{
//	return PBR_IBL(envSpecTex2DArr, mat, minHit.N, -ray.dir);
//}
//else if (minHit.obj == 1)
{
	float3 lightDir = normalize(float3(1, -1, 1));
	float3 lightColor = float3(1, 1, 1) * 3.5;
	return PBR_GGX(mat, minHit.N, -ray.dir, -lightDir, lightColor) + 0.3 * mat.albedo;
}
	return 0;
}

float HardShadow_TraceScene(Ray ray, out HitInfo info);
float SoftShadow_TraceScene(Ray ray, out HitInfo info);
float RenderSceneSDFShadow(Ray ray, HitInfo minHit)
{
//float3 lightDir = normalize(float3(1, -1, 1));
//ray.pos = minHit.P;
//ray.dir = -lightDir;
//ray.pos += SceneSDFShadowNormalBias * minHit.N;
//HitInfo hitInfo;
//return HardShadow_TraceScene(ray, hitInfo);
return 1;
}

//###################################################################################
#include "../../HLSL/SDFGame/SDFCommonDef.hlsl"
#include "../../HLSL/Noise/NoiseCommonDef.hlsl"

//tutorial: iq modeling https://www.youtube.com/watch?v=-pdSjBPH3zM

//float SDFFoTou(float3 p)
//{
//	float re = 0;
//	float r = 10.45 + 0.05*sin(16 * p.y)*sin(16 * p.x + 10 * _Time.y)*sin(16 * p.z);
//	float3 center = float3(0, 0.5, 0);
//	re = length(p - center) - r;
//	re *= 0.5f;
//	return re;
//}
float SDFPlanet(float3 p)
{
	float re = 0;
	float r = 0.48;// +0.05*sin(16 * p.y)*sin(16 * p.x + 10 * _Time.y)*sin(16 * p.z);
	float dis = fbm4(p.zxy*10);
	r += 0.02*smoothstep(0.5f, 1.0f, dis);
	float3 center = float3(0, r, 0);
	
	re = length(p - center) - r;
	re *= 0.5f;
	return re;
}

float dd(float2 x)
{
	return dot(x,x);
}

float addv(float2 a) { return a.x + a.y; }

float2 solveCubic2(float3 a)
{
	float p = a.y-a.x*a.x/3.;
	float p3 = p*p*p;
	float q = a.x*(2.*a.x*a.x-9.*a.y)/27.+a.z;
	float d = q*q+4.*p3/27.;
	if(d>.0)
	{
		float2 x = (float2(1,-1)*sqrt(d)-q)*.5;
		float tt = addv(sign(x)*pow(abs(x),float2(1/3.0,1/3.0)))-a.x/3.0;
		return float2(tt,tt);
	}
	float v = acos(-sqrt(-27./p3)*q*.5)/3.;
	float m = cos(v);
	float n = sin(v)*1.732050808;
	return float2(m+m,-n-m)*sqrt(-p/3.)-a.x/3.;
}

//https://www.shadertoy.com/view/XdB3Ww
float calculateDistanceToQuadraticBezier(float2 p, float2 a, float2 b, float2 c)
{
	b += lerp(float2(1e-4,1e-4),float2(0,0),abs(sign(b*2.0-a-c)));
	float2 A = b-a;
	float2 B = c-b-A;
	float2 C = p-a;
	float2 D = A*2.;
	float2 T = clamp(solveCubic2(float3(-3.*dot(A,B),dot(C,B)-2.*dd(A),dot(C,A))/-dd(B)),0.,1.);
	return sqrt(min(dd(C-(D+B*T.x)*T.x),dd(C-(D+B*T.y)*T.y)));
}

//if p is 'outside' , 1result; 'inside' ,2result ,choose the one nearer
float projectToQuadraticBezier(float2 p, float2 a, float2 b, float2 c)
{
	b += lerp(float2(1e-4,1e-4),float2(0,0),abs(sign(b*2.0-a-c)));
	float2 A = b-a;
	float2 B = c-b-A;
	float2 C = p-a;
	float2 D = A*2.;
	float2 T = (solveCubic2(float3(-3.*dot(A,B),dot(C,B)-2.*dd(A),dot(C,A))/-dd(B)));

	float d1_square = dd(C-(D+B*T.x)*T.x);
	float d2_square = dd(C-(D+B*T.y)*T.y);

	return d1_square < d2_square ? T.x : T.y;
}

float disFromQuadraticBezierT(float2 p, float t, float2 a, float2 b, float2 c)
{
	b += lerp(float2(1e-4,1e-4),float2(0,0),abs(sign(b*2.0-a-c)));
	float2 A = b-a;
	float2 B = c-b-A;
	float2 C = p-a;
	float2 D = A*2.;
	return sqrt(dd(C-(D+B*t.x)*t.x));
}

bool Is01(float x)
{
	return x>0 && x<1;
}

float sdfClip2D(float3 p, float d, float h)
{
	float2 w = float2( d, abs(p.y) - h );
d = min(max(w.x,w.y),0.0) + length(max(w,0.0));
	return d;
}


float GetObjSDF(int inx, float3 p)
{
if (inx == 0)
{
	return SDFSphere(p, float3(5, 0.5, 0), 0.5); //球
	//return SDFPlanet(p);
}
else if (inx == 1)
{//地面
	//box center(0, -1.2, -5), bound(5, 0.1, 5)
	//return SDFBox(p, float3(0, -0.5, 0), float3(5, 0.5, 5));
	//return SDFBoxTransform(p, float3(5, 0.5, 5),
	//	float3(0, -0.5, 0),float3(0,0,30*Time01()));

	//return SDFShearXBoxTransform(p, float3(5, 0.5, 5),
	//	0,-0.5,
	//	float3(0, -0.5, 0));

	//return SDFShearXSphere(p, float3(0, 0, 0), 0.5,
	//					0,1*Time01());

	//### A
	//float a1 = SDFShearXBoxTransform(p, float3(5, 0.5, 0.5),
	//	0, 0.3,
	//	float3(0, -0.5, -1.5));
	//
	//float a2 = SDFShearXBoxTransform(p, float3(5, 0.5, 0.5),
	//	0, -0.3,
	//	float3(0, -0.5, 1.5));
	//
	//float a3 = SDFBox(p, float3(-1.5, -0.5, 0), float3(0.4, 0.5, 2));
	//
	//float re = min(a1,a2);
	//re = min(re,a3);

	//### (besizer segment)3 point Besizer
	//float re = -0.1 + calculateDistanceToQuadraticBezier(p.xz, float2(1.65,-0.57), float2(1,1.3),float2(0.18,-0.61));
	//float h=0.1;
	//float2 w = float2( re, abs(p.y) - h );
//re = min(max(w.x,w.y),0.0) + length(max(w,0.0));

	//### 2 besizer segment
	//float h=0.1;
	//
	//float c1 = -0.1 + calculateDistanceToQuadraticBezier(p.xz, float2(0.18,-0.61), float2(0,0),float2(0.5,1.2));
	//float2 w = float2( c1, abs(p.y) - h );
//c1 = min(max(w.x,w.y),0.0) + length(max(w,0.0));
	//
	//float c2 = -0.1 + calculateDistanceToQuadraticBezier(p.xz, float2(0,0), float2(0.5,1.2),float2(1,1.3));
	//w = float2( c2, abs(p.y) - h );
//c2 = min(max(w.x,w.y),0.0) + length(max(w,0.0));
	//
	//float re = min(c1,c2);

	/*
	//### lerped 2 besizer segment
	float re = 10000000;
	float h = 0.1;
	
	float t1 = projectToQuadraticBezier(p.xz, float2(0.18,-0.61), float2(0,0),float2(0.5,1.2));
	float t2 = projectToQuadraticBezier(p.xz, float2(0,0), float2(0.5,1.2),float2(1,1.3));
	if(Is01(t1) && t2<0)
	{//head
		re = -0.1 + disFromQuadraticBezierT(p.xz, t1, float2(0.18,-0.61), float2(0,0),float2(0.5,1.2));
		re = sdfClip2D(p, re, h);
	}
	else if(Is01(t2) && t1<0)
	{//tail
		re = -0.1 + disFromQuadraticBezierT(p.xz, t2, float2(0,0), float2(0.5,1.2),float2(1,1.3));
		re = sdfClip2D(p, re, h);
	}
	else if (Is01(t1) && Is01(t2))
	{//body
		//like CheapSpline,now t1>0.5,t2<0.5
		float lerpK = saturate((t1-0.5)/0.5);
		float d1 = -0.1 + disFromQuadraticBezierT(p.xz, t1, float2(0.18,-0.61), float2(0,0),float2(0.5,1.2));
		float d2 = -0.1 + disFromQuadraticBezierT(p.xz, t2, float2(0,0), float2(0.5,1.2),float2(1,1.3));
		re = lerp(d1,d2,lerpK);
		re = sdfClip2D(p, re, h);
	}
	else
	{
		return 100000000;
	}
	*/

	//### 2 quadBesizerSpline segment , box side,round end
	//float h=0.1;
	//
	//float c1 = -0.1 + calculateDistanceToQuadraticBezier(p.xz, float2(0,0), float2(1.06,0.72),float2(1.67,0));
	//float2 w = float2( c1, abs(p.y) - h );
//c1 = min(max(w.x,w.y),0.0) + length(max(w,0.0));
	//
	//float c2 = -0.1 + calculateDistanceToQuadraticBezier(p.xz, float2(1.67,0), float2(2.717196,-1.236034),float2(2.89,-3));
	//w = float2( c2, abs(p.y) - h );
//c2 = min(max(w.x,w.y),0.0) + length(max(w,0.0));
	//
	//float re = min(c1,c2);

	//### 2 quadBesizerSpline segment, box side
	float re = 100000;
	float2 box = float2(0.1, 0.05);
	
	float c1 = calculateDistanceToQuadraticBezier(p.xz, float2(0,0), float2(1.06,0.72),float2(1.67,0));	
	float c2 = calculateDistanceToQuadraticBezier(p.xz, float2(1.67,0), float2(2.717196,-1.236034),float2(2.89,-3));
	
	float t1 = projectToQuadraticBezier(p.xz, float2(0,0), float2(1.06,0.72),float2(1.67,0));
	float t2 = projectToQuadraticBezier(p.xz, float2(1.67,0), float2(2.717196,-1.236034),float2(2.89,-3));
	
	if(t1<0 && t2<0)
	{//head
		//float2 t = float2(0,0);
		//re = SDFSphere(p, float3(t.x,0,t.y), 0.2);

		float2 u2d = normalize(float2(0,0) - float2(1.06,0.72));
		float3 u = float3(u2d.x,0,u2d.y);
		float3 v = float3(0,1,0);
		float3 w = cross(u,v);
		//0.01 as a user set cap thickness
		re = SDFBoxByUVW(p,u,v,w,float3(0,0,0),float3(0.01f,box.y,box.x));
	}
	else if (t1>1 && t2>1)
	{//tail
		//float2 t = float2(2.89,-3);
		//re = SDFSphere(p, float3(t.x,0,t.y), 0.2);
		
		float2 u2d = normalize(float2(2.89,-3) - float2(2.717196,-1.236034));
		float3 u = float3(u2d.x,0,u2d.y);
		float3 v = float3(0,1,0);
		float3 w = cross(u,v);
		//0.01 as a user set cap thickness
		re = SDFBoxByUVW(p,u,v,w,float3(2.89,0, -3),float3(0.01f,box.y,box.x));
	}
	else
	{
		float2 w = float2(min(c1,c2),abs(p.y)) - box;
		re = min(max(w.x,w.y),0.0) + length(max(w,0.0));
	}

	//### Box defined by uvw
	//float2 u2d = normalize(float2(0,0) - float2(1.06,0.72));
	//float3 u = float3(u2d.x,0,u2d.y);
	//float3 v = float3(0,1,0);
	//float3 w = cross(u,v);
	//float cap1 = SDFBoxByUVW(p,u,v,w,float3(0,0,0),float3(0.05*Time01(),0.05,0.05));
	//
	//re = min(re,cap1);
	return re;
}
else
{
	return -1;
}
}

float3 GetObjSDFNormal(int inx, float3 p)
{
	return normalize(float3(
		GetObjSDF(inx, float3(p.x + NormalEpsilon, p.y, p.z)) - GetObjSDF(inx, float3(p.x - NormalEpsilon, p.y, p.z)),
		GetObjSDF(inx, float3(p.x, p.y + NormalEpsilon, p.z)) - GetObjSDF(inx, float3(p.x, p.y - NormalEpsilon, p.z)),
		GetObjSDF(inx, float3(p.x, p.y, p.z + NormalEpsilon)) - GetObjSDF(inx, float3(p.x, p.y, p.z - NormalEpsilon))
		));
}

float3 GetObjNormal(int inx, float3 p)
{
if (inx == 0)
{
	//return SDFSphereNormal(p, float3(0, 0.5, 0));
	//return SDFPlanetNormal(p);
	return GetObjSDFNormal(inx, p);
}
else
{
	return GetObjSDFNormal(inx, p);
}
}


float TraceScene(Ray ray, out HitInfo info)
{
	Init(info);

	int traceCount = 0;
	while (traceCount <= MaxTraceTime)
	{
		int objInx = -1;
		float objSDF[OBJNUM];
		float sdf = MaxSDF;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			objSDF[inx] = GetObjSDF(inx, ray.pos);
			if (objSDF[inx] < sdf)
			{
				sdf = objSDF[inx];
				objInx = inx;
			}
		}

		if (sdf > MaxTraceDis)
		{
			break;
		}

		if (sdf <= TraceThre)
		{
			info.bHit = true;
			info.obj = objInx;
			info.N = GetObjNormal(objInx, ray.pos);
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		traceCount++;
	}

	if (info.bHit)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

float HardShadow_TraceScene(Ray ray, out HitInfo info)
{
	Init(info);

	int traceCount = 0;
	while (traceCount <= MaxTraceTime*0.1)
	{
		int objInx = -1;
		float objSDF[OBJNUM];
		float sdf = MaxSDF;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			objSDF[inx] = GetObjSDF(inx, ray.pos);
			if (objSDF[inx] < sdf)
			{
				sdf = objSDF[inx];
				objInx = inx;
			}
		}

		if (sdf > MaxTraceDis)
		{
			break;
		}

		if (sdf <= TraceThre*0.5)
		{
			info.bHit = true;
			info.obj = objInx;
			//info.N = GetObjNormal(objInx, ray.pos);
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		traceCount++;
	}

	if (info.bHit)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

//https://www.shadertoy.com/view/MsfGRr
float SoftShadow_TraceScene(Ray ray, out HitInfo info)
{
	Init(info);
	float sha = 1.0;
	float t = 0.005 * 0.1; //一个非0小值，会避免极其细微的多余shadow

	int traceCount = 0;
	while (traceCount <= MaxTraceTime*0.2)
	{
		int objInx = -1;
		float objSDF[OBJNUM];
		float sdf = MaxSDF;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			objSDF[inx] = GetObjSDF(inx, ray.pos);
			if (objSDF[inx] < sdf)
			{
				sdf = objSDF[inx];
				objInx = inx;
			}
		}

		if (sdf <= 0)
		{
			sha = 0;
			break;
		}

		if (sdf > MaxTraceDis)
		{
			break;
		}

		sha = min(sha, SceneSDFSoftShadowK * sdf / t);
		if (sha < 0.001) break;

		//*0.1f解决背面漏光问题
		if (sdf <= TraceThre*0.1f)
		{
			info.bHit = true;
			info.obj = objInx;
			//info.N = GetObjNormal(objInx, ray.pos);
			info.P = ray.pos;
			break;
		}

		t += clamp(sdf, 0.01*SceneSDFSoftShadowBias, 0.5*SceneSDFSoftShadowBias);

		ray.pos += sdf * ray.dir;
		traceCount++;
	}

	return saturate(sha);
}
