Shader "DianDian/Skin-Pre Integrated_Kelemen"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        [Normal][NoScaleOffset]_BumpMap("Normal Map", 2D) = "bump" {}
        [NoScaleOffset]_MaskTex("MaskTex", 2D) = "white" {}
        _Smoothness("Smoothness", Range(0, 1)) = 0.47
        _SpecularScale("SpecularScale", Range(0,1)) = 0.26
        Curve("Curvature Source",Float) = 1
        _CurvatureFactor("CurveFactor",Range(0,5)) = 1

        [NoScaleOffset]_SkinLUT("Skin LUT", 2D) = "white"
        [NoScaleOffset]_KelemenLUT("Kelemen LUT", 2D) = "white"
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma target 3.5
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma shader_feature CURVE_REALTIME CURVE_TEX

            #include "SkinLightModel_Kelemen.cginc"

            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }

            Blend One One

            CGPROGRAM
            #pragma target 3.5
            #pragma vertex vertAdd
            #pragma fragment fragAdd
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fog
            #pragma shader_feature CURVE_REALTIME CURVE_TEX

            #include "SkinLightModel_Kelemen.cginc"

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

            #include "SkinLightModel_Kelemen.cginc"

            ENDCG
        }
    }

	CustomEditor "DDRenderPipeline.SkinShaderGUI"
}
