#ifndef DD_SHADER_LIGHT_UTIL_INCLUDED
#define DD_SHADER_LIGHT_UTIL_INCLUDED

#include "AutoLight.cginc"

inline half LightAtten(half3 pos)
{
	half atten = 1;

#if defined(POINT)
	float3 lightCoord = mul(unity_WorldToLight, float4(pos, 1)).xyz;
	atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
#elif defined(SPOT)
	float4 lightCoord = mul(unity_WorldToLight, float4(pos, 1));
	atten = (lightCoord.z > 0) * UnitySpotCookie(lightCoord) * UnitySpotAttenuate(lightCoord.xyz);
#elif defined(POINT_COOKIE)
	float3 lightCoord = mul(unity_WorldToLight, float4(pos, 1)).xyz;
	atten = tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).r * texCUBE(_LightTexture0, lightCoord).w;
#elif defined(DIRECTIONAL_COOKIE)
	float3 lightCoord = mul(unity_WorldToLight, float4(pos, 1)).xyz;
	atten = tex2D(_LightTexture0, lightCoord).w;
#else
	atten = 1.0;
#endif

	return atten;
}

inline DDLight GetLight(half atten, float3 worldPos)
{
	DDLight l;
	l.color = _LightColor0.rgb;

#ifdef UNITY_COLORSPACE_GAMMA
	l.color = GammaToLinearSpace(l.color);
#endif

#ifndef USING_DIRECTIONAL_LIGHT
	l.dir = normalize(UnityWorldSpaceLightDir(worldPos));
#else
	l.dir = _WorldSpaceLightPos0.xyz;
#endif

	l.atten = atten;

#ifdef LIGHT_ATTEN_SEPERATE
	l.lightAtten = LightAtten(worldPos);
#else
	l.lightAtten = 0;
#endif

	return l;
}

#endif