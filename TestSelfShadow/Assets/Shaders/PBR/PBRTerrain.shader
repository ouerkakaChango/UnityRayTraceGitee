//暂时不支持点光源实时阴影
Shader "DianDian/PBRTerrain"
{
	Properties
	{
		_Color("Color", Color) = (0.5,0.5,0.5,1)
		[KeywordEnum(NoSplat, SplatR, SplatRG, SplatRGB)] _DiffuseNum("Use SplatLayer", Float) = 0
		//--------------------------------------------------
		_Diffuse01("Diffuse01", 2D) = "white" {}
		[Normal]_NormalMap01("Normal Map01", 2D) = "bump" {}
		_NormalScale01("Normal Scale01", Range( 0 , 10)) = 1
		_MetallicGlossMap("Mask(R:Metallic)(G:Occlusion)(B:Emission)(A:Smoothness)", 2D) = "black" {}

		_Diffuse02("Diffuse02", 2D) = "white" {}
		[Normal]_NormalMap02("Normal Map02", 2D) = "bump" {}
		_NormalScale02("Normal Scale02", Range( 0 , 10)) = 1
		[NoScaleOffset]_MetallicGlossMap02("Mask 02", 2D) = "black" {}

		_Diffuse03("Diffuse03", 2D) = "white" {}
		[Normal]_NormalMap03("Normal Map03", 2D) = "bump" {}
		_NormalScale03("Normal Scale03", Range( 0 , 10)) = 1
		[NoScaleOffset]_MetallicGlossMap03("Mask 03", 2D) = "black" {}

		_Diffuse04("Diffuse04", 2D) = "white" {}
		[Normal]_NormalMap04("Normal Map04", 2D) = "bump" {}
		_NormalScale04("Normal Scale04", Range( 0 , 10)) = 1
		[NoScaleOffset]_MetallicGlossMap04("Mask 04", 2D) = "black" {}

		_Diffuse05("Diffuse05", 2D) = "white" {}
		[Normal]_NormalMap05("Normal Map05", 2D) = "bump" {}
		_NormalScale05("Normal Scale05", Range( 0 , 10)) = 1
		[NoScaleOffset]_MetallicGlossMap05("Mask 05", 2D) = "black" {}

		_SplatAlpha("SplatAlpha", 2D) = "black" {}
		_HeightBlendWeight("Height Blend Weight", Range(0.01, 1)) = 1

		//_Mask("Mask", 2D) = "white" {}
		//_FloatScale("Float Scale", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		//--------------------------------------------------
        
		//_MainTex("MainTex", 2D) = "white" {}
		//[NoScaleOffset]_BumpMap("Normal Map", 2D) = "bump" {}
		//_BumpScale("BumpScale", float) = 1.0
		_Metallic("Metallic Scale", Range(0.0, 1.0)) = 1.0
		_GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
		[HDR]_Emission("Emission", Color) = (0,0,0,1)

		[Toggle]_UseParallax("Use Parallax", Float) = 0
		_Parallax("Height Scale", Range(0, 0.08)) = 0.02

		_LightLimit("Light Limit", Range(0.0, 3.0)) = 1.5
		//_LightPower("Light Power", Range(0.0, 5.0)) = 1.0
		[KeywordEnum(On, Off)] _UseColorShadow("Use Color Shadow", Float) = 0
		[KeywordEnum(On, Off)] _DisableGIError("GI Standard Mode", Float) = 1
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
			"RenderType" = "Opaque"
			"DisableBatching" = "False"
		}

		LOD 300

		Pass
		{
			Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
			Blend One Zero
			ZWrite On
			Cull Back
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma shader_feature LIGHTMAP_OFF LIGHTMAP_ON
			
			#pragma shader_feature _DIFFUSENUM_NOSPLAT _DIFFUSENUM_SPLATR _DIFFUSENUM_SPLATRG _DIFFUSENUM_SPLATRGB
			#pragma shader_feature _USECOLORSHADOW_OFF
			//#pragma multi_compile _ _LIGHTMAP_OPT2_ON
			#pragma multi_compile _ LIGHTMAP_AS_AO
			
			#define USE_PBR_BRDF2
			#define _PARALLAX

			#include "TerrainSurface.cginc"

			ENDCG
		}

		Pass
		{
			Tags { "RenderType" = "Opaque" "LightMode" = "ForwardAdd" }

			Blend One One
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
			#pragma shader_feature _DIFFUSENUM_NOSPLAT _DIFFUSENUM_SPLATR _DIFFUSENUM_SPLATRG _DIFFUSENUM_SPLATRGB
			#pragma shader_feature _USECOLORSHADOW_OFF
											
			#define USE_PBR_BRDF2
		
			#define LIGHT_ATTEN_SEPERATE

			#include "TerrainSurface.cginc"

			ENDCG
		}

		Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
			Offset 1, 1
			
			ZWrite On ZTest LEqual

			CGPROGRAM
			#pragma vertex vert_shadow
			#pragma fragment frag_shadow
			#pragma multi_compile_shadowcaster
			#pragma fragmentoption ARB_precision_hint_fastest

			#include "TerrainSurface.cginc"

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

			#include "TerrainSurface.cginc"

			ENDCG
		}
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
			"RenderType" = "Opaque"
			"DisableBatching" = "False"
		}

		LOD 200

		Pass
		{
			Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
			Blend One Zero
			ZWrite On
			Cull Back
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma shader_feature LIGHTMAP_OFF LIGHTMAP_ON			
			#pragma shader_feature _DIFFUSENUM_NOSPLAT _DIFFUSENUM_SPLATR _DIFFUSENUM_SPLATRG _DIFFUSENUM_SPLATRGB
			#pragma shader_feature _USECOLORSHADOW_OFF
			//#pragma multi_compile _ _LIGHTMAP_OPT2_ON
			#pragma multi_compile _ LIGHTMAP_AS_AO
			
			#define USE_PBR_BRDF3

			#include "TerrainSurface.cginc"

			ENDCG
		}

		Pass
		{
			Tags { "RenderType" = "Opaque" "LightMode" = "ForwardAdd" }

			Blend One One
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
			#pragma shader_feature _DIFFUSENUM_NOSPLAT _DIFFUSENUM_SPLATR _DIFFUSENUM_SPLATRG _DIFFUSENUM_SPLATRGB
			#pragma shader_feature _USECOLORSHADOW_OFF
			
			#define USE_PBR_BRDF3

			#define LIGHT_ATTEN_SEPERATE

			#include "TerrainSurface.cginc"

			ENDCG
		}

		Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
			Offset 1, 1
			
			ZWrite On ZTest LEqual

			CGPROGRAM
			#pragma vertex vert_shadow
			#pragma fragment frag_shadow
			#pragma multi_compile_shadowcaster
			#pragma fragmentoption ARB_precision_hint_fastest

			#include "TerrainSurface.cginc"

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

			#include "TerrainSurface.cginc"

			ENDCG
		}
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
			"RenderType" = "Opaque"
			"DisableBatching" = "False"
		}

		LOD 100

		Pass
		{
			Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
			Blend One Zero
			ZWrite On
			Cull Back
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma shader_feature LIGHTMAP_OFF LIGHTMAP_ON			
			#pragma shader_feature _DIFFUSENUM_NOSPLAT _DIFFUSENUM_SPLATR _DIFFUSENUM_SPLATRG _DIFFUSENUM_SPLATRGB
			#pragma shader_feature _USECOLORSHADOW_OFF
			//#pragma multi_compile _ _LIGHTMAP_OPT2_ON
			#pragma multi_compile _ LIGHTMAP_AS_AO
			
			#define USE_LAMBERT

			#include "TerrainSurface.cginc"

			ENDCG
		}

		Pass
		{
			Tags { "RenderType" = "Opaque" "LightMode" = "ForwardAdd" }

			Blend One One
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
			#pragma shader_feature _DIFFUSENUM_NOSPLAT _DIFFUSENUM_SPLATR _DIFFUSENUM_SPLATRG _DIFFUSENUM_SPLATRGB
			#pragma shader_feature _USECOLORSHADOW_OFF
					
			#define USE_LAMBERT

			#define LIGHT_ATTEN_SEPERATE

			#include "TerrainSurface.cginc"

			ENDCG
		}

		Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
			Offset 1, 1
			
			ZWrite On ZTest LEqual

			CGPROGRAM
			#pragma vertex vert_shadow
			#pragma fragment frag_shadow
			#pragma multi_compile_shadowcaster
			#pragma fragmentoption ARB_precision_hint_fastest

			#include "TerrainSurface.cginc"

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

			#include "TerrainSurface.cginc"

			ENDCG
		}
	}

	CustomEditor "DDRenderPipeline.GroundShaderGUI"
}