// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "C7/TanSpcaeNormalMap"
{
    Properties
    {
        _Color ("Color Tint", Color ) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Bump Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Range(-1.5, 1.5)) = 0.0 
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tan : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // one float4 "uv" maintain two group of UV coordinate
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                // BiNormal
                float3 BiNormal = cross(normalize(v.normal), normalize(v.tan.xyz)) * v.tan.w;

                // Transform Matrix: O_Space to Tan_Space 
                // Build in Matrx: TANGENT_SPACE_ROTATION
                float3x3 Tan_Rotation = float3x3 (v.tan.xyz, BiNormal, v.normal);
                o.lightDir = mul(Tan_Rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(Tan_Rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 Tan_LightDir = normalize(i.lightDir);
                fixed3 Tan_ViewDir = normalize(i.viewDir);

                // get texel in Normal_Map, turn color back to normal vector
                fixed4 P_Normal = tex2D(_BumpMap, i.uv.zw);
                fixed3 Tan_Normal;

                // if not setting "Normal_Map"
                // Tan_Normal.xy = (P_Normal.xy *2 -1) * _BumpScale;
                // Tan_Normal.z = sqrt(1.0 - saturate(dot(Tan_Normal.xy, Tan_Normal.xy)));

                // setting correct and uusing Build in func:
                Tan_Normal = UnpackNormal(P_Normal);
                Tan_Normal.xy *= _BumpScale;
                Tan_Normal.z = sqrt(1.0 - saturate(dot(Tan_Normal.xy, Tan_Normal.xy)));

                // Light calculate
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(Tan_Normal, Tan_LightDir));
                fixed3 halfDir = normalize(Tan_LightDir + Tan_ViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb 
                                  * pow(max(0, dot(Tan_Normal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
