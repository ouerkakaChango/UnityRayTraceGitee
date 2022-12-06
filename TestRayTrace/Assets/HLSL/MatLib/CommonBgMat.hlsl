#ifndef COMMONBGMAT_HLSL
#define COMMONBGMAT_HLSL
#include "../CommonDef.hlsl"
#include "../TransferMath/TransferMath.hlsl"
//#include "../PBR/PBRCommonDef.hlsl"
//#include "../PBR/PBR_IBL.hlsl"
//#include "../PBR/PBR_GGX.hlsl"
//#include "../UV/UVCommonDef.hlsl"
#include "../Noise/NoiseCommonDef.hlsl"

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

//https://www.shadertoy.com/view/tdSXzD
//---WaterSky---------------------------------------------------------------------------------------------------
//AURORA STUFF
float2x2 mm2(in float a) {
	float c = cos(a);
	float s = sin(a);
	return float2x2(c, s, -s, c);
}

float WaterSky_tri(in float x) {
	return clamp(abs(frac(x) - .5), 0.01, 0.49);
}

float2 WaterSky_tri2(in float2 p) {
	return float2(WaterSky_tri(p.x) + WaterSky_tri(p.y), WaterSky_tri(p.y + WaterSky_tri(p.x)));
}

float triNoise2d(in float2 p, float spd)
{
	float2x2 m2 = float2x2(0.95534, 0.29552, -0.29552, 0.95534);
	float z = 1.8;
	float z2 = 2.5;
	float rz = 0.;
	p = mul(mm2(p.x*0.06),p);
	float2 bp = p;
	for (float i = 0.; i < 5.; i++)
	{
		float2 dg = WaterSky_tri2(bp*1.85)*.75;
		dg = mul(mm2(_Time.y*spd),dg);
		p -= dg / z2;

		bp *= 1.3;
		z2 *= 1.45;
		z *= .42;
		p *= 1.21 + (rz - 1.0)*.02;

		rz += WaterSky_tri(p.x + WaterSky_tri(p.y))*z;
		p = mul(-m2, p);
	}
	return clamp(1. / pow(rz*29., 1.3), 0., .55);
}

float hash21(in float2 n) { return frac(sin(dot(n, float2(12.9898, 4.1414))) * 43758.5453); }
float4 aurora(float3 ro, float3 rd, float2 fragCoord)
{
	float4 col = 0;
	float4 avgCol = 0;
	ro *= 1e-5;
	float mt = 10.;
	for (float i = 0.; i < 5.; i++)
	{
		float of = 0.006*hash21(fragCoord.xy)*smoothstep(0., 15., i*mt);
		float pt = ((.8 + pow((i*mt), 1.2)*.001) - rd.y) / (rd.y*2. + 0.4);
		pt -= of;
		float3 bpos = (ro)+pt * rd;
		float2 p = bpos.zx;
		//float2 p = rd.zx;
		float rzt = triNoise2d(p, 0.1);
		float4 col2 = float4(0, 0, 0, rzt);
		col2.rgb = (sin(1. - float3(2.15, -.5, 1.2) + (i*mt)*0.053)*(0.5*mt))*rzt;
		avgCol = lerp(avgCol, col2, .5);
		col += avgCol * exp2((-i * mt)*0.04 - 2.5)*smoothstep(0., 5., i*mt);

	}

	col *= (clamp(rd.y*15. + .4, 0., 1.2));
	return col * 2.8;
}

float escape(in float3 p, in float3 d, in float R) {
	float3 v = p - float3(0., -6360e3, 0.);
	float b = dot(v, d);
	float c = dot(v, v) - R * R;
	float det2 = b * b - c;
	if (det2 < 0.) return -1.;
	float det = sqrt(det2);
	float t1 = -b - det, t2 = -b + det;
	return (t1 >= 0.) ? t1 : t2;
}

float WaterSky_noise(in float2 uv) {
	//return textureLod(iChannel0, (v + .5) / 256., 0.).r;
	return shiftNoiseTex.SampleLevel(noise_linear_repeat_sampler, (uv + 0.5) / 256, 0).x;
}

// by iq
float WaterSky_Noise(in float3 x)
{
	float3 p = floor(x);
	float3 f = frac(x);
	f = f * f*(3.0 - 2.0*f);

	float2 uv = (p.xy + float2(37.0, 17.0)*p.z) + f.xy;
	float2 rg = shiftNoiseTex.SampleLevel(noise_linear_repeat_sampler, (uv + 0.5) / 256, 0).yx;//texture(iChannel0, (uv + 0.5) / 256.0, -100.0).yx;
	return lerp(rg.x, rg.y, f.z);
}

float fnoise(float3 p, in float t)
{
	p *= .25;
	float f;
	f = 0.5000 * WaterSky_Noise(p); p = p * 3.02; p.y -= t * .1; //t*.05 speed cloud changes
	f += 0.2500 * WaterSky_Noise(p); p = p * 3.03; p.y += t * .06;
	f += 0.1250 * WaterSky_Noise(p); p = p * 3.01;
	f += 0.0625   * WaterSky_Noise(p); p = p * 3.03;
	f += 0.03125  * WaterSky_Noise(p); p = p * 3.02;
	//f += 0.015625 * noise_computational(p);
	return f;
}

