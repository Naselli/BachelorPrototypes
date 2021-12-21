Shader "Unlit/SimpleShader"
{
    Properties {
        //_MainTex ("Texture", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            

            //Mesh data: vertex position, vertex normal, UVs, tangents, vertex colors;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float4 normal : NORMAL;
                
                //float4 colors : COLOR;
                //float2 uv1 : TEXCOORD1;
                //float4 tangent : TANGENT;
            };

            struct VertexOutput {
                float4 clipSpacePos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

            //vertex shader
            VertexOutput vert ( VertexInput v   ) {
                VertexOutput o;
                o.uv0 = v.uv0;
                o.normal = v.normal;
                o.clipSpacePos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            //float -alot -> alot
            //fixed -1 -> 1
            //half  -32.000 -> 32.000
            float4 frag ( VertexOutput o ) : SV_Target {
                float2 uv = o.uv0;
                
                //Remapped normals
                float3 normal = o.normal / 2 + .5; //0 -> 1
                
                //float3 lightDir = normalize( float3( 1, 1, 1 ) );
                float3 lightColor = _LightColor0.rgb;
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                
                float lightFalloff = max( 0, dot( lightDir, o.normal ) );
                float3 diffuseLight = lightFalloff * lightColor;
                    
                float3 ambientLight = float3( .2, .2, .2 );
                
            return float4(  diffuseLight , 0 );
            
            }
            ENDCG
        }
    }
}
