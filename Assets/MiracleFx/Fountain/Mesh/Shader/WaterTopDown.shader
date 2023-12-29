Shader "Unlit/WaterTopDown"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white"  {}

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

            struct appdata
            {
                float3 normal : NORMAL;
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uvNoise : TEXCOORD1;
            };

            struct v2f
            {
                float3 normal : TEXCOORD2;
                float2 uv : TEXCOORD0;
                float2 uvNoise : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _Noise;
            float4 _MainTex_ST, _Noise_ST;

            v2f vert (appdata v)
            {
                v2f o;
                float noise = tex2Dlod(_Noise, float4(v.uvNoise, 0, 0)).r;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvNoise = TRANSFORM_TEX(v.uvNoise, _Noise);
                o.normal = normalize(mul(unity_ObjectToWorld, v.normal)) + noise;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
