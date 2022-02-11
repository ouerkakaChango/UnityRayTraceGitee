#ifndef DD_PD_SHADING_DATA_INCLUDED
#define DD_PD_SHADING_DATA_INCLUDED

struct CommonShadingData
{
	half3 diffColor;
	half3 specColor;
	half oneMinusReflectivity;
	half smoothness;
	half alpha;
};

#endif