float cloud(float3 p, in float t) {
	float cld = fnoise(p*2e-4, t) + 0.5 * 0.1;
	cld = smoothstep(.4 + .04, .6 + .04, cld);
	cld *= cld * (5.0*5.0);
	return cld + 0.01 * (0.5*20.);
}

void densities(in float3 pos, out float rayleigh, out float mie) {
	float h = length(pos - float3(0., -6360e3, 0.)) - 6360e3;
	rayleigh = exp(-h / 8e3);
	float3 d = pos;
	d.y = 0.0;
	float dist = length(d);

	float cld = 0.;
	if (5e3 < h && h < 8e3) {
		cld = cloud(pos + float3(_Time.y*5e2, 0., _Time.y*6e2), _Time.y)*0.5; //direction and speed the cloud movers
		cld *= sin(3.1415*(h - 5e3) / 5e3) * 0.5;
	}

	if (dist > 70e3) {

		float factor = clamp(1.0 - ((dist - 70e3) / (70e3 - 1.0)), 0.0, 1.0);
		cld *= factor;
	}

	mie = exp(-h / 1.2e3) + cld + 0.01 * (0.5*20.);

}

// this can be explained: http://www.scratchapixel.com/lessons/3d-advanced-lessons/simulating-the-colors-of-the-sky/atmospheric-scattering/
void scatter(float3 Ds, float3 o, float3 d, out float3 col, out float3 scat) {
	float3 bR = float3(5.8e-6, 13.5e-6, 33.1e-6); //normal earth
	float L = escape(o, d, 6380e3);
	float mu = dot(d, Ds);
	float opmu2 = 1. + mu * mu;
	float phaseR = .0596831 * opmu2;
	float phaseM = .1193662 * (1. - 0.45 * 0.45) * opmu2 / ((2. + 0.45 * 0.45) * pow(1. + 0.45 * 0.45 - 2.*0.45*mu, 1.5));
	float phaseS = .1193662 * (1. - 0.999) * opmu2 / ((2. + 0.999) * pow(1. + 0.999 - 2.*0.999*mu, 1.5));

	float depthR = 0., depthM = 0.;
	float3 R = 0, M = 0;

	float dl = L / 16.;
	for (int i = 0; i < 16; ++i) {
		float l = i * dl;
		float3 p = (o + d * l);

		float dR, dM;
		densities(p, dR, dM);
		dR *= dl; dM *= dl;
		depthR += dR;
		depthM += dM;

		float Ls = escape(p, Ds, 6380e3);
		if (Ls > 0.) {
			float dls = Ls / float(16);
			float depthRs = 0., depthMs = 0.;
			for (int j = 0; j < 16; ++j) {
				float ls = float(j) * dls;
				float3 ps = (p + Ds * ls);
				float dRs, dMs;
				densities(ps, dRs, dMs);
				depthRs += dRs * dls;
				depthMs += dMs * dls;
			}

			float3 A = exp(-(bR * (depthRs + depthR) + 21e-6 * (depthMs + depthM)));
			R += (A * dR);
			M += A * dM;
		}
		else {
		}
	}

	col = (10.) *(M * 21e-6 * (phaseM)); // Mie scattering
	col += (5.) *(M * 21e-6 *phaseS); //Sun
	col += (10.) *(R * bR * phaseR); //Rayleigh scattering
	scat = 0.1 *(21e-6*depthM);
}

float3 WaterSky_hash33(float3 p)
{
	p = frac(p * float3(443.8975, 397.2973, 491.1871));
	p += dot(p.zxy, p.yxz + 19.27);
	return frac(float3(p.x * p.y, p.z*p.x, p.y*p.z));
}

float3 WaterSky_stars(float2 iResolution, in float3 p)
{
	float3 c = 0;
	float res = iResolution.x*2.5;

	for (float i = 0.; i < 4.; i++)
	{
		float3 q = frac(p*(.15*res)) - 0.5;
		float3 id = floor(p*(.15*res));
		float2 rn = WaterSky_hash33(id).xy;
		float c2 = 1. - smoothstep(0., .6, length(q));
		c2 *= step(rn.x, .0005 + i * i*0.001);
		c += c2 * (lerp(float3(1.0, 0.49, 0.1), float3(0.75, 0.9, 1.), rn.y)*0.1 + 0.9);
		p *= 1.3;
	}
	return c * c*.8;
}

inline float zenithDensity(float x) 
{
	return 0.5 / pow(max(x - 0.48, 0.0035), 0.75);
}

float getSunPoint(float2 p, float2 lp) {
	float fov = tan(radians(60.0));
	return smoothstep(0.04*(fov / 2.0), 0.026*(fov / 2.0), distance(p, lp)) * 50.0;
}

