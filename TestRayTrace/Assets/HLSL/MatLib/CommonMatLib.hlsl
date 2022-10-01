#ifndef COMMONMATLIB_HLSL
#define COMMONMATLIB_HLSL
#include "../PBR/PBRCommonDef.hlsl"
//#include "../PBR/PBR_IBL.hlsl"
//#include "../PBR/PBR_GGX.hlsl"
#include "../UV/UVCommonDef.hlsl"
#include "../Noise/NoiseCommonDef.hlsl"

void SetMatLib_BrushedMetal(inout Material_PBR mat, float2 uv, float brushPower = 0.15)
{
	//change from https://www.shadertoy.com/view/tldfD8
	float g = 0.1, l=0.;
	g += -0.5+SampleR(greyNoiseMedium, uv*float2(.06,4.18));
	l += brushPower;
	l = exp(4.*l-1.5);
	g = exp(1.2*g-1.5);
	float v = .1*g+.2*l+2.*g*l;
	mat.metallic = saturate(v*2);
	mat.roughness = saturate((1-v)*0.5);
}

//#############################################################################

float tri(in float x)
{
	return abs(frac(x) - .5);
}

float2 tri2(in float2 p)
{
	return float2(tri(p.x + tri(p.y*2.)), tri(p.y + tri(p.x*2.)));
}

float triangleNoise(in float2 p)
{
	float z = 1.5;
	float z2 = 1.5;
	float rz = 0.;
	float2 bp = 2.*p;
	float2x2 trinoisemat = { 0.970,  0.242, -0.242,  0.970 };
	for (float i = 0.; i <= 4.; i++)
	{
		float2 dg = tri2(bp*2.)*.8;
		dg = rotate(dg, 0.314);
		p += dg / z2;

		bp *= 1.6;
		z2 *= .6;
		z *= 1.8;
		p *= 1.2;
		p = mul(trinoisemat, p);

		rz += (tri(p.x + tri(p.y))) / z;
	}
	return rz;
}

float arc(in float2 plr, in float radius, in float thickness, in float la, in float ha)
{
	// clamp arc start/end
	float res = step(la, plr.y) * step(plr.y, ha);
	// smooth outside
	res *= smoothstep(plr.x, plr.x, radius + thickness);
	// smooth inside
	float f = radius - thickness;
	res *= smoothstep(f, f, plr.x);
	// smooth start
	res *= smoothstep(la, la, plr.y);
	// smooth end
	res *= 1. - smoothstep(ha, ha, plr.y);
	return res;
}

float3 marquetry(float2 uv, Texture2D<float3> WoodTexture, float seed1 = 7.0, float seed2 = -4.0)
{
	float2 p = uv;
	p.x = abs(p.x);
	p.y = abs(p.y);
	p = 2.*abs(frac(p) - 0.5);

	float k0 = 4.*36. + 36.*seed1;

	float k2 = seed2;
	p = rotate(p, PI*(k0) / 180);
	p.y = 2. - (0.2 + k2)*(1. - exp(-abs(p.y)));

	float NUM = 10.0f;
	float lp = length(p);
	float id = floor(lp*NUM + .5) / NUM;

	//polar coords
	float2 plr = float2(lp, atan2(p.y, p.x));

	//Draw concentric arcs
	float rz = arc(plr, id, 0.425 / NUM, 0.0, PI);

	float m = rz;
	rz *= triangleNoise(p)*0.5 + 0.5;
	float3 nn = SampleRGB(RGBANoiseMedium, float2(0.123, id));
	float3 col = (SampleRGB(WoodTexture, uv + nn.xy)*nn.z + 0.25) * rz;
	col *= 1.25;
	col = smoothstep(0.0, 1.0, col);
	col = exp(col) - 1.0;
	col = clamp(col, 0.0, 1.0);

	return col;
}

float3 marquetry_normal(float2 coord, Texture2D<float3> WoodTexture, float seed1 = 7.0, float seed2 = -4.0)
{
	float diff = 0.001;
	float diffX = marquetry(float2(coord.x + diff, coord.y),WoodTexture,seed1,seed2).r - marquetry(float2(coord.x - diff, coord.y), WoodTexture, seed1, seed2).r;
	float diffY = marquetry(float2(coord.x, coord.y + diff),WoodTexture,seed1,seed2).r - marquetry(float2(coord.x, coord.y - diff), WoodTexture, seed1, seed2).r;
	float2 localDiff = float2(diffX, diffY);
	localDiff *= -1.0;
	localDiff = (localDiff / 2.0) + .5;
	float localDiffMag = length(localDiff);
	float z = sqrt(max(0., 1.0 - pow(localDiffMag, 2.0)));
	return float3(localDiff, z);
}

void SetMatLib_Marquetry(inout Material_PBR mat, inout HitInfo minHit, float2 uv, float3 T, float3 B, Texture2D<float3> WoodTexture, float seed1 = 7.0, float seed2 = -4.0)
{
	mat.albedo = marquetry(uv, WoodTexture, seed1, seed2);
	float3 n_tan = marquetry_normal(uv, WoodTexture, seed1, seed2);
	minHit.N = ApplyNTangent(n_tan, minHit.N, T, B, 1.0);
}

//#############################################################################

float swril_n21(float2 p)
{
	return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
}


float2 swril_n22(float2 p)
{
	float n = swril_n21(p);
	return float2(n, swril_n21(p + n));
}

float2 swirl(float2 uv, float seed, inout float acc_frc, inout float2 acc_rot)
{
	float tm = 0.; //iTime * .005 + 4.;

	// point
	float n = swril_n21(float2(seed, seed));
	float2 pnt = 0.5 + float2(cos(tm + n * 423.1), sin(tm + n * 254.3) * .5);

	// rotate point
	float2  dif = uv - pnt;
	float len = length(dif);
	float frc = smoothstep(.0, 1., exp(len * -2.4) * (cos(len * 10.) * .5 + .5));
	float swl = frc * sin(tm + n * 624.8) * 3.5;
	float2  rot = rotate(dif, swl);

	// for normal map
	acc_frc += frc;
	acc_rot += rot * frc;

	// rotated uv
	return rot + pnt;
}

void SetMatLib_SwirlGold(inout Material_PBR mat, inout HitInfo minHit, float2 uv, float3 T, float3 B, float intensity = 0.5, int points = 20)
{
	float acc_frc = .0;
	float2  acc_rot = 0;
	float2  sv = uv;
	for (int i = 0; i < points; i++)
		sv = swirl(sv, frac(float(i + 1) * 123.45), acc_frc, acc_rot);

	// normal map
	float3 roughness = float3(swril_n22(sv), 1.) * .02;
	float3 normal = normalize(float3(acc_rot, acc_frc * .01) + roughness);
	normal = ApplyNTangent(normal, minHit.N, T, B, intensity);
	minHit.N = normal;
}
#endif