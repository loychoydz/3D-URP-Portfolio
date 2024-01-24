Shader "Custom/CameraOpaqueTexture_example" {
	Properties{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Noise ("Noise", 2D) = "white" {}


		[HeaderHelpURL(Rendering)]
		[Enum(UnityEngine.Rendering.CullMode)] _Culling ("Cull Mode", Int) = 2
		[Enum(Off,0,On,1)] _ZWrite("ZWrite", Int) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Int) = 4

		[HeaderHelpURL(Blending)]
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend mode Source", Int) = 5 // SrcAlpha
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend mode Destination", Int) = 6 //OneMinusSrcAlpha
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Transparent+100" }

		Cull [_Culling]

        ZWrite [_ZWrite]
        ZTest [_ZTest]

        Blend [_BlendSrc] [_BlendDst]

		Pass{
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
				float4 screenPos : TEXCOORD1;
                float4 normal : TEXCOORD2;
			};
        
			fixed4 _Color;
			sampler2D _MainTex, _Noise;
			float4 _MainTex_ST;

			sampler2D _CameraOpaqueTexture;
			

			v2f vert (appdata v)
			{
				v2f o;
                o.normal = normalize(v.normal);
                float noise = tex2Dlod(_Noise, float4(v.uv + _Time.x, 0 ,0)).r;
                v.vertex += o.normal * noise;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D (_MainTex, i.uv) * _Color;

				float4 grabTex = tex2Dproj(_CameraOpaqueTexture, i.screenPos);

				fixed4 col;
				col.rgb = c.rgb * grabTex.rgb;
				col.a = c.a;
				return grabTex;
			}
			ENDCG
		} // Pass
	} // SubShader
}