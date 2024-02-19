Shader "MiracleFx/FrozenExplosion/Particles/TextureAlphaCtrl"

{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Mask ("Mask", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white" {}

        _EdgeWidth ("Edge Width", Range(0,1)) = 1
        [HDR]_EdgeColor1 ("Edge Color 1", color) = (1, 0, 0, 0)
        [HDR]_EdgeColor2 ("Edge Color 2", color) = (1, 0, 0, 0)
        _EdgeColorSped ("Edge Col Speed", Range (1,5)) = 1 
        _DisappearValue ("Disappear Value", Range (0, 1)) = 0

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        LOD 100
        Blend SrcAlpha One
        Zwrite Off
        Cull Off
    

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
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 uvNoise : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _EdgeWidth;
            float4 _EdgeColor1;
            float4 _EdgeColor2;
            sampler2D _Mask;
            float4 _Mask_ST;
            float _EdgeColorSped;
            sampler2D _Noise;
            float4 _Noise_ST;
            float _DisappearValue;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uvNoise = TRANSFORM_TEX(v.uvNoise, _Noise);
                o.uv.z = v.uv.z;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float texcoorD0Z = 1 - i.uv.z; 

                   

                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 mask = tex2D(_Mask,i.uv);
                fixed4 noise = tex2D(_Noise, i.uvNoise);
                
                float edge = smoothstep( texcoorD0Z, texcoorD0Z + _EdgeWidth, mask.a * col.a * noise.a);
                // float edge = step( texcoorD0Z, mask.a * col.a * noise.a);

                edge *= col.a;
                float4 edgeCol = lerp(_EdgeColor1, _EdgeColor2, saturate(sin(_Time.y* _EdgeColorSped)));
                float4 mainCol = lerp(edgeCol, col, edge);

                return mainCol;
            }
            ENDCG
        }
    }
}
