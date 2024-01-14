Shader "Unlit/Magma"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white" {}


        _Color1 ("Color1", color) = (0, 0, 0, 0)
        _Color2 ("Color2", color) = (0, 0, 0, 0)
        _Layer ("Layer", Range(1, 5)) = 1
        _EdgeMask ("Edge Mask", float) = 0
        _Alpha ("Alpha", Range(0, 1)) = 0
     }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Blend SrcAlpha One
        Cull Back
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

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uvNoise : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float2 uvMask : TEXCOORD2;
            };

            sampler2D _MainTex, _Noise, _Mask;
            float4 _MainTex_ST, _Noise_ST, _Color1, _Color2;
            float _Layer, _EdgeMask, _Alpha;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvNoise = TRANSFORM_TEX(v.uv, _Noise);
                o.uvMask = v.uv;
                return o;
            }

            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float mask = smoothstep(_EdgeMask + 0.5, _EdgeMask, i.uvMask.x);

                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 noise = tex2D(_Noise, i.uvNoise);

                float alphaMask = noise.a + mask;
                
                col.a *= alphaMask;

                Unity_Remap_float(floor(col.a * _Layer) / _Layer, float2(0, 1), float2(0, 1), col.a);
               
                col = lerp(_Color1, _Color2, col.a);
                
                noise.a +=  mask;
                noise.a = step(_Alpha, noise.a);
                col.a *= noise.a;

                return col;
            }
            ENDCG
        }
    }
}
