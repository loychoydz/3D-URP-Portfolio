Shader "Unlit/TextureDisappear"
{
    Properties
    {   
        [Header(Blend Mode)]
        [Space(5)]
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlend ("SrcBlend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend ("DstBlend", Float) = 1
        [Space(10)]
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Color ("Color", color) = (1, 1, 1, 1)
        
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend [_SrcBlend] [_DstBlend]
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
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST, _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uv.z = v.uv.z;
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                float alphaClip = step(i.uv.z, col.a);
                col.a *= alphaClip;
                col *= _Color;
                return col;
            }
            ENDCG
        }
    }
}
