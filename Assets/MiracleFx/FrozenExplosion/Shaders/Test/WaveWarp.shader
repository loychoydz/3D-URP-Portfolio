Shader "Unlit/WaveWarp"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Speed", float) = 1
        _CuongDo ("Cuong Do", float) = 1
        _Sequence ("Sequence", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off


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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Speed;
            float _CuongDo;
            float _Sequence;

            v2f vert (appdata v)
            {
                v2f o;
                float speed = _Speed * _Time.y;
                float waveX = v.vertex.x + sin(v.vertex.y + speed);
                float waveY = v.vertex.y + sin(v.vertex.x + speed  * _Sequence) * _CuongDo;

                o.vertex = UnityObjectToClipPos(float3(v.vertex.x, waveY, v.vertex.z));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
