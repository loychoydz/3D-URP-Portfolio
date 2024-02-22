Shader "Unlit/TwoFaceTex"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlend ("SrcBlend", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DscBlend ("DscBlend", float) = 1
        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull ("Cull", Integer) = 1
        [Enum(Off, 0, On, 1)]
        _Zwrite("Zwrite", float) = 0
        [Space(10)]

        _MainTex ("Texture", 2D) = "white" {}
        _TexOffset ("TexOffset", float) = 1
        _Displacement("Displace Tex", 2D) = "white" {}
        _DisplacementAmount ("Displace Amount", Range(0, 1)) = 0.1
        _Mask ("Mask", 2D) = "white" {}
        _DisappearTex ("DisappearTex", 2D) = "white" {}
        [Space(10)]

        [HDR]_Col1 ("Color Front", color) = (1, 1, 1, 1)
        [HDR]_Col2 ("Color Back", color) = (1, 1, 1, 1)



    }
    SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull [_Cull]
        Zwrite On
        Ztest Less
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
                float4 color : COLOR;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float3 uv : TEXCOORD0;
                float2 uv_mask : TEXCOORD1;
                float2 uv_disappear : TEXCOORD2;
                float3 normal : TEXCOORD3;
                float2 uv_displacement : TEXCOORD4;
            };

            sampler2D _MainTex, _DisappearTex, _Mask, _Displacement;
            float4 _MainTex_ST, _DisappearTex_ST, _Displacement_ST, _Col1, _Col2;
            float _TexOffset, _DisplacementAmount;

            v2f vert (appdata v)
            {
                v2f o;
                o.normal = v.normal;
                o.uv_displacement = TRANSFORM_TEX(v.uv.xy, _Displacement);
                o.uv_displacement.x -=  4 * _Time.x;
                float displacement = tex2Dlod(_Displacement, float4(o.uv_displacement, 0, 0)).r;
                v.vertex.xyz += o.normal * displacement * _DisplacementAmount;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uv_disappear = TRANSFORM_TEX(v.uv.xy, _DisappearTex);
                o.uv_mask = v.uv.xy;
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i, half facing : VFACE) : SV_Target
            {
                i.uv.x += _TexOffset * _Time.y;
                
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                fixed4 mask = tex2D(_Mask, i.uv_mask);
                fixed4 disappearTex = tex2D(_DisappearTex, i.uv_disappear);

                col = facing > 0 ? col * _Col1 : col * _Col2;

                col.a *= step(i.uv.z, disappearTex.a);
                col.a *= mask.a;

                return col;

            }
            ENDCG
        }
    }
}
