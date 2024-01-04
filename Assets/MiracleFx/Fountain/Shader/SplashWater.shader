Shader "Unlit/SplashWater"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white" {}
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
                float4 color : COLOR;
                float3 uv : TEXCOORD0;
                float2 uvNoise : TEXCOORD1;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float2 uvNoise : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;

            };

            sampler2D _MainTex, _Noise;
            float4 _MainTex_ST, _Noise_ST;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uv.z = v.uv.z;
                o.uvNoise = TRANSFORM_TEX(v.uvNoise, _Noise);
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                fixed4 noise = tex2D(_Noise, i.uvNoise);
                
                col.a *= noise.a;
                noise.a = step(i.uv.z, noise.a);
                col.a *= noise.a;

                return col;
            }
            ENDCG
        }
    }
}
