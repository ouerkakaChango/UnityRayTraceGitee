#ifndef RANDUTILITY_H
#define RANDUTILITY_H
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

float3 random_on_unit_sphere(inout uint state)
{
	float z = random_float_01(state) * 2.0f - 1.0f;
	float t = random_float_01(state) * 2.0f * 3.1415926f;
	float r = sqrt(max(0.0, 1.0f - z * z));
	float x = r * cos(t);
	float y = r * sin(t);
	float3 res = float3(x, y, z);
	return res;
}

float3 randP_round(float3 seed)
{
	uint stat = (uint)(seed.x) * 1973 + (uint)(seed.y) * 9277 + (uint)(seed.z) * 2699 | 1;

	return random_on_unit_sphere(stat);
}

float3 randP_hemiRound(float3 seed)
{
	uint stat = (uint)(seed.x) * 1973 + (uint)(seed.y) * 9277 + (uint)(seed.z) * 2699 | 1;

	float3 re =  random_on_unit_sphere(stat);
	re.z = abs(re.z);
	return re;
}

float rand01(float3 seed)
{
	uint stat = (uint)(seed.x) * 1973 + (uint)(seed.y) * 9277 + (uint)(seed.z) * 2699 | 1;

	return random_float_01(stat);
}

//???
//https://www.baeldung.com/cs/uniform-to-normal-distribution
//https://blog.csdn.net/weixin_30734435/article/details/99602086
float normalDistribution(float ave, float sqrtPhi,float3 seed1,float3 seed2)
{
	float random_1 = rand01(seed1);
	float random_2 = rand01(seed2);
	if (sqrtPhi <= 0)
	{
		return 0;
	}
	return sqrtPhi * sqrt(-2 * log(random_1)) * cos(2 * PI * random_2) + ave;
}

//#########################################################################
// 1 ~ 8 维的 sobol 生成矩阵
const uint V[8 * 32] = {
	2147483648, 1073741824, 536870912, 268435456, 134217728, 67108864, 33554432, 16777216, 8388608, 4194304, 2097152, 1048576, 524288, 262144, 131072, 65536, 32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1,
	2147483648, 3221225472, 2684354560, 4026531840, 2281701376, 3422552064, 2852126720, 4278190080, 2155872256, 3233808384, 2694840320, 4042260480, 2290614272, 3435921408, 2863267840, 4294901760, 2147516416, 3221274624, 2684395520, 4026593280, 2281736192, 3422604288, 2852170240, 4278255360, 2155905152, 3233857728, 2694881440, 4042322160, 2290649224, 3435973836, 2863311530, 4294967295,
	2147483648, 3221225472, 1610612736, 2415919104, 3892314112, 1543503872, 2382364672, 3305111552, 1753219072, 2629828608, 3999268864, 1435500544, 2154299392, 3231449088, 1626210304, 2421489664, 3900735488, 1556135936, 2388680704, 3314585600, 1751705600, 2627492864, 4008611328, 1431684352, 2147543168, 3221249216, 1610649184, 2415969680, 3892340840, 1543543964, 2382425838, 3305133397,
	2147483648, 3221225472, 536870912, 1342177280, 4160749568, 1946157056, 2717908992, 2466250752, 3632267264, 624951296, 1507852288, 3872391168, 2013790208, 3020685312, 2181169152, 3271884800, 546275328, 1363623936, 4226424832, 1977167872, 2693105664, 2437829632, 3689389568, 635137280, 1484783744, 3846176960, 2044723232, 3067084880, 2148008184, 3222012020, 537002146, 1342505107,
	2147483648, 1073741824, 536870912, 2952790016, 4160749568, 3690987520, 2046820352, 2634022912, 1518338048, 801112064, 2707423232, 4038066176, 3666345984, 1875116032, 2170683392, 1085997056, 579305472, 3016343552, 4217741312, 3719483392, 2013407232, 2617981952, 1510979072, 755882752, 2726789248, 4090085440, 3680870432, 1840435376, 2147625208, 1074478300, 537900666, 2953698205,
	2147483648, 1073741824, 1610612736, 805306368, 2818572288, 335544320, 2113929216, 3472883712, 2290089984, 3829399552, 3059744768, 1127219200, 3089629184, 4199809024, 3567124480, 1891565568, 394297344, 3988799488, 920674304, 4193267712, 2950604800, 3977188352, 3250028032, 129093376, 2231568512, 2963678272, 4281226848, 432124720, 803643432, 1633613396, 2672665246, 3170194367,
	2147483648, 3221225472, 2684354560, 3489660928, 1476395008, 2483027968, 1040187392, 3808428032, 3196059648, 599785472, 505413632, 4077912064, 1182269440, 1736704000, 2017853440, 2221342720, 3329785856, 2810494976, 3628507136, 1416089600, 2658719744, 864310272, 3863387648, 3076993792, 553150080, 272922560, 4167467040, 1148698640, 1719673080, 2009075780, 2149644390, 3222291575,
	2147483648, 1073741824, 2684354560, 1342177280, 2281701376, 1946157056, 436207616, 2566914048, 2625634304, 3208642560, 2720006144, 2098200576, 111673344, 2354315264, 3464626176, 4027383808, 2886631424, 3770826752, 1691164672, 3357462528, 1993345024, 3752330240, 873073152, 2870150400, 1700563072, 87021376, 1097028000, 1222351248, 1560027592, 2977959924, 23268898, 437609937
};

