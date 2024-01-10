Shader "Miracle/Unlit/Particles/StylizedExplosion/Explosion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Step("Step", Range(0, 1)) = 0
        _Color ("Color", color) = (1, 1, 1, 1)
        _TwirlStrength ("Twirl Strength", float) = 1
        _Scale ("Scale", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Blend SrcAlpha One
        Cull Off
        Zwrite Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST, _Color;
            float _TwirlStrength, _Scale;
            
            void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float Scale, float2 Offset, out float2 Out)
            {
                float2 delta = UV - Center;
                float angle = Strength * length(delta);
                float x = cos(angle) * delta.x - sin(angle) * delta.y;
                float y = sin(angle) * delta.x + cos(angle) * delta.y;
                x *= Scale;
                y *= Scale;
                Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 center = (0.5, 0.5);
                Unity_Twirl_float(i.uv, center, _TwirlStrength, _Scale, _MainTex_ST.zw, i.uv);

                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }
            ENDCG
        }
    }
}
