Shader "Miracle/Unlit/Mesh/Character"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DisappearValue ("DisappearValue", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry"}
        LOD 100
        Blend SrcAlpha One
        Cull Front
        Zwrite On

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
            };

            struct v2f
            {
                float3 normal : TEXCOORD4;
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 charPivot : TEXCOORD1;
                float3 charPos : TEXCOORD2;
                float3 charToWorld : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _DisappearValue;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.charPivot = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
                o.charToWorld = mul(unity_ObjectToWorld, v.vertex);
                o.charPos = o.charToWorld - o.charPivot;
                return o;
            }

            float Unity_Remap ( float In, float2 InMinMax, float2 OutMinMax)
            {
                float Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                return Out;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.charPos.y = Unity_Remap(i.charPos.y, float2 (-2, 2), float2 (0, 1));
                fixed4 col = tex2D(_MainTex, i.uv);

                float disappear = step(_DisappearValue, i.charPos.y);

                col.a = disappear;

                return col;
            }
            ENDCG
        }
    }
}
