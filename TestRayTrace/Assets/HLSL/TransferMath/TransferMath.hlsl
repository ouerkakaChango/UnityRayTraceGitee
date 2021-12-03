#ifndef TRANSFERMATH_HLSL
#define TRANSFERMATH_HLSL
//x: phi [0,2PI)
//y: theta [0,PI]
//z: r
float3 CartesianToSpherical(in float3 xyz)
{
	float r = length(xyz);
	xyz *= 1.f / r;
	float theta = acos(xyz.z);

	float phi = atan2(xyz.y, xyz.x); //atan2 [-PI,PI]
	phi += PI;

	return float3(phi, theta, r);
}

float3 XYZ_StandardFromUnity(float3 p)
{
	p.z = -p.z;
	p.xyz = p.xzy;
	return p;
}

float2 EquirectangularToUV(float3 dir)
{
	float2 uv = 0;
	dir = normalize(dir);
	dir = XYZ_StandardFromUnity(dir);
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
#endif