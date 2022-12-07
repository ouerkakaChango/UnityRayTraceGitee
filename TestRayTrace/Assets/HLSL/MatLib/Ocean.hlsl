#ifndef OCEAN_HLSL
#define OCEAN_HLSL
#include "../PBR/PBRCommonDef.hlsl"
//#include "../PBR/PBR_IBL.hlsl"
//#include "../PBR/PBR_GGX.hlsl"
#include "../UV/UVCommonDef.hlsl"
#include "../Noise/NoiseCommonDef.hlsl"
//---Ocean-----------------------------------------------------------------------------------------
//https://www.shadertoy.com/view/wt3XDj
float2 Ocean_hash21(float p)
{
	float3 p3 = frac(p * float3(.1031, .1030, .0973));
	p3 += dot(p3, p3.yzx + 33.33);
	return frac((p3.xx + p3.yz)*p3.zy);
}

float2 Ocean_SmoothNoise22(float2 o)
{
	float2 p = floor(o);
	float2 f = frac(o);

	float n = p.x + p.y*57.0;

	float2 a = Ocean_hash21(n + 0.0);
	float2 b = Ocean_hash21(n + 1.0);
	float2 c = Ocean_hash21(n + 57.0);
	float2 d = Ocean_hash21(n + 58.0);

	float2 f2 = f * f;
	float2 f3 = f2 * f;

	float2 t = 3.0 * f2 - 2.0 * f3;

	float u = t.x;
	float v = t.y;

	float2 res = a + (b - a)*u + (c - a)*v + (a - b + d - c)*u*v;

	return res;
}

float Water_WaveShape(float2 uv, float chop)
{
	//uv += Ocean_SmoothNoise22(uv * 0.6) * 2.0;
	//!!! optimize from xc
	uv += perlinNoise1.SampleLevel(noise_linear_repeat_sampler, uv*0.1, 0).yx * 2.0;
	

	float2 w = sin(uv * 2.0) * 0.5 + 0.5;

	w = 1.0 - pow(1.0 - w, chop);

	float h = (w.x + w.y) * 0.5;

	return h;//pow( h, 0.1 );
}

float Water_GetWaves(float2 mapPos, int waterOctaves, float time)
{
	float a = 1.0f;

	float h = 0.0f;

	float tot = 0.0;

	float r = 2.5f;
	float2x2 rm = float2x2(cos(r), -sin(r), sin(r), cos(r)) * 2.1f;

	float2 aPos = mapPos;

	float waveTime = time;

	float chopA = 0.7;
	float chopB = 0.9;

	for (int octave = 0; octave < waterOctaves; octave++)
	{
		float chop = lerp(chopA, chopB, float(octave) / float(waterOctaves - 1));

		h += Water_WaveShape(aPos + waveTime, chop) * a;
		tot += a;

		aPos = mul(rm, aPos);

		a *= 0.3;

		waveTime *= 1.6;

	}

	return h / tot;
}

float Water_GetHeight(float2 origMapPos, int waterOctaves, float time)
{

	float2 mapPos = origMapPos / 4.0;

	float h = Water_GetWaves(mapPos, waterOctaves, time);

	//???
	float terrainHeight = 0;//Terrain_GetHeight( iChannelRockTexture, origMapPos, false, true );
	float waveScale = smoothstep(0.0, -2.0, terrainHeight) * 0.8 + 0.2;



	float result = h * waveScale;

	//???
	float shorelineWaves = 0;//GetShorelineWaves(origMapPos, -terrainHeight).x * waveScale * 1.5;

	float water_terrain_dh = result - terrainHeight;

	float edge = (water_terrain_dh + shorelineWaves * 0.5 + 0.02)*5.;
	edge = clamp(1.0 - edge, 0.0, 1.0);
	edge = sqrt(1.0 - edge * edge);

	result += edge * 0.1;

	result += shorelineWaves;

	return result;
}
//___Ocean________________________________________________________________________________________________________
#endif