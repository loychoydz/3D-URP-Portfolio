Shader "Unlit/WaterTopDown"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white"  {}
        _Mask ("Mask", 2D) = "white" {}
        [Space(10)]
        _NoisePow ("NoisePow", Range(0, 0.5)) = 0
        _WaterSpeed ("Water/XY Noise/ZW", vector) = (0,0,0,0)
        _WaterCol ("WaterCol", color) = (1,1,1,1)
        _Disappear ("Disappear", Range(0,1)) = 0
    


    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha One
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
                float3 normal : NORMAL;
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uvNoise : TEXCOORD1;
                float2 uvMask :TEXCOORD3;
            };

            struct v2f
            {
                float3 normal : TEXCOORD2;
                float2 uv : TEXCOORD0;
                float2 uvNoise : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float2 uvMask :TEXCOORD3;
                float4 noiseTex : TEXCOORD4;

            };

            sampler2D _MainTex, _Noise, _Mask;
            float4 _MainTex_ST, _Noise_ST, _WaterSpeed, _WaterCol, _Mask_ST;
            float _NoisePow, _Disappear;

            v2f vert (appdata v)
            {
                v2f o;
                o.normal = normalize(mul(unity_ObjectToWorld, v.normal));
                v.uvNoise.x += _WaterSpeed.z * _Time.y;
                v.uvNoise.y += _WaterSpeed.w * _Time.y;

                o.uvNoise = TRANSFORM_TEX(v.uvNoise, _Noise);
                o.noiseTex = tex2Dlod(_Noise, float4(o.uvNoise, 0, 0));
                v.vertex.xyz += v.normal * o.noiseTex.x * _NoisePow;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvMask = TRANSFORM_TEX(v.uvMask, _Mask);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.uv.x += _WaterSpeed.x * _Time.y;
                i.uv.y += _WaterSpeed.y * _Time.y;

                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 mask = tex2D(_Mask, i.uvMask); 
                col *= _WaterCol;
                float disappearTex = smoothstep(_Disappear, _Disappear + 0.02, mask.a * i.noiseTex.a);
                col.a *= disappearTex;
                return col;
            }
            ENDCG
        }
    }
}
