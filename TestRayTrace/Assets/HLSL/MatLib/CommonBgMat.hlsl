#ifndef COMMONBGMAT_HLSL
#define COMMONBGMAT_HLSL
#include "../CommonDef.hlsl"
#include "../TransferMath/TransferMath.hlsl"
//#include "../PBR/PBRCommonDef.hlsl"
//#include "../PBR/PBR_IBL.hlsl"
//#include "../PBR/PBR_GGX.hlsl"
//#include "../UV/UVCommonDef.hlsl"
//#include "../Noise/NoiseCommonDef.hlsl"

//---Star Sky-------------------------------------------------------------------------------
//https://www.shadertoy.com/view/stBcW1

// License: MIT OR CC-BY-NC-4.0, author: mercury, found: https://mercury.sexy/hg_sdf/
float2 mod2(inout float2 p, float2 size) {
	float2 c = floor((p + size * 0.5) / size);
	p = fmod(p + size * 0.5, size) - size * 0.5;
	return c;
}

// License: Unknown, author: Unknown, found: don't remember
float2 hash2(float2 p) {
	p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
	return frac(sin(p)*43758.5453123);
}

// License: CC BY-NC-SA 3.0, author: Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick), found: https://www.shadertoy.com/view/Mt3GW2
float3 blackbody(float Temp) {
	float3 col = float3(255, 255, 255);
	col.x = 56100000. * pow(Temp, (-3. / 2.)) + 148.;
	col.y = 100.04 * log(Temp) - 623.6;
	if (Temp > 6500.) col.y = 35200000. * pow(Temp, (-3. / 2.)) + 184.;
	col.z = 194.18 * log(Temp) - 1448.6;
	col = clamp(col, 0., 255.) / 255.;
	if (Temp < 1000.) col *= Temp / 1000.;
	return col;
}

float3 stars(float3 ro, float3 rd, float layers = 5) {
	float3 col = float3(0, 0, 0);
	float m = layers;
	float2 sp = CartesianToSpherical(rd).yx;

	for (float i = 0.0; i < m; ++i) {
		float2 pp = sp + 0.5*i;
		float s = i / (m - 1.0);
		float2 dim = lerp(0.05, 0.003, s)*PI;
		float2 np = mod2(pp, dim);
		float2 h = hash2(np + 127.0 + i);
		float2 o = -1.0 + 2.0*h;
		float y = sin(sp.x);
		pp += o * dim*0.5;
		pp.y *= y;
		float l = length(pp);

		float h1 = frac(h.x*1667.0);
		float h2 = frac(h.x*1887.0);
		float h3 = frac(h.x*2997.0);

		float3 scol = lerp(8.0*h2, 0.25*h2*h2, s)*blackbody(lerp(3000.0, 22000.0, h1*h1));

		float3 ccol = col + exp(-(6000.0 / lerp(2.0, 0.25, s))*max(l - 0.001, 0.0))*scol;
		col = h3 < y ? ccol : col;
	}

	return col;
}
//___StarSky____________________________________________________________________________________________________

#endif