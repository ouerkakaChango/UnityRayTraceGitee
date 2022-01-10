#ifndef NOISECOMMONDEF_HLSL
#define NOISECOMMONDEF_HLSL
//https ://www.shadertoy.com/view/ldScDh
Texture2D NoiseRGBTex;

//??? problem, need accurate (37.0, 17.0) noise tex
//SamplerState noise_point_repeat_sampler;
//float o_noise(in float3 x)
//{
//	x *= 255;
//	float3 p = floor(x);
//	float3 f = frac(x);
//	f = f * f*(3.0 - 2.0*f);
//	float2 uv = (p.xy + float2(37.0, 17.0)*p.z) + f.xy;
//	//float2 rg = NoiseRGBTex[uv + 0.5].yx;
//	float2 rg = NoiseRGBTex.SampleLevel(noise_point_repeat_sampler, (uv + 0.5)/255, 0).yx;
//	return lerp(rg.x, rg.y, f.z);
//}

float iqhash(float n)
{
	return frac(sin(n)*43758.5453);
}

float noise(float3 x)
{
	// The noise function returns a value in the range -1.0f -> 1.0f
	float3 p = floor(x);
	float3 f = frac(x);

	f = f * f*(3.0 - 2.0*f);
	float n = p.x + p.y*57.0 + 113.0*p.z;
	return lerp(lerp(lerp(iqhash(n + 0.0), iqhash(n + 1.0), f.x),
		lerp(iqhash(n + 57.0), iqhash(n + 58.0), f.x), f.y),
		lerp(lerp(iqhash(n + 113.0), iqhash(n + 114.0), f.x),
			lerp(iqhash(n + 170.0), iqhash(n + 171.0), f.x), f.y), f.z);
}

float fbm4(in float3 p)
{
	float n = 0.0;
	n += 1.000*noise(p*1.0);
	n += 0.500*noise(p*2.0); 
	n += 0.250*noise(p*4.0);
	n += 0.125*noise(p*8.0);
	return n;
}
#endif