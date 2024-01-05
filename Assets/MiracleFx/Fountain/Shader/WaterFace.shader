Shader "Unlit/WaterFace"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", color) = (1, 1, 1, 1)
        _Wave ("Wave", 2D) = "white" {}
        _Displace("Displacement", float) = 1
        _PolarRadius ("PolarRadius", float) = 1 
        _PolarAngle ("PolarAngle", float) = 1
        _PolarCenter ("PolarCenter", Range(0, 1)) = 0
        _OffsetSpeed ("OffsetSpeed", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
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
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _Wave;
            float4 _MainTex_ST, _Color;
            float _PolarAngle, _PolarRadius, _PolarCenter, _OffsetSpeed, _Displace;

            v2f vert (appdata v)
            {
                v2f o;
                float2 delta = v.uv - _PolarCenter;
                float radius = length(delta);
                float angle = atan2(delta.x, delta.y) * 1.0/6.28;
                float wave = tex2Dlod(_Wave, float4(float2(angle, radius + _Time.y * 0.1), 0, 0)).r;

                v.vertex += v.normal * wave * _Displace;
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float2 Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale)
            {
                float2 delta = UV - Center;
                float radius = length(delta) * 2 * RadialScale;
                float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
                return float2(radius, angle);
            }
            float2 Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation)
            {
                Rotation = Rotation * (3.1415926f/180.0f);
                UV -= Center;
                float s = sin(Rotation);
                float c = cos(Rotation);
                float2x2 rMatrix = float2x2(c, -s, s, c);
                rMatrix *= 0.5;
                rMatrix += 0.5;
                rMatrix = rMatrix * 2 - 1;
                UV.xy = mul(UV.xy, rMatrix);
                UV += Center;
                return UV;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uvRotate = Unity_Rotate_Degrees_float(i.uv, float2(0.5, 0.5), 180);
                float2 uvPolar1 = Unity_PolarCoordinates_float(i.uv, float2(_PolarCenter,_PolarCenter), _PolarRadius, _PolarAngle);
                float2 uvPolar2 = Unity_PolarCoordinates_float(uvRotate, float2(_PolarCenter,_PolarCenter), _PolarRadius, _PolarAngle);

                uvPolar1.x += _OffsetSpeed * _Time.y;
                uvPolar2.x += _OffsetSpeed * _Time.y;

                fixed4 col1 = tex2D(_MainTex, uvPolar1);
                fixed4 col2 = tex2D(_MainTex, uvPolar2);
                float mask = smoothstep(0.5, 0.6, i.uv.y);
                fixed4 col = lerp(col2, col1, mask);
                return col * _Color;
            }
            ENDCG
        }
    }
}
