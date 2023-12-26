Shader "Miracle/Unlit/Particles/CubeSparks"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        _EmissTex ("EmissTex", 2D) = "white" {}
        [HDR] _EmissCol ("Emiss Color", color) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        // Blend SrcAlpha One
        Cull Off
        Zwrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 color : COLOR;
                float4 vertex : POSITION;              
                float3 uvEmissTex : TEXCOORD0;
            };

            struct v2f
            {
                float4 color : COLOR;     
                float4 vertex : SV_POSITION;
                float3 uvEmissTex : TEXCOORD0;
            };

            // sampler2D _MainTex;
            sampler2D _EmissTex;
            float4 _EmissTex_ST, _EmissCol;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvEmissTex.xy = TRANSFORM_TEX(v.uvEmissTex.xy, _EmissTex);
                o.color = v.color;
                o.uvEmissTex.z = v.uvEmissTex.z;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 emisstex = tex2D(_EmissTex, i.uvEmissTex);
                fixed4 col = i.color;
                emisstex *= _EmissCol;
                col.rgb *= col.rgb * i.uvEmissTex.z * emisstex.rgb;

                return col;
                
            }
            ENDCG
        }
    }
}
