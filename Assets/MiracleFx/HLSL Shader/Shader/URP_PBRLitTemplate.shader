Shader "Miracle/URPTemplates/PBRLitShaderExample" 
{
	
	Properties {

		[MainTexture] _BaseMap("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" {}
		[MainColor]   _BaseColor("Base Color", Color) = (1, 1, 1, 1)

		[Space(20)]
		[Toggle(_ALPHATEST_ON)] _AlphaTestToggle ("Alpha Clipping", Float) = 0
		_Cutoff ("Alpha Cutoff", Float) = 0.5

		[Space(20)]
		[Toggle(_SPECULAR_SETUP)] _MetallicSpecToggle ("Specular (if on), Metallic (if off)", Float) = 0
		[Toggle(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)] _SmoothnessSource ("Smoothness Source, Albedo Alpha (if on) vs Metallic (if off)", Float) = 0
		_Metallic("Metallic", Range(0.0, 1.0)) = 0
		_Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
		_SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
		[Toggle(_METALLICSPECGLOSSMAP)] _MetallicSpecGlossMapToggle ("Use Metallic/Specular Gloss Map", Float) = 0
		_MetallicSpecGlossMap("Specular or Metallic Map", 2D) = "black" {}
		[Space(10)]
		_LightSweepTex("LightSweep Tex", 2D) = "white" {}
		// Usually this is split into _SpecGlossMap and _MetallicGlossMap, but I find
		// that a bit annoying as I'm not using a custom ShaderGUI to show/hide them.

		[Space(20)]
		[Toggle(_NORMALMAP)] _NormalMapToggle ("Use Normal Map", Float) = 0
		[NoScaleOffset] _BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1

		// Not including Height (parallax) map in this example/template

		// Don't use Occulusion Map
		// [Space(20)]
		// [Toggle(_OCCLUSIONMAP)] _OcclusionToggle ("Use Occlusion Map", Float) = 0
		// [NoScaleOffset] _OcclusionMap("Occlusion Map", 2D) = "bump" {}
		// _OcclusionStrength("Occlusion Strength", Range(0.0, 1.0)) = 1.0

		[Space(20)]
		[Toggle(_EMISSION)] _Emission ("Emission", Float) = 0
		[HDR] _EmissionColor("Emission Color", Color) = (0,0,0)
		[NoScaleOffset]_EmissionMap("Emission Map", 2D) = "black" {}

		[Space(20)]
		[Toggle(_SPECULARHIGHLIGHTS_OFF)] _SpecularHighlights("Turn Specular Highlights Off", Float) = 0
		[Toggle(_ENVIRONMENTREFLECTIONS_OFF)] _EnvironmentalReflections("Turn Environmental Reflections Off", Float) = 0
		// These are inverted fom what the URP/Lit shader does which is a bit annoying.
		// They would usually be handled by the Lit ShaderGUI but I'm using Toggle instead,
		// which assumes the keyword is more of an "on" state.

		// Not including Detail maps in this template
	}
	SubShader {
		Tags {
			"RenderPipeline"="UniversalPipeline"
			"RenderType"="Opaque"
			"Queue"="Geometry"
		}

		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

		TEXTURE2D(_LightSweepTex);
		SAMPLER(sampler_LightSweepTex);

		CBUFFER_START(UnityPerMaterial)
		float4 _BaseMap_ST;
		float4 _BaseColor;
		float4 _EmissionColor;
		float4 _SpecColor;
		float4 _LightSweepTex_ST;
		float _Metallic;
		float _Smoothness;
		// float _OcclusionStrength;
		float _Cutoff;
		float _BumpScale;
		CBUFFER_END
		ENDHLSL

		Pass {
			Name "ForwardLit"
			Tags { "LightMode"="UniversalForward" }

			HLSLPROGRAM
			#pragma vertex LitPassVertex
			#pragma fragment LitPassFragment

			// ---------------------------------------------------------------------------
			// Keywords
			// ---------------------------------------------------------------------------

			// Material Keywords
			#pragma shader_feature_local _NORMALMAP
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
			#pragma shader_feature_local_fragment _EMISSION
			#pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
			#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			// #pragma shader_feature_local_fragment _OCCLUSIONMAP

			//#pragma shader_feature_local _PARALLAXMAP // v10+ only
			//#pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED // v10+ only
			// Note, for this template not supporting parallax/height mapping or detail maps

			//#pragma shader_feature_local _ _CLEARCOAT _CLEARCOATMAP // v10+ only, URP/ComplexLit shader

			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
			#pragma shader_feature_local_fragment _SPECULAR_SETUP
			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF

			// URP Keywords
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			// Note, v11 changes these to :
			// #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN

			// #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			// #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION // v10+ only (for SSAO support)
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING // v10+ only, renamed from "_MIXED_LIGHTING_SUBTRACTIVE"
			#pragma multi_compile _ SHADOWS_SHADOWMASK // v10+ only

			// Unity Keywords
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			// #pragma multi_compile_fog

			// Structs

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			struct Attributes {
				float4 positionOS	: POSITION;

				#ifdef _NORMALMAP
				float4 tangentOS 	: TANGENT;
				#endif

				float4 normalOS		: NORMAL;
				float2 uv		    : TEXCOORD0;
				float2 lightmapUV	: TEXCOORD1;
				float4 color		: COLOR;
			};

			struct Varyings {
				float4 positionCS 					: SV_POSITION;
				float2 uv		    				: TEXCOORD0;
				DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
				float3 positionWS					: TEXCOORD2;

				#ifdef _NORMALMAP
					half4 normalWS					: TEXCOORD3;    // xyz: normal, w: viewDir.x
					half4 tangentWS					: TEXCOORD4;    // xyz: tangent, w: viewDir.y
					half4 bitangentWS				: TEXCOORD5;    // xyz: bitangent, w: viewDir.z
				#else
					half3 normalWS					: TEXCOORD3;
				#endif

				// #ifdef _ADDITIONAL_LIGHTS_VERTEX
				// 	half4 fogFactorAndVertexLight	: TEXCOORD6; // x: fogFactor, yzw: vertex light
				// #else
				// 	half  fogFactor					: TEXCOORD6;
				// #endif

				// #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				// 	float4 shadowCoord 				: TEXCOORD7;
				// #endif

				float4 color						: COLOR;
				float2 uv_lightsweep : TEXCOORD6;
			};

			#include "PBRInput.hlsl"
			#include "PBRSurface.hlsl"

			// Vertex Shader

			Varyings LitPassVertex(Attributes IN) {
				Varyings OUT;

				VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);

				#ifdef _NORMALMAP
					VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz, IN.tangentOS);
				#else
					VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz);
				#endif

				OUT.positionCS = positionInputs.positionCS;
				OUT.positionWS = positionInputs.positionWS;

				half3 viewDirWS = GetWorldSpaceViewDir(positionInputs.positionWS);
				half3 vertexLight = VertexLighting(positionInputs.positionWS, normalInputs.normalWS);
				// half fogFactor = ComputeFogFactor(positionInputs.positionCS.z);
				
				#ifdef _NORMALMAP
					OUT.normalWS = half4(normalInputs.normalWS, viewDirWS.x);
					OUT.tangentWS = half4(normalInputs.tangentWS, viewDirWS.y);
					OUT.bitangentWS = half4(normalInputs.bitangentWS, viewDirWS.z);
				#else
					OUT.normalWS = NormalizeNormalPerVertex(normalInputs.normalWS);
					//OUT.viewDirWS = viewDirWS;
				#endif

				OUTPUT_LIGHTMAP_UV(IN.lightmapUV, unity_LightmapST, OUT.lightmapUV);
				OUTPUT_SH(OUT.normalWS.xyz, OUT.vertexSH);

				// #ifdef _ADDITIONAL_LIGHTS_VERTEX
				// 	OUT.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				// #else
				// 	OUT.fogFactor = fogFactor;
				// #endif

				// #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				// 	OUT.shadowCoord = GetShadowCoord(positionInputs);
				// #endif

				OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
				OUT.color = IN.color;
				float2 maxUV = float2(max(0,IN.positionOS.x), max(0,IN.positionOS.y));
				OUT.uv_lightsweep = TRANSFORM_TEX(IN.positionOS.xy / maxUV, _LightSweepTex);
				return OUT;
			}

			// Fragment Shader
			
			half4 LitPassFragment(Varyings IN) : SV_Target {
				
				// Setup SurfaceData
				SurfaceData surfaceData;
				InitializeSurfaceData(IN, surfaceData);

				// Setup InputData
				InputData inputData;
				InitializeInputData(IN, surfaceData.normalTS, inputData);

				//Fresnel

				// Declare Texture
				half4 lightsweep = SAMPLE_TEXTURE2D(_LightSweepTex, sampler_LightSweepTex, IN.uv_lightsweep);


				// Simple Lighting (Lambert & BlinnPhong)
				half4 color = UniversalFragmentPBR(inputData, surfaceData);

				// Fog
				// color.rgb = MixFog(color.rgb, inputData.fogCoord);
				//color.a = OutputAlpha(color.a, _Surface);
				// return color;
				return lightsweep;
			}
			ENDHLSL
		}
	}
}
