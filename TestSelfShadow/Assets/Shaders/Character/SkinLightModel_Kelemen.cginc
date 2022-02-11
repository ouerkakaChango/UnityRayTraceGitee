#ifndef SKIN_LIGHT_MODEL_INCLUDED
#define SKIN_LIGHT_MODEL_INCLUDED

#include "UnityStandardUtils.cginc"

#define TEX1_UVST _MainTex_ST
#define INPUT_NEED_WORLD_POS
#define INPUT_NEED_WORLD_VERTEX_NORMAL
#include "../Framework/DDShaderLightingCommon.cginc"
#include "../Framework/DDShaderUtil.cginc"

sampler2D _MainTex;
half4 _MainTex_ST;
half4 _Color;

sampler2D _BumpMap;

sampler2D _MaskTex;
half _Smoothness;
half _SpecularScale;
half _CurvatureFactor;

struct SkinSurfaceData
{
	half3 Albedo;
	half3 Normal;
	half Smoothness;
	half Occlusion;
	half Curvature;
	half3 Emission;
	half SpecularScale;
};

inline void RestOutput(out SkinSurfaceData IN)
{
	IN.Albedo = 0;
	IN.Normal = half3(0, 0, 1);
	IN.Smoothness = 0;
	IN.Occlusion = 1;
	IN.SpecularScale = 1;
	IN.Emission = 0;
	IN.Curvature = 0.5;
}

void surf(Input IN, inout SkinSurfaceData o)
{
	half4 col = tex2D(_MainTex, IN.uv);
	half3 albedo = col.rgb * _Color.rgb;
#ifdef UNITY_COLORSPACE_GAMMA
	albedo = GammaToLinearSpace(albedo);
#endif
	o.Albedo = albedo;
	o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv));
	half4 mask = tex2D(_MaskTex, IN.uv);
	o.Smoothness = mask.r * _Smoothness;
	o.SpecularScale = mask.g * _SpecularScale;
#if defined(CURVE_REALTIME)
	o.Curvature = saturate(_CurvatureFactor * 0.01 * (length(fwidth(IN.worldVertexNormal)) / length(fwidth(IN.worldPos))));
#elif defined(CURVE_TEX)
	o.Curvature = mask.b;
#endif
	o.Occlusion = mask.a;
}

#define SurfaceData_T SkinSurfaceData
#define FUNC_SURF surf

struct SkinShadingData
{
	half3 diffColor;
	half3 specColor;
	half smoothness;
	half curvature;
	half oneMinusReflectivity;
	half specularScale;
	half alpha;
};

#define ShadingData_T SkinShadingData

inline void ShadingPrepare_Skin(SkinSurfaceData IN, out SkinShadingData shadingData)
{
	shadingData.specColor = 0.028f;
	shadingData.diffColor = EnergyConservationBetweenDiffuseAndSpecular(IN.Albedo, shadingData.specColor, shadingData.oneMinusReflectivity);
	shadingData.smoothness = IN.Smoothness;
	shadingData.curvature = IN.Curvature;
	shadingData.specularScale = IN.SpecularScale;
	shadingData.alpha = 1;
}

#define FUNC_SHADING_PREPARE ShadingPrepare_Skin

sampler2D _SkinLUT;
sampler2D _KelemenLUT;

//float KS_Skin_Specular(
//	float3 N, // Bumped surface normal    
//	float3 L, // Points to light    
//	float3 V, // Points to eye    
//	float m,  // Roughness    
//	float rho_s, // Specular brightness    
//	uniform texobj2D beckmannTex ) 
//{   
//	float result = 0.0;   
//	float ndotl = dot( N, L ); 
//	if( ndotl > 0.0 ) 
//	{    
//		float3 h = L + V; // Unnormalized half-way vector    
//		float3 H = normalize( h );    
//		float ndoth = dot( N, H );    
//		float PH = pow( 2.0*f1tex2D(beckmannTex,float2(ndoth,m)), 10.0 );   
//		float F = fresnelReflectance( H, V, 0.028 );    
//		float frSpec = max( PH * F / dot( h, h ), 0 );    
//		result = ndotl * rho_s * frSpec; // BRDF * dot(N,L) * rho_s  
//	}  
//	return result; 
//} 

