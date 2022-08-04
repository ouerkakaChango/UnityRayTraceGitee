#ifndef TRANSFERMATH_HLSL
#define TRANSFERMATH_HLSL
//x: theta [0,2PI)
//y: phi [0,PI]
//z: r
float3 CartesianToSpherical(float3 xyz)
{
	float r = length(xyz);
	xyz *= 1.f / r;
	float phi = acos(xyz.z);

	if (NearZero(xyz.x) && NearZero(xyz.y))
	{
		return float3(0, phi, r);
	}

	float theta = atan2(xyz.y, xyz.x); //atan2 [-PI,PI]
	theta += (theta < 0) ? 2 * PI : 0;

	return float3(theta, phi, r);
}

float3 SphericalToCartesian(float phi, float theta, float r=1)
{
	return float3(
			r*sin(theta)*cos(phi),
			r*sin(theta)*sin(phi),
			r*cos(theta)
		);
}

float3 XYZ_StandardFromUnity(float3 p)
{
	p.z = -p.z;
	p.yz = p.zy;
	return p;
}

float3 XYZ_UnityFromStandard(float3 p)
{
	p.yz = p.zy;
	p.z = -p.z;
	return p;
}

//uv.v:down to up
float2 EquirectangularToUV(float3 dir, bool unityDir = false)
{
	float2 uv = 0;
	dir = normalize(dir);
	if (unityDir)
	{
		dir = XYZ_StandardFromUnity(dir);
	}
	//!!!
	//由于转球系是需要有x,y,z规定的，
	//所以要先转成标准方向
	// get theta phi from x, y comp (phi [0,2PI) theta [0,PI] )
	float3 sphereCoord = CartesianToSpherical(dir);
	uv.x = sphereCoord.x;
	uv.x /= 2 * PI;

	uv.y = sphereCoord.y;
	uv.y /= PI;

	uv = saturate(uv);
	uv.y = 1 - uv.y;
	return uv;
}

//uv.v:down to up
float3 UVToEquirectangular(float2 uv, bool unityDir = false)
{
	uv.y = 1 - uv.y;
	uv.x *= 2 * PI;
	uv.y *= PI;
	float3 dir = SphericalToCartesian(uv.x, uv.y);
	if (unityDir)
	{
		dir = XYZ_UnityFromStandard(dir);
	}
	return dir;
}

// v must be in z-up coord
float3 Vec2NormalHemisphere(float3 v, float3 N)
{
	float3 helper = float3(1, 0, 0);
	if (abs(N.x) > 0.999) helper = float3(0, 1, 0);
	float3 tangent = normalize(cross(helper, N));
	float3 bitangent = normalize((cross(N, tangent)));
	return v.x*tangent + v.y*bitangent + v.z * N;
}

float3 NormalMapToWorld(float3 v, float3 T,float3 B, float3 N)
{
	v = normalize(v);
	return T * v.x + B * v.y + N * v.z;
}
#endif