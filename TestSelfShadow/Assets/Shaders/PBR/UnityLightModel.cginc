#ifndef UNITY_LIGHT_MODEL_INCLUDED
#define UNITY_LIGHT_MODEL_INCLUDED

#ifdef USE_UNITY_LIGHT_MODEL
	#include "../Predefine/DDPDShadingData.cginc"
	#define ShadingData_T CommonShadingData

	#include "../Predefine/DDPDShadingPrepareFunc.cginc"
	#if defined(USE_PBR_BRDF2) || defined(USE_PBR_BRDF3)
	#	define FUNC_SHADING_PREPARE ShadingPrepare_DiffuseAndSpecularFromMetallic
	#else
	#	define FUNC_SHADING_PREPARE ShadingPrepare_DiffuseAndNoSpecular
	#endif

	#include "../Predefine/DDPDBRDF.cginc"
	#define DIFFUSE_TERM DiffuseTerm_Lambert

	#if defined(USE_PBR_BRDF2)
	#	define INDIRECT_SPECULAR_TERM IndirectSpecularTerm_BRDF2
	#	define SPECULAR_TERM SpecularTerm_PBR_BRDF2
	#elif defined(USE_PBR_BRDF3)
	#	define INDIRECT_SPECULAR_TERM IndirectSpecularTerm_BRDF3
	#	define SPECULAR_TERM SpecularTerm_PBR_BRDF3
	#else
	#	define INDIRECT_SPECULAR_TERM NoIndirectSpecularTerm
	#	define SPECULAR_TERM NoSpecularTerm
	#endif

	#ifdef USE_LAMBERT
	#define NO_NEED_INDIRECT_SPECULAR
	#endif

	#define USE_UNITYGI
	#include "../Predefine/DDPDShaderGI.cginc"


#if defined(UNITY_PASS_FORWARDBASE)
	#include "../Predefine/DDPDLightingFunc.cginc"
	#define FUNC_LIGHTING_INDIRECT DD_Common_LightingFunc_Indirect
	#define FUNC_LIGHTING_DIRECT DD_Common_LightingFunc_Direct
	#include "../Framework/DDShaderLighting.cginc"
#elif defined(UNITY_PASS_FORWARDADD)
	#include "../Predefine/DDPDLightingFunc.cginc"
	#define FUNC_LIGHTING_DIRECT DD_Common_LightingFunc_Direct
	#include "../Framework/DDShaderLightingAdd.cginc"
#elif defined(UNITY_PASS_SHADOWCASTER)
	#include "../Framework/DDShaderShadow.cginc"
#elif  defined(UNITY_PASS_META)
	#include "../Framework/DDShaderMeta.cginc"
#endif
#endif
#endif