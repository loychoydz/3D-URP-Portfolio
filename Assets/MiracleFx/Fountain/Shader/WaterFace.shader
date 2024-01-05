Shader "Unlit/WaterFace"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
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
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // float2 uv = v.uv - 0.5;
                // float uvRadius = length(uv);
                // float uvAngle = atan2(uv.x, uv.y);
                // o.uv = TRANSFORM_TEX(float2(uvRadius, uvAngle), _MainTex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float2 Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale)
            {
                float2 delta = UV - Center;
                float radius = length(delta) * 2 * RadialScale;
                float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
                return float2(radius, angle);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // i.uv.x += -1 *  _Time.y;
                float2 uvPolar = Unity_PolarCoordinates_float(i.uv, float2(0.5, 0.5), 1, 1);
                fixed4 col = tex2D(_MainTex, uvPolar);
                return col;
            }
            ENDCG
        }
    }
}
