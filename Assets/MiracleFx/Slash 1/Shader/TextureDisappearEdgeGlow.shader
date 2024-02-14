Shader "Unlit/TextureDisappearEdgeGlow"
{
    Properties
    {
        [Header(Blend Mode)]
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor ("SrcBlend", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor ("DstBlend", float) = 1
        [Space(10)]
        _MainTex ("Texture", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white" {}
        [NoScaleOffset]_Mask ("Mask", 2D) = "white" {}

        [HDR]_EdgeCol ("Edge color", color) = (1, 1, 1, 1)

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Blend [_SrcFactor] [_DstFactor]
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
                float4 color : COLOR;   
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float2 uvNoise : TEXCOORD1;
                float2 uvMask : TEXCOORD2;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;   
            };

            sampler2D _MainTex, _Noise, _Mask;
            float4 _MainTex_ST, _Noise_ST, _Mask_ST, _EdgeCol;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uvNoise = TRANSFORM_TEX(v.uv, _Noise);
                o.uvMask = TRANSFORM_TEX(v.uv, _Mask);
                o.uv.z = v.uv.z;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                fixed4 noise = tex2D(_Noise, i.uvNoise);
                fixed4 mask = tex2D(_Mask, i.uvMask);

                noise.a = smoothstep(i.uv.z, i.uv.z + 0.1, noise.a);

                col.a *= noise.a;
                col.rgb = lerp(_EdgeCol.rgb,col.rgb, noise.a);
                col.a *= mask.a;

                return col;
            }
            ENDCG
        }
    }
}
