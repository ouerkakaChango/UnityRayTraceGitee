Shader "DianDian/PBR-Cartoon"
{
	Properties
	{
        _Color("Color", Color) = (0.5,0.5,0.5,1)
		_MainTex("MainTex", 2D) = "white" {}
		[Normal][NoScaleOffset]_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("BumpScale", float) = 1.0
		[NoScaleOffset]_MetallicGlossMap("Mask(R:Metallic)(G:Smoothness)(B:Occlusion)(A:Emission)", 2D) = "white" {}
		[Gamma]_Metallic("Metallic Scale", Range(0.0, 1.0)) = 0.0
		_Glossiness("Smoothness Scale", Range(0.0, 1.0)) = 0.5
		_OcclusionStrength("Occlusion Strength", Range(0.0, 1.0)) = 1.0
		_Emission("Emission", Color) = (0,0,0,1)

		_DiffuseLight_MidPoint("Light Mid Point", Range(-1, 1)) = 0.5
		_DiffuseLight_Blur("Light Blur", Range(0, 1)) = 0.5
		_BackColor("Back Color", Color) = (0, 0, 0, 1)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
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

			#define _NORMALMAP

			#define USE_PBR_BRDF2

			#include "CartoonSurface.cginc"

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

			#define _NORMALMAP

			#define USE_PBR_BRDF2

			#define LIGHT_ATTEN_SEPERATE

			#include "CartoonSurface.cginc"

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

			#include "CartoonSurface.cginc"

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

			#include "CartoonSurface.cginc"

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

			#define _NORMALMAP

			#define USE_PBR_BRDF3

			#include "CartoonSurface.cginc"

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

			#define _NORMALMAP

			#define USE_PBR_BRDF3

			#define LIGHT_ATTEN_SEPERATE

			#include "CartoonSurface.cginc"

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

			#include "CartoonSurface.cginc"

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

			#include "CartoonSurface.cginc"

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

			#define _NORMALMAP

			#define USE_LAMBERT

			#include "CartoonSurface.cginc"

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

			#define _NORMALMAP

			#define USE_LAMBERT

			#define LIGHT_ATTEN_SEPERATE

			#include "CartoonSurface.cginc"

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

			#include "CartoonSurface.cginc"

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

			#include "CartoonSurface.cginc"

			ENDCG
		}
	}
}