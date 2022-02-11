#ifndef UNITY_GI_INCLUDED
#define UNITY_GI_INCLUDED

#ifdef USE_UNITYGI

#include "UnityGlobalIllumination.cginc"
#include "UnityStandardUtils.cginc"
#include "UnityStandardBRDF.cginc"

#ifdef LIGHTMAP_ON
#   define DD_V2F_INDIRECT_T    half2
#   define DD_V2F_INDIRECT(idx) DD_V2F_INDIRECT_T indirect : TEXCOORD##idx;
#   define USE_GI
#elif UNITY_SHOULD_SAMPLE_SH
#   define DD_V2F_INDIRECT_T    half3
#   define DD_V2F_INDIRECT(idx) DD_V2F_INDIRECT_T indirect : TEXCOORD##idx;
#   define USE_GI
#else
#   define DD_V2F_INDIRECT_T    void
#   define DD_V2F_INDIRECT(idx) 
#endif

half3 DD_ShadeSHPerVertex (half3 normal, half3 ambient)
{
    #if UNITY_SAMPLE_FULL_SH_PER_PIXEL
        // Completely per-pixel
        // nothing to do here
    #elif (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        // Completely per-vertex
        ambient += max(half3(0,0,0), ShadeSH9 (half4(normal, 1.0)));
    #else
        // L2 per-vertex, L0..L1 & gamma-correction per-pixel

        ambient += SHEvalLinearL2 (half4(normal, 1.0));     // no max since this is only L2 contribution
    #endif

    return ambient;
}

half3 DD_ShadeSHPerPixel (half3 normal, half3 ambient, float3 worldPos)
{
    half3 ambient_contrib = 0.0;

    #if UNITY_SAMPLE_FULL_SH_PER_PIXEL
        // Completely per-pixel
        #if UNITY_LIGHT_PROBE_PROXY_VOLUME
            if (unity_ProbeVolumeParams.x == 1.0)
                ambient_contrib = SHEvalLinearL0L1_SampleProbeVolume(half4(normal, 1.0), worldPos);
            else
                ambient_contrib = SHEvalLinearL0L1(half4(normal, 1.0));
        #else
            ambient_contrib = SHEvalLinearL0L1(half4(normal, 1.0));
        #endif

            ambient_contrib += SHEvalLinearL2(half4(normal, 1.0));

            ambient += max(half3(0, 0, 0), ambient_contrib);

    #elif (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        // Completely per-vertex
        // nothing to do here. Gamma conversion on ambient from SH takes place in the vertex shader, see ShadeSHPerVertex.
    #else
        // L2 per-vertex, L0..L1 & gamma-correction per-pixel
        // Ambient in this case is expected to be always Linear, see ShadeSHPerVertex()
        #if UNITY_LIGHT_PROBE_PROXY_VOLUME
            if (unity_ProbeVolumeParams.x == 1.0)
                ambient_contrib = SHEvalLinearL0L1_SampleProbeVolume (half4(normal, 1.0), worldPos);
            else
                ambient_contrib = SHEvalLinearL0L1 (half4(normal, 1.0));
        #else
            ambient_contrib = SHEvalLinearL0L1 (half4(normal, 1.0));
        #endif

        ambient = max(half3(0, 0, 0), ambient+ambient_contrib);     // include L2 contribution in vertex shader before clamp.
    #endif

    return ambient;
}

inline DD_V2F_INDIRECT_T VertexGI(in half2 texcoord1, float3 posWorld, half3 normalWorld)
{
#ifdef LIGHTMAP_ON
	return texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#elif UNITY_SHOULD_SAMPLE_SH
    half3 sh = 0;
	#ifdef VERTEXLIGHT_ON
		sh = Shade4PointLights (
			unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
			unity_4LightAtten0, posWorld, normalWorld);
	#endif

	return DD_ShadeSHPerVertex(normalWorld, sh);
#endif
}

