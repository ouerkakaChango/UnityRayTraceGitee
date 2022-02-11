#ifndef DD_PD_LIGHTING_FUNC_INCLUDED
#define DD_PD_LIGHTING_FUNC_INCLUDED

#ifdef _USE_COLOR_SHADOW
half4 _ShadowParams;
inline half3 GetShadowAtten(half atten)
{
	atten = lerp(atten, 1, 1 - _ShadowParams.w);
	return lerp(_ShadowParams.rgb, 1, atten);
}
#else
inline half GetShadowAtten(half atten)
{
	return atten;
}
#endif

half3 DD_Common_LightingFunc_Indirect(in ShadingData_T shadingData, in LightingInput lightingInput, in DDIndirect indirect)
{
	half3 diffuse = shadingData.diffColor;
	half3 specular = shadingData.specColor;
	half smoothness = shadingData.smoothness;
	half oneMinusReflectivity = shadingData.oneMinusReflectivity;

	half nv = saturate(dot(lightingInput.worldNormal, lightingInput.viewDir));
	half perceptualRoughness = 1.0h - smoothness;
	half roughness = perceptualRoughness * perceptualRoughness;

	half3 indirectSpecularTerm = INDIRECT_SPECULAR_TERM(indirect.specular, specular, nv, smoothness, roughness, perceptualRoughness, oneMinusReflectivity);

	half3 final = 0;
	final = diffuse * indirect.diffuse;
#ifndef NO_NEED_INDIRECT_SPECULAR
	final += indirectSpecularTerm;
#endif

	return final;
}

half3 DD_Common_LightingFunc_Direct(in ShadingData_T shadingData, in LightingInput lightingInput, in DDLight light)
{
	half3 L = light.dir;
	half3 lightColor = light.color * GetShadowAtten(light.atten);
#ifdef LIGHT_ATTEN_SEPERATE
	lightColor *= light.lightAtten;
#endif

	half3 diffuse = shadingData.diffColor;
	half3 specular = shadingData.specColor;
	half smoothness = shadingData.smoothness;

	half perceptualRoughness = 1.0h - smoothness;
	half roughness = perceptualRoughness * perceptualRoughness;

	half nl = dot(lightingInput.worldNormal, L);
	half3 diffuseTerm = DIFFUSE_TERM(lightColor, diffuse, nl);
	half3 specularTerm = SPECULAR_TERM(lightColor, specular, nl, lightingInput.worldNormal, L, lightingInput.viewDir, smoothness, roughness);

	half3 final = 0;
	final += diffuseTerm + specularTerm;

	return final;
}

#endif