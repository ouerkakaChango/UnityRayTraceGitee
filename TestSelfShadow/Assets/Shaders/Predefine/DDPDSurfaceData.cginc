#ifndef DD_PD_SURFACE_DATA_INCLUDED
#define DD_PD_SURFACE_DATA_INCLUDED

struct CommonSurfaceData
{
	half3 Albedo;
	half3 Normal;
	half3 Emission;
	half Metallic;
	half Smoothness;
	half Occlusion;
	half Alpha;
};

inline void RestOutput(out CommonSurfaceData IN)
{
	IN.Albedo = 0;
	IN.Normal = half3(0, 0, 1);
	IN.Emission = 0;
	IN.Metallic = 0;
	IN.Smoothness = 0;
	IN.Occlusion = 1;
	IN.Alpha = 1;
}

#endif