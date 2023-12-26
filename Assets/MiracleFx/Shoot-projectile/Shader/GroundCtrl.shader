Shader "Miracle/Unlit/Particles/GroundCtrl"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_MainCol ("MainColor", color) = (0, 0, 0 , 0)

        _Mask ("Mask", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white" {}
        [Space(10)]
        [HDR]_EdgeCol ("EdgeColor", color) = (0, 0, 0 , 0)
        _EdgeThickness  ("Edge Thick", Range(0, 0.5)) = 0


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
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
                float2 uvNoise : TEXCOORD1;
                float4 color : COLOR;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float2 uvNoise : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;

            };

            sampler2D _MainTex, _Mask, _Noise;
            float4 _MainTex_ST, _Noise_ST, _EdgeCol, _MainCol;
            float _EdgeThickness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uvNoise =TRANSFORM_TEX(v.uvNoise, _Noise);
                o.uv.z = v.uv.z;
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                col.xyz *= _MainCol.xyz;
                fixed4 noise = tex2D(_Noise, i.uvNoise);
                fixed4 mask = tex2D(_Mask, i.uv);


               float edge = smoothstep(i.uv.z, i.uv.z + _EdgeThickness, mask.a * noise.a);
               col = lerp(_EdgeCol, col, edge);


                return col;
            }
            ENDCG
        }
    }
}
