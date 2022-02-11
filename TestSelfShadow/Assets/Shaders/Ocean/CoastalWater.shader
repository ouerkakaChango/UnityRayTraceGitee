Shader "DianDian/Ocean/Coastalwater"
{
    Properties
    {
        _MaxWaterDepth("Max Water Depth", Range(0.1, 1000)) = 500

        [HideInInspector]_RefractionIntensity("Refraction Intensity", Range(0, 2)) = 1
        [HideInInspector]_RefractionDistortion("Refraction Distortion", Range(0, 4)) = 0.5

        [HideInInspector]_SubSurfaceColor("Color", Color) = (0.0, 0.48, 0.36)
        [HideInInspector]_SubSurfaceBase("Base Mul", Range(0.0, 4.0)) = 1.0
        [HideInInspector]_SubSurfaceSun("Sun Mul", Range(0.0, 10.0)) = 4.5
        [HideInInspector]_SubSurfaceSunFallOff("Sun Fall-Off", Range(1.0, 16.0)) = 5.0

        _ShorelineFoamMinDepth("Shoreline Foam Min Depth", Range(0.01, 5.0)) = 0.27
        _FoamTexture("Foam", 2D) = "white"
        _FoamEdge("Foam Edge", Float) = 0
        _FoamSpeed("Foam Move Speed", Float) = 1
        _FoamUVScale("Foam UV Scale", Float) = 1

        _FoamNoise("Foam Noise", 2D) = "white"
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        GrabPass{}

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            ZWrite Off
            CGPROGRAM
            #pragma target 3.5
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #include "CoastalWaterLightModel.cginc"

            ENDCG
        }
    }
}