//float4 finalSkinShader(
//	float3 position : POSITION, 
//	float2 texCoord : TEXCOORD0, 
//	float3 normal : TEXCOORD1,   // Shadow map coords for the modified translucent shadow map    
//	float4 TSM_coord : TEXCOORD2,   // Blurred irradiance textures    
//	uniform texobj2D irrad1Tex,   
//	uniform texobj2D irrad6Tex,   // RGB Gaussian weights that define skin profiles    
//	uniform float3 gauss1w,   
//	uniform float3 gauss6w,   
//	uniform float mix, // Determines pre-/post-scatter texturing    
//	uniform texobj2D TSMTex,   
//	uniform texobj2D rhodTex ) 
//{   
//	// The total diffuse light exiting the surface    
//	float3 diffuseLight = 0;   
//	float4 irrad1tap = f4tex2D( irrad1Tex, texCoord );   
//	float4 irrad6tap = f4tex2D( irrad6Tex, texCoord );   
//	diffuseLight += gauss1w * irrad1tap.xyz;
//	diffuseLight += gauss6w * irrad6tap.xyz;   // Renormalize diffusion profiles to white    
//	float3 normConst = gauss1w + guass2w + . . . + gauss6w;  
//	diffuseLight /= normConst; // Renormalize to white diffuse light    
//							   // Compute global scatter from modified TSM    
//							   // TSMtap = (distance to light, u, v)    
//	float3 TSMtap = f3tex2D( TSMTex, TSM_coord.xy / TSM_coord.w ); // Four average thicknesses through the object (in mm)    
//	float4 thickness_mm = 1.0 * -(1.0 / 0.2) * log( float4( irrad2tap.w, irrad3tap.w, irrad4tap.w, irrad5tap.w )); 
//	float2 stretchTap = f2tex2D( stretch32Tex, texCoord ); 
//	float stretchval = 0.5 * ( stretchTap.x + stretchTap.y ); 
//	float4 a_values = float4( 0.433, 0.753, 1.412, 2.722 ); 
//	float4 inv_a = -1.0 / ( 2.0 * a_values * a_values ); 
//	float4 fades = exp( thickness_mm * thickness_mm * inv_a ); 
//	float textureScale = 1024.0 * 0.1 / stretchval; 
//	float blendFactor4 = saturate(textureScale *                               length( v2f.c_texCoord.xy - TSMtap.yz ) /                               ( a_values.y * 6.0 ) ); 
//	float blendFactor5 = saturate(textureScale *                               length( v2f.c_texCoord.xy - TSMtap.yz ) /                               ( a_values.z * 6.0 ) ); 
//	float blendFactor6 = saturate(textureScale *                               length( v2f.c_texCoord.xy - TSMtap.yz ) /                               ( a_values.w * 6.0 ) ); 
//	diffuseLight += gauss4w / normConst * fades.y * blendFactor4 *                 f3tex2D( irrad4Tex, TSMtap.yz ).xyz; 
//	diffuseLight += gauss5w / normConst * fades.z * blendFactor5 *                 f3tex2D( irrad5Tex, TSMtap.yz ).xyz; 
//	diffuseLight += gauss6w / normConst * fades.w * blendFactor6 *                 f3tex2D( irrad6Tex, TSMtap.yz ).xyz; // Determine skin color from a diffuseColor map 
//	diffuseLight *= pow(f3tex2D( diffuseColorTex, texCoord ), 1.0�Cmix); // Energy conservation (optional) �C rho_s and m can be painted    
//																		// in a texture    
//	float finalScale = 1 �C rho_s*f1tex2D(rhodTex, float2(dot(N, V), m); 
//	diffuseLight *= finalScale; 
//	float3 specularLight = 0;   // Compute specular for each light    for (each light)     
//	specularLight += lightColor[i] * lightShadow[i] * KS_Skin_Specular( N, L[i], V, m, rho_s, beckmannTex );   
//	return float4( diffuseLight + specularLight, 1.0 ); 
//} 

#define USE_UNITYGI
#define USE_CUSTOM_FUNC_GI
#include "../Predefine/DDPDShaderGI.cginc"

void Skin_GI(in SurfaceData_T s, in DDGIInput input, out DDGI gi)
{
	GI_IndirectDiffuse(1, input, gi);
#ifndef NO_NEED_INDIRECT_SPECULAR
	gi.indirect.specular = GI_IndirectSpecular(s.Occlusion, s.Smoothness, input);
#endif
}

