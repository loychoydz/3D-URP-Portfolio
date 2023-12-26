Shader "Miracle/Unlit/Mesh/BulletTex"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlend ("Source Factor", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend ("Destination Factor", Float) = 1
        [Space(10)]
        _MainTex ("Texture", 2D) = "white" {}
        _Mask ("Mask", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white" {}
        [HDR]_Color ("Color", color) = (0,0,0,0)
        [Space(10)]
        _SpeedOffset ("MainOffset/XY + Noise/ZW", vector) = (0,0,0,0)
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
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uvNoise : TEXCOORD1;
                float2 uvMask : TEXCOORD2;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;

            };

            sampler2D _MainTex, _Mask, _Noise;
            float4 _MainTex_ST, _Mask_ST, _Noise_ST, _SpeedOffset, _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvMask = TRANSFORM_TEX(v.uv, _Mask);
                o.uvNoise = TRANSFORM_TEX(v.uv, _Noise);
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.uv.x += _SpeedOffset.x *_Time.y;
                i.uv.y += _SpeedOffset.y *_Time.y;
                i.uvNoise.x += _SpeedOffset.z *_Time.y;
                i.uvNoise.y += _SpeedOffset.w *_Time.y;



                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                fixed4 mask = tex2D(_Mask, i.uvMask);
                fixed4 noise = tex2D(_Noise, i.uvNoise);

                col.a *= mask.a * noise.a;

                return col * _Color;
            }
            ENDCG
        }
    }
}
