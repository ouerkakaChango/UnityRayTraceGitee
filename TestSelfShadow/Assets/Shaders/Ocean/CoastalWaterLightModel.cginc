#ifndef COASTAL_WATER_LIGHT_MODEL_INCLUDED
#define COASTAL_WATER_LIGHT_MODEL_INCLUDED

#define INPUT_NEED_SCREEN_UV
#define INPUT_NEED_DEPTH

#include "../Framework/DDShaderLightingCommon.cginc"
#include "../Predefine/DDPDSurfaceData.cginc"
#include "UnityCG.cginc"

struct WaterSurfaceData
{
	half3 Albedo;
	half3 Normal;
	half Occlusion;
	half Smoothness;
	half3 Emission;
	float2 grabScreenUV;
	float2 screenUV;
	float depth;
};

inline void RestOutput(out WaterSurfaceData IN)
{
	IN.Albedo = 0;
	IN.Normal = half3(0, 0, 1);
	IN.Smoothness = 0;
	IN.Occlusion = 1;
	IN.Emission = 0;
	IN.grabScreenUV = 0;
	IN.screenUV = 0;
	IN.depth = 0;
}

void surf(Input IN, inout WaterSurfaceData o)
{
	o.Albedo = 0;
	o.Normal = half3(0, 0, 1);
	o.Smoothness = 0.95f;
	o.grabScreenUV = IN.grabScreenUV;
	o.screenUV = IN.screenUV;
	o.depth = IN.depth;
}

#define SurfaceData_T WaterSurfaceData
#define FUNC_SURF surf

struct WaterShadingData
{
	half3 diffColor;
	half smoothness;
	float2 grabScreenUV;
	float depth;
	float absDepth;
};

#define ShadingData_T WaterShadingData

half _MaxWaterDepth;
UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

inline void ShadingPrepare_Water(WaterSurfaceData IN, out WaterShadingData shadingData)
{
	shadingData.diffColor = IN.Albedo;
	shadingData.smoothness = IN.Smoothness;
	shadingData.grabScreenUV = IN.grabScreenUV;

	float surfaceDepth = Linear01Depth(IN.depth);

	float sceneDepth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, IN.screenUV));
	float ld = saturate((sceneDepth - surfaceDepth) * _ProjectionParams.z / _MaxWaterDepth);

	shadingData.depth = max(0.01, ld);
	shadingData.absDepth = (sceneDepth - surfaceDepth) * _ProjectionParams.z;
}

#define FUNC_SHADING_PREPARE ShadingPrepare_Water

#define USE_UNITYGI
#include "../Predefine/DDPDShaderGI.cginc"

sampler2D _GrabTexture;
sampler2D _AbsorptionTex;

half _RefractionIntensity;
half _RefractionDistortion;
half _AbsorptionR;
half _AbsorptionG;
half _AbsorptionB;
half _AbsorptionScale;

half3 _SubSurfaceColor;
half _SubSurfaceBase;
half _SubSurfaceSun;
half _SubSurfaceSunFallOff;
half _ShorelineFoamMinDepth;

sampler2D _FoamTexture;
sampler2D _FoamNoise;
half4 _FoamNoise_ST;
half _FoamSpeed;
half _FoamUVScale;
half _FoamEdge;

inline float _Pow5(float x)
{
	return x * x * x * x * x;
}

float CalculateFresnelReflectionCoefficient(float cosTheta)
{
	float waterF0 = 0.02F;
	float t = _Pow5(max(0., 1.0 - cosTheta));
	const float R_theta = waterF0 + (1.0 - waterF0) * t;
	return R_theta;
}

half3 Refraction(float2 uv, half depth)
{
	half3 refraction = tex2D(_GrabTexture, uv).rgb * _RefractionIntensity;
	half3 absorption = tex2D(_AbsorptionTex, half2(depth, 0));

	//half3 absorption = half3(_AbsorptionR, _AbsorptionG, _AbsorptionB);
	//refraction *= exp(-absorption * depth * _MaxWaterDepth * _AbsorptionScale);
	return refraction * absorption;
}