// 格林码 
uint grayCode(uint i) {
	return i ^ (i >> 1);
}

// 生成第 d 维度的第 i 个 sobol 数
float sobol(uint d, uint i) {
	uint result = 0;
	uint offset = d * 32;
	for (uint j = 0; i; i >>= 1, j++)
		if (i & 1)
			result ^= V[j + offset];

	return float(result) * (1.0f / float(0xFFFFFFFFU));
}

// 生成第 i 帧的第 b 次反弹需要的二维随机向量
float2 randfloat2_unrot(uint i, uint b) {
	float u = sobol(b * 2, grayCode(i));
	float v = sobol(b * 2 + 1, grayCode(i));
	return float2(u, v);
}

uint wang_hash(inout uint seed) {
	seed = uint(seed ^ uint(61)) ^ uint(seed >> uint(16));
	seed *= uint(9);
	seed = seed ^ (seed >> 4);
	seed *= uint(0x27d4eb2d);
	seed = seed ^ (seed >> 15);
	return seed;
}

float2 CranleyPattersonRotation(int width ,int height, int pixX, int pixY, float2 p) {
	uint pseed = uint(
		uint((pixX * 0.5 + 0.5) * width)  * uint(1973) +
		uint((pixY * 0.5 + 0.5) * height) * uint(9277) +
		uint(114514 / 1919) * uint(26699)) | uint(1);

	float u = float(wang_hash(pseed)) / 4294967296.0;
	float v = float(wang_hash(pseed)) / 4294967296.0;

	p.x += u;
	if (p.x > 1) p.x -= 1;
	if (p.x < 0) p.x += 1;

	p.y += v;
	if (p.y > 1) p.y -= 1;
	if (p.y < 0) p.y += 1;

	return p;
}

// 生成第 i 帧的第 b 次反弹需要的二维随机向量
//w,h,i,j,?,?
float2 randfloat2(int width, int height, int pixX, int pixY, uint i, uint b) {
	return CranleyPattersonRotation(width, height, pixX, pixY, randfloat2_unrot(i,b));
}

//#########################################################################
//https://learnopengl-cn.github.io/07%20PBR/03%20IBL/02%20Specular%20IBL/

float RadicalInverse_VdC(uint bits)
{
	bits = (bits << 16u) | (bits >> 16u);
	bits = ((bits & 0x55555555u) << 1u) | ((bits & 0xAAAAAAAAu) >> 1u);
	bits = ((bits & 0x33333333u) << 2u) | ((bits & 0xCCCCCCCCu) >> 2u);
	bits = ((bits & 0x0F0F0F0Fu) << 4u) | ((bits & 0xF0F0F0F0u) >> 4u);
	bits = ((bits & 0x00FF00FFu) << 8u) | ((bits & 0xFF00FF00u) >> 8u);
	return float(bits) * 2.3283064365386963e-10; // / 0x100000000
}

float2 Hammersley(uint i, uint N)
{
	return float2(float(i) / float(N), RadicalInverse_VdC(i));
}

//##########################################################################
//https://zhuanlan.zhihu.com/p/47959352
//https://www.shadertoy.com/view/NscfD8
float RandFast_Old(float2 PixelPos, float Magic = 3571.0)
{
	PixelPos = (0.4f + normalize(PixelPos))*512.0f;
	float2 Random2 = (1.0 / 4320.0) * PixelPos + float2(0.25, 0.0);
	float Random = frac(dot(Random2 * Random2, Magic));
	Random = frac(Random * Random * (2 * Magic));
	return Random;
}

//https://www.shadertoy.com/view/XlXcW4
float3 hash_uint3(uint3 x)
{
	const uint k = 1103515245U;
	x = ((x >> 8U) ^ x.yzx)*k;
	x = ((x >> 8U) ^ x.yzx)*k;
	x = ((x >> 8U) ^ x.yzx)*k;

	return float3(x)*(1.0 / float(0xffffffffU));
}

float RandFast(float2 PixelPos, uint scale=512)
{
	uint2 upos = (uint2)(abs(PixelPos) * scale);
	return hash_uint3(uint3(upos,0)).x;
}
#endif