half3 IndirectSpecularTerm_Skin(half3 indirectLightColor, half3 specColor, half nv, half smoothness, half roughness, half perceptualRoughness, half specularScale, half oneMinusReflectivity)
{
	half surfaceReduction = (0.6 - 0.08 * perceptualRoughness);
	surfaceReduction = 1.0 - roughness * perceptualRoughness * surfaceReduction;
	half grazingTerm = saturate(smoothness + (1 - oneMinusReflectivity));

	return surfaceReduction * FresnelLerpFast(specColor, grazingTerm, nv) * specularScale * indirectLightColor;
}

half3 DiffuseTerm_Skin(half3 lightColor, half3 diffColor, half nl, half curvature)
{
	half wrappedNdL = (nl * 0.5 + 0.5);
	half3 diffFactor = tex2D(_SkinLUT, float2(wrappedNdL, curvature));
	return diffColor * diffFactor * lightColor;
}

half Pow10(half v)
{
	half v2 = v * v;
	half v4 = v2 * v2;
	return v4 * v4 * v2;
}

half3 SpecularTerm_Kelemen(half3 lightColor, half3 specColor, half nl, half3 worldNormal, half3 lightDir, half3 viewDir, half smoothness, half roughness, half specularScale)
{
	float3 halfVector = float3(lightDir)+viewDir;
	float3 halfDir = Unity_SafeNormalize(halfVector);
	float nh = saturate(dot(worldNormal, halfDir));
	float lh = saturate(dot(lightDir, halfDir));

	half kelemen = tex2D(_KelemenLUT, float2(nh, roughness)).r;
	half PH = 1;
	PH = pow(2.0 * kelemen, 10);
	PH = Pow10(2.0 * kelemen);
	half F = FresnelTerm(specColor, lh);

	return max(PH * F / dot(halfVector, halfVector), 0) * max(nl, 0) * specularScale * lightColor;
}

half3 SpecularTerm_BlinnPhong(half3 lightColor, half3 specColor, half nl, half3 worldNormal, half3 lightDir, half3 viewDir, half smoothness, half roughness, half specularScale)
{
	float3 halfDir = Unity_SafeNormalize(float3(lightDir)+viewDir);
	float nh = dot(worldNormal, halfDir);
	return pow(max(0, nh), 10.0) * smoothness * max(nl, 0) * specularScale * lightColor;
}

half3 DD_Skin_LightingFunc_Indirect(in SkinShadingData shadingData, in LightingInput lightingInput, in DDIndirect indirect)
{
	half3 diffuse = shadingData.diffColor;
	half3 specular = shadingData.specColor;
	half smoothness = shadingData.smoothness;
	half oneMinusReflectivity = shadingData.oneMinusReflectivity;
	half specularScale = shadingData.specularScale;

	half nv = saturate(dot(lightingInput.worldNormal, lightingInput.viewDir));
	half perceptualRoughness = 1.0h - smoothness;
	half roughness = perceptualRoughness * perceptualRoughness;

	half3 indirectSpecularTerm = IndirectSpecularTerm_Skin(indirect.specular, specular, nv, smoothness, roughness, perceptualRoughness, specularScale, oneMinusReflectivity);

	half3 final = 0;
	final += diffuse * indirect.diffuse;
#ifndef NO_NEED_INDIRECT_SPECULAR
	final += indirectSpecularTerm;
#endif

	return final;
}

half3 DD_Skin_LightingFunc_Direct(in ShadingData_T shadingData, in LightingInput lightingInput, in DDLight light)
{
	half3 L = light.dir;
	half3 lightColor = light.color * light.atten;

	half3 diffuse = shadingData.diffColor;
	half3 specular = shadingData.specColor;
	half smoothness = shadingData.smoothness;
	half curvature = shadingData.curvature;
	half oneMinusReflectivity = shadingData.oneMinusReflectivity;
	half specularScale = shadingData.specularScale;

	half perceptualRoughness = 1.0h - smoothness;
	half roughness = perceptualRoughness * perceptualRoughness;

	half nl = dot(lightingInput.worldNormal, L);
	half3 diffTerm = DiffuseTerm_Skin(lightColor, diffuse, nl, curvature);
	half3 specTerm = SpecularTerm_Kelemen(lightColor, specular, nl, lightingInput.worldNormal, L, lightingInput.viewDir, smoothness, roughness, specularScale);

	half3 final = 0;
	final += diffTerm + specTerm;

	return final;
}

#define _NORMALMAP

#ifdef UNITY_PASS_FORWARDBASE
	#define FUNC_GI Skin_GI
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