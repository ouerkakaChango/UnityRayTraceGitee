#include "../Transform/Transform.hlsl"
float fracNoise(float3 seed ,float3 seedWeight)
{
	return frac(sin(dot(seed, seedWeight)) * 143758.5453);
}

float3 fracRandP(float3 seed) {
	return float3(
		fracNoise(seed, float3(12.989, 78.233, 37.719)),
		fracNoise(seed, float3(39.346, 11.135, 83.155)),
		fracNoise(seed, float3(73.156, 52.235, 09.151))
		);
}

//https://www.cnblogs.com/gearslogy/p/11717470.html
//https://github.com/diharaw/GPUPathTracer/blob/master/src/shader/path_tracer_cs.glsl
//################################
uint g_state = 1973;
//###############################

uint rand(inout uint state)
{
	uint x = state;
	x ^= x << 13;
	x ^= x >> 17;
	x ^= x << 15;
	state = x;
	return x;
}

float random_float_01(inout uint state)
{
	return (rand(state) & 0xFFFFFF) / 16777216.0f;
}

float3 random_in_unit_sphere(inout uint state)
{
	float z = random_float_01(state) * 2.0f - 1.0f;
	float t = random_float_01(state) * 2.0f * 3.1415926f;
	float r = sqrt(max(0.0, 1.0f - z * z));
	float x = r * cos(t);
	float y = r * sin(t);
	float3 res = float3(x, y, z);
	res *= pow(random_float_01(state), 1.0 / 3.0);
	return res;
}

float3 randP_round(float3 seed)
{
	int stat = (int)dot(seed, float3(1973, 9277, 2699));
	
	return random_in_unit_sphere(stat);
	//return normalize(2*fracRandP(seed)-1);
}

float3 randP_hemiRound(float3 seed)
{
	int stat = (int)dot(seed, float3(1973, 9277, 2699));

	float3 re =  random_in_unit_sphere(stat);
	re.z = abs(re.z);
	return re;
}

float rand01(float3 seed)
{
	int stat = (int)dot(seed, float3(1973, 9277, 2699));

	return random_float_01(stat);
}