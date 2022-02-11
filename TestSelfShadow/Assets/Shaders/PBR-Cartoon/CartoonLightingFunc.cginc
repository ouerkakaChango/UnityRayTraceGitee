#ifndef CARTOON_LIGHTING_FUNC_INCLUDED
#define CARTOON_LIGHTING_FUNC_INCLUDED

sampler2D _Ramp;
half3 _ShadowColor;
half _ShadowIntensity;
half _DiffuseLight_MidPoint;
half _DiffuseLight_Blur;
half3 _BackColor;

half3 DiffuseTerm_Cartoon(half3 lightColor, half3 diffColor, half nl)
{
	half d = nl * 0.5 + 0.5;
	half3 ramp = tex2D (_Ramp, float2(d, d)).rgb;
#ifdef UNITY_COLORSPACE_GAMMA
	ramp = GammaToLinearSpace(ramp);
#endif
	return diffColor * ramp * lightColor;
}

half3 DiffuseTerm_Cartoon2(half3 lightColor, half3 diffColor, half nl)
{
	half factor = smoothstep(_DiffuseLight_MidPoint - _DiffuseLight_Blur, _DiffuseLight_MidPoint + _DiffuseLight_Blur, nl);
	return lerp(_BackColor, lightColor, factor) * diffColor;
}

half3 Cartoon_Lighting_Indirect(in CommonShadingData shadingData, in LightingInput lightingInput, in DDIndirect indirect)
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
	final += diffuse * indirect.diffuse;
#ifndef NO_NEED_INDIRECT_SPECULAR
	final += indirectSpecularTerm;
#endif

	return final;
}

half3 Cartoon_Lighting_Direct(in CommonShadingData shadingData, in LightingInput lightingInput, in DDLight light)
{
	half3 L = light.dir;
	half3 lightColor = light.color;
#ifdef LIGHT_ATTEN_SEPERATE
	lightColor *= light.lightAtten;
#endif
	half atten = light.atten;

	half3 diffuse = shadingData.diffColor;
	half3 specular = shadingData.specColor;
	half smoothness = shadingData.smoothness;
	half oneMinusReflectivity = shadingData.oneMinusReflectivity;

	half perceptualRoughness = 1.0h - smoothness;
	half roughness = perceptualRoughness * perceptualRoughness;

	half nl = dot(lightingInput.worldNormal, L);
	half a = atten * (nl >= 0);
	half3 shadowColor = 1;
	shadowColor = lerp(1, _ShadowColor, _ShadowIntensity * (1 - a));

	half3 diffTerm = DiffuseTerm_Cartoon2(lightColor, diffuse, nl);
	half3 specularTerm = SPECULAR_TERM(lightColor * atten, specular, nl, lightingInput.worldNormal, L, lightingInput.viewDir, smoothness, roughness);

	half3 final = 0;
	final += diffTerm + specularTerm;

	return final;
}
#endif