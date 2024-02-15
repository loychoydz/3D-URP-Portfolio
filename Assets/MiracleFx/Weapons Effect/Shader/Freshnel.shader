Shader "Unlit/Freshnel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white" {}
        _NoiseSpeed ("NoiseSpeed", Range(-5,5)) = 0.5
        _FreshnelPow ("Freshnel Pow", Range( 0, 5)) = 1 
        [HDR]_FreshnelCol ("Freshnel Col", color) = (1, 1, 1, 1)
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
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float2 uv_noise : TEXCOORD3;
                float3 vertex_world: TEXCOORD4;
            };

            sampler2D _MainTex, _Noise;
            float4 _MainTex_ST, _Noise_ST, _FreshnelCol;
            float _FreshnelPow, _NoiseSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_noise = TRANSFORM_TEX(v.uv, _Noise);
                o.normal = normalize(mul(unity_ObjectToWorld, float4(v.normal,0))).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos - o.vertex_world);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float freshnel = pow(1 - saturate(dot(i.viewDir, i.normal)), _FreshnelPow);

                i.uv_noise.y -= _NoiseSpeed * _Time.y;

                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 noise = tex2D(_Noise, i.uv_noise);


                col = lerp(col, _FreshnelCol, freshnel * noise.a );



                return col;
            }
            ENDCG
        }
    }
    Fallback "VertexLit"
}