float getMie(float2 p, float2 lp) {
	float mytest = lp.y < 0.5 ? (lp.y + 0.5)*pow(0.05, 20.0) : 0.05;
	float disk = clamp(1.0 - pow(distance(p, lp), mytest), 0.0, 1.0);
	return disk * disk*(3.0 - 2.0 * disk) * 0.25 * PI;
}

float3 getSkyAbsorption(float3 x, float y) {
	float3 absorption = x * y;
	absorption = pow(absorption, 1.0 - (y + absorption) * 0.5) / x / y;
	return absorption;
}

float3 jodieReinhardTonemap(float3 c) {
	float l = dot(c, float3(0.2126, 0.7152, 0.0722));
	float3 tc = c / (c + 1.0);
	return lerp(c / (l + 1.0), tc, tc);
}

float3 getAtmosphericScattering(float2 p, float2 lp) {
	float3 skyColor = float3(0.37, 0.55, 1.0) * (1.0 + 0.0);
	float zenithnew = zenithDensity(p.y);
	float sunPointDistMult = clamp(length(max(lp.y + 0.1 - 0.48, 0.0)), 0.0, 1.0);
	float3 absorption = getSkyAbsorption(skyColor, zenithnew);
	float3 sunAbsorption = getSkyAbsorption(skyColor, zenithDensity(lp.y + 0.1));
	float3 sun3 = getSunPoint(p, lp) * absorption;
	float3 mie2 = getMie(p, lp) * sunAbsorption;
	float3 totalSky = sun3; //+ mie2;
	totalSky *= sunAbsorption * 0.5 + 0.5 * length(sunAbsorption);
	float3 newSky = jodieReinhardTonemap(totalSky);
	return newSky;
}

float3 CommonBg_WaterSky(Ray ray, float2 fragCoord, float2 iResolution, float2 iSunPos) {

	float AR = iResolution.x / iResolution.y;
	float M = 1.0; //canvas.innerWidth/M //canvas.innerHeight/M --res

	float2 uvMouse = iSunPos;//(iSunPos.xy / iResolution.xy);
	uvMouse.x *= AR;

	float2 uv0 = (fragCoord.xy / iResolution.xy);
	uv0 *= M;

	float2 uv = uv0 * (2.0*M) - (1.0*M);
	uv.x *= AR;

	float fov = tan(radians(60.0));

	if (uvMouse.y == 0.) uvMouse.y = (0.7 - (0.05*fov)); //initial view 
	if (uvMouse.x == 0.) uvMouse.x = (1.0 - (0.05*fov)); //initial view


	float3 Ds = normalize(float3(uvMouse.x - ((0.5*AR)), uvMouse.y - 0.5, (fov / -2.0)));


	float3 O = float3(0., 5e1 , 0.);
	float3 D = ray.dir;

	float3 color = 0;
	float3 scat = 0;
	float att = 1;
	float staratt = 1;
	float scatatt = 1;
	float3 star = 0;
	float4 aur = 0;

	float fade = smoothstep(0., 0.01, abs(D.y))*0.5 + 0.9;

	staratt = 1. - min(1.0, (uvMouse.y*2.0));
	scatatt = 1. - min(1.0, (uvMouse.y*2.2));
	float t = _Time.y;
	if (D.y < -(5e1  / 2.5e5)) {
		float L = -O.y / D.y;
		O = O + D * L;
		D.y = -D.y; 
		D = normalize(D + float3(0, .003*sin(t + 6.2831*WaterSky_noise(O.xz + float2(0., -t * 1e3))), 0.));
		att = .6;
		star = WaterSky_stars(iResolution, D);
		//uvMouse.y < 0.5 ? aur = smoothstep(0.0, 2.5, aurora(O, D, fragCoord)) : aur = aur;
		if (uvMouse.y < 0.5)
		{
			aur = smoothstep(0.0, 2.5, aurora(O, D, fragCoord));
		}
		else
		{
			aur = aur;
		}
	}
	else {
		float L1 = O.y / D.y;
		float3 O1 = O + D * L1;

		float3 D1 = 1;
		D1 = normalize(D + float3(1., 0.0009*sin(t + 6.2831*WaterSky_noise(O1.xz + float2(0., t*0.8))), 0.));
		star = WaterSky_stars(iResolution, D1);
		//uvMouse.y < 0.5 ? aur = smoothstep(0., 1.5, aurora(O, D, fragCoord))*fade : aur = aur;
		if (uvMouse.y < 0.5)
		{
			aur = smoothstep(0., 1.5, aurora(O, D, fragCoord))*fade;
		}
		else
		{
			aur = aur;
		}
	}

	star *= att;
	star *= staratt;

	scatter(Ds, ray.pos, D, color, scat);
	color *= att;
	scat *= att;
	scat *= scatatt;

	color += scat;
	color += star;
	//color=color*(1.-(aur.a)*scatatt) + (aur.rgb*scatatt);
	color += aur.rgb*scatatt;
	//color = color / (1 + color);
	//color = pow(color, 0.45);
	return color;
}

//___WaterSky___________________________________________________________________________________________________

#endif