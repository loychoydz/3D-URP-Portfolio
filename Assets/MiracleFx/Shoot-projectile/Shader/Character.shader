Shader "Miracle/Unlit/Mesh/Character"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _TintColor ("Tint Color", color) = (1, 0, 0, 0)
        [HDR]_FresnelCol ("Fresnel Color", color) = (1, 0, 0, 0)
        _FresnelPow ("Fresnel Power", Range(0.2, 3.0)) = 1
        [Space(10)]
        _DisappearValue ("DisappearValue", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags {"RenderType"="Opaque"}
        LOD 100
        // Blend SrcAlpha OneMinusSrcAlpha
        AlphaToMask On //Sử dụng để clip pixel theo Alpha
        Cull Off
        Zwrite On

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
                float3 normal : NORMAL;
                float4 color : COLOR;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 charPivot : TEXCOORD1;
                float3 vertexPos2World : TEXCOORD2;
                float3 vertex2World : TEXCOORD3;
                float3 normal_ToWorld : TEXCOORD4;
                float4 color : COLOR;
            };

            sampler2D _MainTex, _Mask;
            float4 _MainTex_ST, _TintColor, _FresnelCol, _EdgeCol;
            float _DisappearValue, _FresnelPow;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.charPivot = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
                o.vertex2World = mul(unity_ObjectToWorld, v.vertex);
                o.vertexPos2World = o.vertex2World - o.charPivot;
                o.normal_ToWorld = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz;
                o.color = v.color;
                return o;
            }

            float Unity_Remap ( float In, float2 InMinMax, float2 OutMinMax)
            {
                float Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                return Out;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Remap gia tri i.vertexPos2World.y ve 0 -> 1.
                i.vertexPos2World.y = Unity_Remap(i.vertexPos2World.y, float2(-2,2), float2(0,1));

                fixed4 col = tex2D(_MainTex, i.uv) * _TintColor;

                float3 viewDir = normalize(_WorldSpaceCameraPos - i.vertex2World);
                float3 fresnel = pow(1 -saturate(dot(i.normal_ToWorld, viewDir)), _FresnelPow) * _FresnelCol.xyz;
                col.a = 1 - step(_DisappearValue, i.vertexPos2World.y);
                col.rgb += fresnel;

                return col;
            }
            ENDCG
        }
    }
}
