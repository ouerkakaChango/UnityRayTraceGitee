Shader "Hidden/DianDian/PBRFallback"
{
	Properties
	{
		_Color("Color", Color) = (0.5,0.5,0.5,1)

		[KeywordEnum(Off, On)] _AlphaTest("Use Alpha Cutoff", Float) = 0
		_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

		[KeywordEnum(OFF, ON, PBR)] _NormalMap("Use Normal Map", Float) = 0
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
		}
	
		Pass
		{
			Name "Caster"
			Tags { "LightMode" = "ShadowCaster" }
			Offset 1, 1
			
			Fog {Mode Off}
			ZWrite On ZTest LEqual Cull Back
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature _ALPHATEST_ON
			#pragma multi_compile_shadowcaster
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex : POSITION;
			#ifdef _ALPHATEST_ON
				half4 texcoord : TEXCOORD0;
			#endif
			};
			
			struct v2f {
				V2F_SHADOW_CASTER;
			#ifdef _ALPHATEST_ON
				float2  uv : TEXCOORD1;
			#endif
			};
			
			uniform sampler2D _MainTex;
			uniform fixed _Cutoff;
			
			v2f vert(a2v v)
			{
				v2f o;
			#ifdef _ALPHATEST_ON
				o.uv = v.texcoord.xy;
			#endif
				TRANSFER_SHADOW_CASTER(o)
				return o;
			}

			float4 frag(v2f i) : COLOR
			{
			#ifdef _ALPHATEST_ON
				fixed4 texcol = tex2D(_MainTex, i.uv);
				clip(texcol.a - _Cutoff);
			#endif

				SHADOW_CASTER_FRAGMENT(i)
			}
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
	
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature EDITOR_VISUALIZATION
	
			#include "UnityStandardMeta.cginc"
			ENDCG
		}
	}
}