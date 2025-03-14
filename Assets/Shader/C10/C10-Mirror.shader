// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "C10/Mirror" {
	Properties 
    {
		_MainTex ("Main Tex", 2D) = "white" {}
	}
	SubShader 
    {
		Tags { "RenderType" = "Opaque" }
        Tags { "Queue" = "Geometry"}
		
		Pass 
        {
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
            #include "UnityCG.cginc"

			sampler2D _MainTex;
			
			struct appdata 
            {
				float4 vertex : POSITION;
				float3 texcoord : TEXCOORD0;
			};
			
			struct v2f 
            {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert(appdata v) 
            {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;

				// Mirror needs to filp x
				o.uv.x = 1 - o.uv.x;
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target 
            {
				return tex2D(_MainTex, i.uv);
			}
			ENDCG
		}
	} 
 	FallBack Off
}
