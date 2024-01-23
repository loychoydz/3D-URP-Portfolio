Shader "Unlit/TwoFaceTex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Col1 ("Color 1", color) = (1, 1, 1, 1)
        _Col2 ("Color 2", color) = (1, 1, 1, 1)


    }
    SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        Zwrite Off
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float uv_mask : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST, _Col1, _Col2;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_mask = v.uv;

                return o;
            }

            fixed4 frag (v2f i, half facing : VFACE) : SV_Target
            {
                float mask = smoothstep(0.2, 0.4, 1 - i.uv_mask.x);
                i.uv.x += _Time.y;
                fixed4 col = tex2D(_MainTex, i.uv);
                col = facing > 0 ? col * _Col1 : col * _Col2;
                col.a *= mask;
                return col;
            }
            ENDCG
        }
    }
}
