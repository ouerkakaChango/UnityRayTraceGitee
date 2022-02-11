Shader "DianDian/PBR"
{
	Properties
	{
        _Color("Color", Color) = (0.5,0.5,0.5,1)
		_MainTex("MainTex", 2D) = "white" {}
		[Normal][NoScaleOffset]_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("BumpScale", float) = 1.0
		[NoScaleOffset]_MetallicGlossMap("Mask(R:Metallic)(G:Occlusion)(B:Smoothness)(A:Emission)", 2D) = "white" {}
		[Gamma]_Metallic("Metallic Scale", Range(0.0, 1.0)) = 0.0
		_Glossiness("Smoothness Scale", Range(0.0, 1.0)) = 0.5
		_OcclusionStrength("Occlusion Strength", Range(0.0, 1.0)) = 1.0
		_EmissionColor("Emission", Color) = (0,0,0,1)

		[Toggle]_Use_Detail("Use Detail", float) = 0
		[NoScaleOffset]_DetailMask("Detail Mask", 2D) = "white" {}
		_DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
        [Normal][NoScaleOffset]_DetailNormalMap("Normal Map", 2D) = "bump" {}
        _DetailNormalMapScale("Scale", Float) = 1.0

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        // Blending state
        [HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
		}

		LOD 300

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
			Cull Back
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma shader_feature_local _USE_DETAIL_ON
			#pragma multi_compile _ _USE_COLOR_SHADOW
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

			#define _NORMALMAP

			#define USE_PBR_BRDF2

			#include "UnityPBRSurface.cginc"

			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardAdd" }

            Blend [_SrcBlend] One
			ZWrite Off
			ZTest LEqual
			Cull Back

			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vertAdd
			#pragma fragment fragAdd
			#pragma multi_compile_fwdadd
			#pragma multi_compile_fog
			#pragma multi_compile_fwdadd_fullshadows
			#pragma shader_feature_local _USE_DETAIL_ON
			#pragma multi_compile _ _USE_COLOR_SHADOW
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

			#define _NORMALMAP

			#define USE_PBR_BRDF2

			#define LIGHT_ATTEN_SEPERATE

			#include "UnityPBRSurface.cginc"

			ENDCG
		}

		Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
			
			ZWrite On ZTest LEqual

			CGPROGRAM
			#pragma vertex vert_shadow
			#pragma fragment frag_shadow
			#pragma multi_compile_shadowcaster
			#pragma fragmentoption ARB_precision_hint_fastest
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

			#include "UnityPBRSurface.cginc"

			ENDCG
		}

		Pass
		{
			Name "META"
			Tags { "LightMode" = "Meta" }

			Cull Off

			CGPROGRAM
			#pragma vertex vert_meta
			#pragma fragment frag_meta

			#pragma shader_feature EDITOR_VISUALIZATION

			#define USE_PBR_BRDF2

			#include "UnityPBRSurface.cginc"

			ENDCG
		}
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
		}

		LOD 200

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
			Cull Back
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma shader_feature_local _USE_DETAIL_ON
			#pragma multi_compile _ _USE_COLOR_SHADOW
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

			#define _NORMALMAP

			#define USE_PBR_BRDF3

			#include "UnityPBRSurface.cginc"

			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardAdd" }

            Blend [_SrcBlend] One
			ZWrite Off
			ZTest LEqual
			Cull Back

			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vertAdd
			#pragma fragment fragAdd
			#pragma multi_compile_fwdadd
			#pragma multi_compile_fog
			#pragma multi_compile_fwdadd_fullshadows
			#pragma shader_feature_local _USE_DETAIL_ON
			#pragma multi_compile _ _USE_COLOR_SHADOW
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

			#define _NORMALMAP

			#define USE_PBR_BRDF3

			#define LIGHT_ATTEN_SEPERATE

			#include "UnityPBRSurface.cginc"

			ENDCG
		}

		Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
			
			ZWrite On ZTest LEqual

			CGPROGRAM
			#pragma vertex vert_shadow
			#pragma fragment frag_shadow
			#pragma multi_compile_shadowcaster
			#pragma fragmentoption ARB_precision_hint_fastest
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

			#include "UnityPBRSurface.cginc"

			ENDCG
		}

		Pass
		{
			Name "META"
			Tags { "LightMode" = "Meta" }

			Cull Off

			CGPROGRAM
			#pragma vertex vert_meta
			#pragma fragment frag_meta

			#pragma shader_feature EDITOR_VISUALIZATION

			#define USE_PBR_BRDF2

			#include "UnityPBRSurface.cginc"

			ENDCG
		}
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
		}

		LOD 100

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
			Cull Back
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma shader_feature_local _USE_DETAIL_ON
			#pragma multi_compile _ _USE_COLOR_SHADOW
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

			#define _NORMALMAP

			#define USE_LAMBERT

			#include "UnityPBRSurface.cginc"

			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardAdd" }

            Blend [_SrcBlend] One
			ZWrite Off
			ZTest LEqual
			Cull Back

			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vertAdd
			#pragma fragment fragAdd
			#pragma multi_compile_fwdadd
			#pragma multi_compile_fog
			#pragma multi_compile_fwdadd_fullshadows
			#pragma shader_feature_local _USE_DETAIL_ON
			#pragma multi_compile _ _USE_COLOR_SHADOW
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

			#define _NORMALMAP

			#define USE_LAMBERT

			#define LIGHT_ATTEN_SEPERATE

			#include "UnityPBRSurface.cginc"

			ENDCG
		}

		Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
			
			ZWrite On ZTest LEqual

			CGPROGRAM
			#pragma vertex vert_shadow
			#pragma fragment frag_shadow
			#pragma multi_compile_shadowcaster
			#pragma fragmentoption ARB_precision_hint_fastest
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

			#include "UnityPBRSurface.cginc"

			ENDCG
		}

		Pass
		{
			Name "META"
			Tags { "LightMode" = "Meta" }

			Cull Off

			CGPROGRAM
			#pragma vertex vert_meta
			#pragma fragment frag_meta

			#pragma shader_feature EDITOR_VISUALIZATION

			#define USE_PBR_BRDF2

			#include "UnityPBRSurface.cginc"

			ENDCG
		}
	}

	CustomEditor "DDRenderPipeline.PBRShaderGUI"
}