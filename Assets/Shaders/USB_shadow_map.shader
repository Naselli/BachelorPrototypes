Shader "Unlit/USB_shadow_map"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        //shadow pass
        Pass
        {
            Name "Shadow Caster"
            Tags{
                "RenderType"="Opaque"
                "LightMode"="ShadowCaster"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCg.cginc"

            struct appdata{
            };

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert (appdata v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT (i)
            }
ENDCG
}


        //color pass
        Pass
        {

            Name "Shadow Map Texture"
            Tags{
                "RenderType"="Opaque"
                "LightMode"="Forwardbase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fwdbase nolightmap nodirlightmapnodynlightmap novertexlight

            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                //float2 uv : TEXCOORD0;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                SHADOW_COORDS(1)
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 NDCToUV(float4 clipPos){
                float4 uv = clipPos;
                #if defined(UNITY_HALF_TEXEL_OFFSET )
                    uv.xy = float2(uv.x, uv.y * _ProjectionParams.x) + uv.w *_ScreenParams.zw;
                #else
                    uv.xy = float2(uv.x, uv.y * _ProjectionParams.x) + uv.w;
                #endif
                uv.xy = float2(uv.x / uv.w, uv.y / uv.w) * 0.5;
                return uv;

            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                UNITY_TRANSFER_FOG(o,o.vertex);
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                fixed shadow = SHADOW_ATTENUATION(i);
                return col *= shadow;
            }
            ENDCG
        }
    }
}
