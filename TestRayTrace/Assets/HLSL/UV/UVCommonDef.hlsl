#ifndef UVCOMMONDEF_HLSL
#define UVCOMMONDEF_HLSL

bool InBound(float2 p, float2 bound, float tolerence = 0.00001f)
{
	if (bound.x < 0 || bound.y < 0)
	{
		return false; 
	}
	return abs(p) < (bound - tolerence);
}

float2 BoxedUV(float2 p, float2 bound)
{
	if (bound.x < 0 || bound.y < 0)
	{
		return 0;
	}
	return (p + bound) / bound * 0.5;
}

float2 BoxedUV(float3 p, float3 center, float3 bound, float3 rotEuler)
{
	p = p - center;
	p = RotByEuler(p, rotEuler);
	float3 q = abs(p);
	if (InBound(p.xy, bound.xy)&&abs(p.z)>=bound.z)
	{
		return BoxedUV(p.xy, bound.xy);
	}
	else if (InBound(p.xz, bound.xz) && abs(p.y) >= bound.y)
	{
		return BoxedUV(p.xz, bound.xz);
	}
	else if (InBound(p.yz, bound.yz) && abs(p.x) >= bound.x)
	{
		return BoxedUV(p.yz, bound.yz);
	}
	//never reach!
	return 0;
}
#endif