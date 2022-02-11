#ifndef DD_PD_SHADING_PREPARE_FUNC_INCLUDED
#define DD_PD_SHADING_PREPARE_FUNC_INCLUDED

#include "DDPDUtils.cginc"

inline void ShadingPrepare_DiffuseAndSpecularFromMetallic(SurfaceData_T IN, out ShadingData_T shadingData)
{
	shadingData.diffColor = DD_DiffuseAndSpecularFromMetallic(IN.Albedo, IN.Metallic, shadingData.specColor, shadingData.oneMinusReflectivity);
	shadingData.smoothness = IN.Smoothness;
	shadingData.diffColor = DD_PreMultiplyAlpha(shadingData.diffColor, IN.Alpha, shadingData.oneMinusReflectivity, shadingData.alpha);
}

inline void ShadingPrepare_DiffuseAndNoSpecular(SurfaceData_T IN, out ShadingData_T shadingData)
{
	shadingData.diffColor = IN.Albedo;
	shadingData.specColor = 0;
	shadingData.oneMinusReflectivity = 1;
	shadingData.smoothness = 0;
	shadingData.diffColor = DD_PreMultiplyAlpha(shadingData.diffColor, IN.Alpha, shadingData.oneMinusReflectivity, shadingData.alpha);
}

#endif