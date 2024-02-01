Shader "Unlit/TwoFaceTex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TexOffsetSpeed ("TexOffset", float) = 1
        _DisappearTex ("DisappearTex", 2D) = "white" {}
        
        [Toggle] _Mask ("Mask", float) = 1
        
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlend ("SrcBlend", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DscBlend ("DscBlend", float) = 1
        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull ("Cull", Integer) = 1
        [Enum(Off, 0, On, 1)]
        _Zwrite("Zwrite", float) = 0

        _Col1 ("Color 1", color) = (1, 1, 1, 1)
        _Col2 ("Color 2", color) = (1, 1, 1, 1)

        _TexOffset ("TexOffset", float) = 1


    }
    SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull [_Cull]
        Zwrite Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma shader_feature _MASK_ON
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
                float uv_mask : TEXCOORD1;
                float4 color : COLOR;
                float2 uv_disappear : TEXCOORD2;
            };

            sampler2D _MainTex, _DisappearTex;
            float4 _MainTex_ST, _DisappearTex_ST, _Col1, _Col2;
            float _TexOffset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uv_disappear = TRANSFORM_TEX(v.uv.xy, _DisappearTex);
                o.uv_mask = v.uv;
                o.color = v.color;
                o.uv.z = v.uv.z;

                return o;
            }

            fixed4 frag (v2f i, half facing : VFACE) : SV_Target
            {
                float mask = smoothstep(0.2, 0.4, 1 - i.uv_mask.x);
                i.uv.x += _TexOffset * _Time.y;
                
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                fixed4 disappearTex = tex2D(_DisappearTex, i.uv_disappear);

                col = facing > 0 ? col * _Col1 : col * _Col2;

                #if _MASK_ON
                col.a *= mask;
                #else 
                col.a;
                #endif

                col.a *= step(i.uv.z, disappearTex.a);

                return col;

            }
            ENDCG
        }
    }
}