half3 DD_Skin_LightingFunc_Indirect(in WaterShadingData shadingData, in LightingInput lightingInput, in DDIndirect indirect)
{
	//return shadingData.absDepth;
	//return 1 - saturate(shadingData.absDepth / _MaxWaterDepth);


	//return 0;
	//return shadingData.depth;
	//float sDepth = Linear01Depth(shadingData.depth);
	////return sDepth;
	//float sceneDepth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, shadingData.screenUV));
	//float ld = max(0, sceneDepth - sDepth) * _ProjectionParams.z / _MaxWaterDepth;
	//half3 absorption = half3(_AbsorptionR, _AbsorptionG, _AbsorptionB);
	//return exp(-absorption * sceneZ * _MaxWaterDepth * _AbsorptionScale);
	//return ld;
	//return ld;
	//return (sceneZ);
	float fresnel = CalculateFresnelReflectionCoefficient(dot(lightingInput.viewDir, lightingInput.worldNormal));
	half3 refraction = Refraction(shadingData.grabScreenUV, shadingData.depth);
	//return ld;
	//return refraction;
	//return refraction;
	half3 reflection = indirect.specular;
	return lerp(refraction, reflection, fresnel);

	//return 

	//return 
	//return (indirect.diffuse + indirect.specular) * shadingData.diffColor;
	//return 0;
}

half3 DD_Skin_LightingFunc_Direct(in WaterShadingData shadingData, in LightingInput lightingInput, in DDLight light)
{
	//foamAmount *= saturate((i_sceneZ - i_pixelZ) / _ShorelineFoamMinDepth);
	//return shadingData.absDepth ;
	half foam = saturate(shadingData.absDepth / _ShorelineFoamMinDepth) * saturate(1 - shadingData.absDepth - _FoamEdge);
	half2 foamUV1 = lightingInput.worldPos.xz * _FoamUVScale + _FoamSpeed * _Time.y;
	half2 foamUV2 = lightingInput.worldPos.xz * _FoamUVScale - _FoamSpeed * _Time.y;
	half3 foam1 = tex2D(_FoamTexture, foamUV1);
	half3 foam2 = tex2D(_FoamTexture, foamUV2);
	half3 noise = tex2D(_FoamNoise, foamUV1 * _FoamNoise_ST.xy + _FoamNoise_ST.zw).rgb;

	return foam * (foam1 + foam2) * 0.5h * noise;
	//return foam * tex2D(_FoamTexture, foamUV);
	return saturate(shadingData.absDepth / _ShorelineFoamMinDepth) * saturate(1 - shadingData.absDepth);
	return 0;
	//return shadingData.depth;
	//return light.atten;
	//return shadingData.depth;
	half3 lightColor = light.color * light.atten;

	//float v = abs(viewDir.y);
	//half sssAtten = /*dot(worldNormal, light.dir) +*/ dot(light.dir, -viewDir);
	//half towardsSun = pow(saturate(sssAtten), _SubSurfaceSunFallOff);

	//half3 absorption = half3(_AbsorptionR, _AbsorptionG, _AbsorptionB);
	//absorption = exp(-absorption * (shadingData.depth / 2) * _MaxWaterDepth * _AbsorptionScale);
	////return absorption;
	//half3 subsurface = (_SubSurfaceBase + _SubSurfaceSun * towardsSun) * _SubSurfaceColor.rgb * lightColor;
	//subsurface *= (1.0 - v * v) * 0.48;
	//float fresnel = CalculateFresnelReflectionCoefficient(dot(viewDir, worldNormal));
	//half nl = max(0, dot(light.dir, half3(0, 1, 0)));
	////return absorption * (1 - fresnel) * nl;
	////return absorption;
	////return 1 - fresnel;
	//return subsurface * (1 - fresnel);

	half LA = (dot(lightingInput.worldNormal, -light.dir) + dot(lightingInput.viewDir, -light.dir));
	half3 L = -light.dir;
	half ee = pow(saturate(dot(lightingInput.viewDir, L)), _SubSurfaceSunFallOff) * _SubSurfaceSun;
	half3 lt = LA * ee;
	return lt;
	//return (1 - shadingData.depth);
	return lt;

	//LA = ;
	return LA;






	//return shadingData.diffColor;
	return 0;
}

#ifdef UNITY_PASS_FORWARDBASE
	#define FUNC_LIGHTING_INDIRECT DD_Skin_LightingFunc_Indirect
	#define FUNC_LIGHTING_DIRECT DD_Skin_LightingFunc_Direct
	#include "../Framework/DDShaderLighting.cginc"
#elif defined(UNITY_PASS_FORWARDADD)
	#define FUNC_LIGHTING_DIRECT DD_Skin_LightingFunc_Direct
	#include "../Framework/DDShaderLightingAdd.cginc"
#elif defined(UNITY_PASS_SHADOWCASTER)
	#include "../Framework/DDShaderShadow.cginc"
#endif

#endif