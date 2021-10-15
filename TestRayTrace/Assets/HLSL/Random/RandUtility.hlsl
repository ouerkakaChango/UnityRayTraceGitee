float fracNoise(float3 seed ,float3 seedWeight)
{
	return frac(sin(dot(seed, seedWeight)) * 143758.5453);
}

float3 randP(float3 seed) {
	return float3(
		fracNoise(seed, float3(12.989, 78.233, 37.719)),
		fracNoise(seed, float3(39.346, 11.135, 83.155)),
		fracNoise(seed, float3(73.156, 52.235, 09.151))
		);
}

//round表明是单位球的面上，而不是体内
float3 randP_round(float3 seed)
{
	float3 d=0;
	do
	{
		//!!! randP 随机粗糙，不如std::mt1993
		d = 2.0f * randP(seed) - 1;
	} while (dot(d, d) > 1);
	return normalize(d);
}