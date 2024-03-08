Shader "Unlit/HLSL-Shader"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        
        [MainTexture]_BaseMap ("Base Texture", 2D) = "white" {}
        // The _BaseMap variable is visible in the Material's Inspector, as a field
        // called Base Map.

        [MainColor]_BaseColor ("Base Color", color) = (1, 1, 1, 1)
        // The _BaseColor variable is visible in the Material's Inspector, as a field
        // called Base Color. You can use it to select a custom color. This variable
        // has the default value (1, 1, 1, 1).
    }
    SubShader
    {
        // Tags { "RenderType"="Opaque" }
        Tag {"RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" "Queue"="Transparent"}
        // LOD 100

        Pass
        {
            Name "Forward"
            Tag { "LightMode"="UniversalForward" }
            // Used to render objects in the Forward rendering path. Renders geometry with lighting.
            Cull Off
            Zwrite On 
            Blend One One

            // CGPROGRAM
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #include "UnityCG.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


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

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap); // SAMPLER(sampler_linear_repeat_textureName);
            // sampler2D _MainTex;
            // float4 _MainTex_ST;

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            //float _ExampleFloat;
            CBUFFER_END
            // The CBUFFER must include all of the exposed properties 
            // (same as in the Shaderlab Properties block),
            //  except textures, though you still need to include
            // the texture tiling & offset values (e.g. _ExampleTexture_ST, 
            // where S refers to scale and T refers to translate) and TexelSize 
            // (e.g. _ExampleTexture_TexelSize) if they are used.
            
            v2f vert (appdata v)
            {
                v2f o;
                // If you need to sample a texture in the vertex shader, use the LOD version
                // to specify a mipmap (e.g. 0 for full resolution) :
                float4 color = SAMPLE_TEXTURE2D_LOD(textureName, sampler_textureName, uv, 0);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 color = SAMPLE_TEXTURE2D(textureName, sampler_textureName, uv);
                // Note, this can only be used in fragment as it calculates the mipmap level used.
                // fixed4 col = tex2D(_MainTex, i.uv);
                // return col;
            }
            // ENDCG
            ENDHLSL
        }
        // Pass{
             // Name "ShadowCaster"
             // Tag { "LightMode"="ShadowCaster"}
        //  Used for casting shadows
        
        // }
        // Pass{
            // Name "DepthOnly"
            // Tags { "LightMode"="DepthOnly" }
        // Used by the Depth Prepass to create the Depth Texture
        //  (_CameraDepthTexture) if MSAA is enabled or the platform 
        //  doesn’t support copying the depth buffer  
        // }
    }
    FallBack "Path/Name"
}
    // Some other texture type: 
    // // Texture2DArray
    // TEXTURE2D_ARRAY(textureName);
    // SAMPLER(sampler_textureName);
    // // ...
    // float4 color = SAMPLE_TEXTURE2D_ARRAY(textureName, sampler_textureName, uv, index);
    // float4 color = SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, sampler_textureName, uv, lod);

    // // Texture3D
    // TEXTURE3D(textureName);
    // SAMPLER(sampler_textureName);
    // // ...
    // float4 color = SAMPLE_TEXTURE3D(textureName, sampler_textureName, uvw);
    // float4 color = SAMPLE_TEXTURE3D_LOD(textureName, sampler_textureName, uvw, lod);
    // // uses 3D uv coord (commonly referred to as uvw)

    // // TextureCube
    // TEXTURECUBE(textureName);
    // SAMPLER(sampler_textureName);
    // // ...
    // float4 color = SAMPLE_TEXTURECUBE(textureName, sampler_textureName, dir);
    // float4 color = SAMPLE_TEXTURECUBE_LOD(textureName, sampler_textureName, dir, lod);
    // // uses 3D uv coord (named dir here, as it is typically a direction)

    // // TextureCubeArray
    // TEXTURECUBE_ARRAY(textureName);
    // SAMPLER(sampler_textureName);
    // // ...
    // float4 color = SAMPLE_TEXTURECUBE_ARRAY(textureName, sampler_textureName, dir, index);
    // float4 color = SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, sampler_textureName, dir, lod);