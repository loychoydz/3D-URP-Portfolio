Shader "Unlit/Magma"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CellTex ("Cell Tex", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white" {}
        _TexOffset ("Main/XY Cell/ZW", vector) = (1, 1, 1, 1)
        _Color1 ("Color 1", color) = (1,1,1,1)
        _Color2 ("Color 2", color) = (1,1,1,1)
        _EdgeMask ("Edge" , Range(0, 2)) = 1
        _EdgeBot("EdgeBot" , Range(0, 1)) = 1
        _EdgeSide("EdgeSide" , Range(0, 0.2)) = 0
        _Shades ("Shades", Int) = 1
        _HoleSize("Hole Size", Range(0, 1)) = 1
        _Displacement("Displacement", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
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
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv_cell_tex : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float2 uvMask : TEXCOORD2;
                float4 normal : TEXCOORD3;
            };

            sampler2D _MainTex, _CellTex, _Noise;
            float4 _MainTex_ST, _CellTex_ST, _Color1, _Color2, _TexOffset, _Noise_ST;
            float _EdgeMask, _EdgeBot, _Shades, _HoleSize, _Displacement,
            _EdgeSide;

            v2f vert (appdata v)
            {
                v2f o;
                float noise = tex2Dlod(_Noise, float4(v.uv + 4 * _Time.x, 0, 0)).r;
                o.normal = normalize(v.normal);
                v.vertex += o.normal * noise * _Displacement;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_cell_tex = TRANSFORM_TEX(v.uv, _CellTex);
                o.uvMask = v.uv;
                return o;
            }

            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float mask = smoothstep(_EdgeMask, _EdgeMask + 0.3, i.uvMask.y);
                float edgeBot = smoothstep( _EdgeBot, _EdgeBot + 0.2, i.uvMask.y);
                float edgeL = smoothstep( _EdgeSide, _EdgeSide + 0.2, i.uvMask.x);
                float edgeR = smoothstep(_EdgeSide, _EdgeSide + 0.2, 1 - i.uvMask.x);

                float holeSize;
                Unity_Remap_float(sin(_Time.y), float2(-1, 1), float2(0.05,_HoleSize), holeSize);



                i.uv.y += _TexOffset.y * _Time.y;
                i.uv_cell_tex.y += _TexOffset.w * _Time.y;


                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 cellTex = tex2D(_CellTex, i.uv_cell_tex);

                edgeL = step(holeSize, col.a * cellTex.a * edgeL);
                edgeR = step(holeSize, col.a * cellTex.a * edgeR);

                float alpha = col.a * cellTex.a + mask;
                // Unity_Remap_float(alpha, float2(0, 2), float2(0,1), alpha);
                float alphaShades = floor(alpha * _Shades)/_Shades;

                col = lerp(_Color1, _Color2, alphaShades);
                col.a = step(holeSize, alpha * edgeBot);
                col.a = col.a * edgeL * edgeR;


                return col;
            }
            ENDCG
        }
    }
    // FallBack "VertexLit"
}
