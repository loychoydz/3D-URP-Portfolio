Shader "Unlit/Magma-tut"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CellTex ("CellTex", 2D) = "white" {}
        _TexOffset ("Main/XY Cell/ZW", vector) = (0, 0, 0, 0)
        [Space(10)]
        _Noise ("Noise", 2D) = "white" {}
        _Displacement ("Displacement", float) = 1

        [Space(10)]
        _Color1 ("Color 1", color) = (1, 1, 1, 1)
        _Color2 ("Color 2", color) = (1, 1, 1, 1)
        _Shades ("Shades", Range(0.01, 10)) = 1
        [Space(10)]
        _MaskEdge ("Mask Edge", Range(0, 1)) = 0
        _EdgeBot ("EdgeBot", Range(0, 1)) = 0
        _EdgeSide ("EdgeSide", Range(0, 1)) = 0
        _HoleSize ("Hole Size", Range (0, 0.5)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
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
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 uvCellTex : TEXCOORD1;
                float2 uvMask : TEXCOORD2;
                float4 normal : TEXCOORD3;
            };

            sampler2D _MainTex, _CellTex, _Noise;
            float4 _MainTex_ST, _CellTex_ST, _Color1, _Color2, _TexOffset, _Noise_ST;
            float _MaskEdge, _Shades, _EdgeBot, _HoleSize, _EdgeSide,
            _Displacement;

            v2f vert (appdata v)
            {
                v2f o;
                float noise = tex2Dlod(_Noise, float4(v.uv.y + _Time.x * 4, v.uv.y, 0, 0)).r;
                o.normal = normalize(v.normal);
                v.vertex += o.normal * noise * _Displacement;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvCellTex = TRANSFORM_TEX(v.uv, _CellTex);
                o.uvMask = v.uv;
                return o;
            }

            float Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax)
            {
                return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float mask = smoothstep(_MaskEdge, _MaskEdge + 0.3, i.uvMask.y);
                float edgeBot = smoothstep(_EdgeBot, _EdgeBot + 0.2, i.uvMask.y);
                float edgeL = smoothstep(_EdgeSide, _EdgeSide + 0.2, i.uvMask.x);
                float edgeR = smoothstep(_EdgeSide, _EdgeSide + 0.2, 1 - i.uvMask.x);


                float holeSize = Unity_Remap_float4(sin(_Time.y), float2 (-1 ,1), float2(0.05, _HoleSize));
                i.uv.y += _Time.y * _TexOffset.y;
                i.uvCellTex. y += _Time.y * _TexOffset.w;


                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 cellTex = tex2D(_CellTex, i.uvCellTex);

                edgeL = step(holeSize, col.a * cellTex.a * edgeL);
                edgeR = step(holeSize, col.a * cellTex.a * edgeR);

                float alpha = col.a * cellTex.a + mask;
                float alphaShades = floor(alpha * _Shades) / _Shades;

                col = lerp(_Color2, _Color1, alphaShades);
                col.a = step(holeSize, alpha * edgeBot);
                col.a *= edgeL * edgeR;

                return col;
            }
            ENDCG
        }
    }
}