DDGIInput GIInputPrepare(DDLight mainlight, float3 worldPos, half3 viewDir, half3 normal, half4 i_ambientOrLightmapUV)
{
	DDGIInput giInput;
	giInput.light = mainlight;
	giInput.worldPos = worldPos;
	giInput.viewDir = viewDir;
	giInput.normalWorld = normal;
#ifdef LIGHTMAP_ON
	giInput.lmapUV = i_ambientOrLightmapUV;
	giInput.ambient = 0;
#else
	giInput.lmapUV = 0;
	giInput.ambient = i_ambientOrLightmapUV;
#endif
    giInput.probeHDR[0] = unity_SpecCube0_HDR;
    giInput.probeHDR[1] = unity_SpecCube1_HDR;
#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
	giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
#endif
#ifdef UNITY_SPECCUBE_BOX_PROJECTION
	giInput.boxMax[0] = unity_SpecCube0_BoxMax;
	giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
	giInput.boxMax[1] = unity_SpecCube1_BoxMax;
	giInput.boxMin[1] = unity_SpecCube1_BoxMin;
	giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
#endif
	return giInput;
}

void GI_IndirectDiffuse(half occlusion, in DDGIInput input, out DDGI gi)
{
	ResetGI(gi);
	half atten = input.light.atten;

    #if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
        half bakedAtten = UnitySampleBakedOcclusion(input.lmapUV.xy, input.worldPos);
        float zDist = dot(_WorldSpaceCameraPos - input.worldPos, UNITY_MATRIX_V[2].xyz);
        float fadeDist = UnityComputeShadowFadeDistance(input.worldPos, zDist);
        atten = UnityMixRealtimeAndBakedShadows(atten, bakedAtten, UnityComputeShadowFade(fadeDist));
    #endif

	gi.light = input.light;
	gi.light.atten = atten;

    #if UNITY_SHOULD_SAMPLE_SH
        gi.indirect.diffuse = DD_ShadeSHPerPixel(input.normalWorld, input.ambient, input.worldPos);
    #endif

    #if defined(LIGHTMAP_ON)
        // Baked lightmaps
        half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, input.lmapUV.xy);
        half3 bakedColor = DecodeLightmap(bakedColorTex);

        #ifdef DIRLIGHTMAP_COMBINED
            fixed4 bakedDirTex = UNITY_SAMPLE_TEX2D_SAMPLER (unity_LightmapInd, unity_Lightmap, input.lmapUV.xy);
            gi.indirect.diffuse += DecodeDirectionalLightmap (bakedColor, bakedDirTex, input.normalWorld);

            #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
                ResetLight(gi.light);
                gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap (gi.indirect.diffuse, atten, bakedColorTex, input.normalWorld);
            #endif

        #else // not directional lightmap
            gi.indirect.diffuse += bakedColor;

            #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
                ResetLight(gi.light);
                gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap(gi.indirect.diffuse, atten, bakedColorTex, input.normalWorld);
            #endif

        #endif
    #endif

	gi.indirect.diffuse *= occlusion;
}
inline half3 DD_DecodeHDR (half4 data, half4 decodeInstructions)
{
    // Take into account texture alpha if decodeInstructions.w is true(the alpha value affects the RGB channels)
    half alpha = decodeInstructions.w * (data.a - 1.0) + 1.0;

    // If Linear mode is not supported we can skip exponent part
    //#if defined(UNITY_COLORSPACE_GAMMA)
    //    return (decodeInstructions.x * alpha) * data.rgb;
    //#else
    #   if defined(UNITY_USE_NATIVE_HDR)
            return decodeInstructions.x * data.rgb; // Multiplier for future HDRI relative to absolute conversion.
    #   else
            return (decodeInstructions.x * pow(alpha, decodeInstructions.y)) * data.rgb;
    #   endif
    //#endif
}

