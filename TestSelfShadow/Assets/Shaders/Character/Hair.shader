Shader "DianDian/Hair"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Texture", 2D) = "white" {}
        [Normal]_NormalMap("Normal", 2D) = "bump" {}
        _HairMask("Hair Mask", 2D) = "white" {}
        [Space]
        _Glossiness("Smoothness Scale 1", Range(0.0, 1.0)) = 0.5
        _ShiftValue1("ShiftValue1", Range(-1.0,1.0)) = 0.0
        _SpecularColor1("SpecularColor1", Color) = (1,1,1,1)
        [Space]
        _Glossiness2("Smoothness Scale 2", Range(0.0, 1.0)) = 0.5
        _ShiftValue2("ShiftValue2", Range(-1.0,1.0)) = 0.0
        _SpecularColor2("SpecularColor2", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
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

            #include "HairLightModel.cginc"

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

            #include "HairLightModel.cginc"

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

            #include "HairLightModel.cginc"

            ENDCG
        }
    }
}
