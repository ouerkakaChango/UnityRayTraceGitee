Shader "Unlit/S_SDFSliceVisualize"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_SubInfo("SubInfo", Vector) = (0,0,0,0)
    }
    SubShader
    {
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

			float4 _SubInfo;

            float4 frag (v2f i) : SV_Target
            {
				float2 uv = i.uv;
				int edgeX = _SubInfo.x;
				int edgeY = _SubInfo.y;
				if (edgeX > 0 && edgeY > 0)
				{
					int subID = _SubInfo.z;
					int idx = subID % edgeX;
					int idy = (subID - idx) / edgeY;

					float2 cell = 1 / float2(edgeX, edgeY);
					float2 origin = float2(idx*cell.x, idy*cell.y);
					//localuv = (worlduv - origin) / cell;
					uv = uv * cell + origin;
				}

				float sdf = tex2D(_MainTex, uv).r;
				float4 re;
				if (abs(sdf) < 0.0001)
				{
					re = float4(0, 0, 0, 1);
				}
				else
				{
					re = 0;
				}
                return re;
            }
            ENDCG
        }
    }
}