half3 DD_GlossyEnvironment (UNITY_ARGS_TEXCUBE(tex), half4 hdr, Unity_GlossyEnvironmentData glossIn)
{
    half perceptualRoughness = glossIn.roughness /* perceptualRoughness */ ;

// TODO: CAUTION: remap from Morten may work only with offline convolution, see impact with runtime convolution!
// For now disabled
#if 0
    float m = PerceptualRoughnessToRoughness(perceptualRoughness); // m is the real roughness parameter
    const float fEps = 1.192092896e-07F;        // smallest such that 1.0+FLT_EPSILON != 1.0  (+1e-4h is NOT good here. is visibly very wrong)
    float n =  (2.0/max(fEps, m*m))-2.0;        // remap to spec power. See eq. 21 in --> https://dl.dropboxusercontent.com/u/55891920/papers/mm_brdf.pdf

    n /= 4;                                     // remap from n_dot_h formulatino to n_dot_r. See section "Pre-convolved Cube Maps vs Path Tracers" --> https://s3.amazonaws.com/docs.knaldtech.com/knald/1.0.0/lys_power_drops.html

    perceptualRoughness = pow( 2/(n+2), 0.25);      // remap back to square root of real roughness (0.25 include both the sqrt root of the conversion and sqrt for going from roughness to perceptualRoughness)
#else
    // MM: came up with a surprisingly close approximation to what the #if 0'ed out code above does.
    perceptualRoughness = perceptualRoughness*(1.7 - 0.7*perceptualRoughness);
#endif


    half mip = perceptualRoughnessToMipmapLevel(perceptualRoughness);
    half3 R = glossIn.reflUVW;
    half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(tex, R, mip);
#if defined(UNITY_COLORSPACE_GAMMA)
    rgbm.rgb = GammaToLinearSpace(rgbm.rgb);
#endif
    return DD_DecodeHDR(rgbm, hdr);
}

half3 GI_IndirectSpecular(half occlusion, half smoothness, in DDGIInput input)
{
    half3 specular = 0;

	Unity_GlossyEnvironmentData glossIn = UnityGlossyEnvironmentSetup(smoothness, input.viewDir,input.normalWorld, 0);

    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
        // we will tweak reflUVW in glossIn directly (as we pass it to Unity_GlossyEnvironment twice for probe0 and probe1), so keep original to pass into BoxProjectedCubemapDirection
        half3 originalReflUVW = glossIn.reflUVW;
        glossIn.reflUVW = BoxProjectedCubemapDirection (originalReflUVW, input.worldPos, input.probePosition[0], input.boxMin[0], input.boxMax[0]);
    #endif

    #ifdef _GLOSSYREFLECTIONS_OFF
        specular = unity_IndirectSpecColor.rgb;
    #else
        half3 env0 = DD_GlossyEnvironment (UNITY_PASS_TEXCUBE(unity_SpecCube0), input.probeHDR[0], glossIn);
        #ifdef UNITY_SPECCUBE_BLENDING
            const float kBlendFactor = 0.99999;
            float blendLerp = input.boxMin[0].w;
            UNITY_BRANCH
            if (blendLerp < kBlendFactor)
            {
                #ifdef UNITY_SPECCUBE_BOX_PROJECTION
                    glossIn.reflUVW = BoxProjectedCubemapDirection (originalReflUVW, input.worldPos, input.probePosition[1], input.boxMin[1], input.boxMax[1]);
                #endif

                half3 env1 = DD_GlossyEnvironment (UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0), input.probeHDR[1], glossIn);
                specular = lerp(env1, env0, blendLerp);
            }
            else
            {
                specular = env0;
            }
        #else
            specular = env0;
        #endif
    #endif

    return specular * occlusion;
}

#ifndef USE_CUSTOM_FUNC_GI
void Unity_GI(in SurfaceData_T s, in DDGIInput input, out DDGI gi)
{
    GI_IndirectDiffuse(s.Occlusion, input, gi);
#ifndef NO_NEED_INDIRECT_SPECULAR
    gi.indirect.specular = GI_IndirectSpecular(s.Occlusion, s.Smoothness, input);
#else
    gi.indirect.specular = 0;
#endif
}
#endif

#define VERTEX_GI VertexGI
#define FUNC_GIINPUT GIInputPrepare
#ifndef USE_CUSTOM_FUNC_GI
    #define FUNC_GI Unity_GI
#endif

#endif

#endif