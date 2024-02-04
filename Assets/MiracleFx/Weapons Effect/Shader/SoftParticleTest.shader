Shader "Unlit/SoftParticleTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white" {}

        _FadeNear ("Fade Amount", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha One
        Zwrite Off
        Ztest Off
        Cull Off
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
                float4 color : COLOR;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
                float4 color : COLOR;
                float2 uv_noise : TEXCOORD2;


            };

            sampler2D _MainTex, _Noise;
            float4 _MainTex_ST, _Noise_ST;
            sampler2D _CameraDepthTexture;
            float _FadeNear;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uv_noise = TRANSFORM_TEX(v.uv.xy, _Noise);

                o.screenPos = ComputeScreenPos(o.vertex);
                o.color = v.color;
                o.uv.z = v.uv.z;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 screenPosUV = i.screenPos.xy / i.screenPos.w;
                float sceneDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenPosUV));
                float fade =  saturate(sceneDepth - _FadeNear - i.screenPos.w);

                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                fixed4 noise = tex2D(_Noise, i.uv_noise);
                noise.a = smoothstep(i.uv.z, i.uv.z + 0.3, noise.a);

                col.a *= fade * noise.a ;

                return col *2;
            }
            ENDCG
        }
    }
}
