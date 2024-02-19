Shader "MiracleFx/Particles/Trail/TrailScrollAdd"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Mask ("Mask", 2D) = "white" {}
        _BlurValue ("Blur", Range (0,1)) = 0
        _SpeedOffset ("Speed Offset", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
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
                float4 color : COLOR;
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 color : COLOR;
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Mask;
            float4 _Mask_ST;
            float _BlurValue;
            float _SpeedOffset;


            v2f vert (appdata v)
            {
                v2f o;
                o.color = v.color;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uv.z = v.uv.z;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float speedOffset = i.uv.z * _SpeedOffset;
                float4 particleCol = i.color;
                float v = i.uv.y + speedOffset;
                
                fixed4 mask = tex2D(_Mask, i.uv);
                fixed4 col = tex2D(_MainTex, float2 (i.uv.x, v));
                col.a = smoothstep(i.uv.z, i.uv.z + _BlurValue, col.a);

                return col *= particleCol * mask.a;
            }
            ENDCG
        }
    }
}
