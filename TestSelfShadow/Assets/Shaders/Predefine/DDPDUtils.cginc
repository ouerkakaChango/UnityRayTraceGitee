#ifndef DD_PD_UTILS_INCLUDED
#define DD_PD_UTILS_INCLUDED

#define DD_ColorSpaceDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04)

inline half DD_OneMinusReflectivityFromMetallic(half metallic)
{
	// We'll need oneMinusReflectivity, so
	//   1-reflectivity = 1-lerp(dielectricSpec, 1, metallic) = lerp(1-dielectricSpec, 0, metallic)
	// store (1-dielectricSpec) in unity_ColorSpaceDielectricSpec.a, then
	//   1-reflectivity = lerp(alpha, 0, metallic) = alpha + metallic*(0 - alpha) =
	//                  = alpha - metallic * alpha
	half oneMinusDielectricSpec = DD_ColorSpaceDielectricSpec.a;
	return oneMinusDielectricSpec - metallic * oneMinusDielectricSpec;
}

inline half3 DD_DiffuseAndSpecularFromMetallic(half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity)
{
	specColor = lerp(DD_ColorSpaceDielectricSpec.rgb, albedo, metallic);
	oneMinusReflectivity = DD_OneMinusReflectivityFromMetallic(metallic);
	return albedo * oneMinusReflectivity;
}

inline half3 DD_PreMultiplyAlpha(half3 diffColor, half alpha, half oneMinusReflectivity, out half outModifiedAlpha)
{
#if defined(_ALPHAPREMULTIPLY_ON)
    // NOTE: shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)

    // Transparency 'removes' from Diffuse component
    diffColor *= alpha;

#if (SHADER_TARGET < 30)
    // SM2.0: instruction count limitation
    // Instead will sacrifice part of physically based transparency where amount Reflectivity is affecting Transparency
    // SM2.0: uses unmodified alpha
    outModifiedAlpha = alpha;
#else
    // Reflectivity 'removes' from the rest of components, including Transparency
    // outAlpha = 1-(1-alpha)*(1-reflectivity) = 1-(oneMinusReflectivity - alpha*oneMinusReflectivity) =
    //          = 1-oneMinusReflectivity + alpha*oneMinusReflectivity
    outModifiedAlpha = 1 - oneMinusReflectivity + alpha * oneMinusReflectivity;
#endif
#else
    outModifiedAlpha = alpha;
#endif
    return diffColor;
}

#endif