Shader "C11/ScrollingBg"
{
    Properties
    {
        _MainTex ("Base Layer (RGB)", 2D) = "white" {}
		_DetailTex ("2nd Layer (RGB)", 2D) = "white" {}
		_ScrollSpeedA ("Base layer Scroll Speed", Float) = 0.1
		_ScrollSpeedB ("2nd layer Scroll Speed", Float) = 0.25
		_Multiplier ("Layer Multiplier", Float) = 0.75
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque"}
        Tags {"Queue" = "Geometry"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            sampler2D _DetailTex;
            float4 _MainTex_ST;
            float4 _DetailTex_ST;

            float _ScrollSpeedA;
            float _ScrollSpeedB;
            float _Multiplier;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) 
                    + frac(float2(_ScrollSpeedA, 0.0) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) 
                    + frac(float2(_ScrollSpeedB, 0.0) * _Time.y);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 firstLayer = tex2D(_MainTex, i.uv.xy);
				fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw);
				
				fixed4 color = lerp(firstLayer, secondLayer, secondLayer.a);
				color.rgb *= _Multiplier;
				
				return color;
            }
            ENDCG
        }
    }
    FallBack "VertexLit"
}
