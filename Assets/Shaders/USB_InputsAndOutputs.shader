Shader "Unlit/USB_InputsAndOutputs"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
        
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                //more optimised in vertex shader bcuz its caculated by vertices not pixels on screen
                o.normal = normalize(mul(unity_ObjectToWorld, float4(v.normal,0))).xyz; 
                return o;
            }
            
            void unity_light (in float3 normals, out float3 Out){
                Out =  (normals);
            }

            half3 normalWorld(half3 normal){
                return normalize(mul(unity_ObjectToWorld, float4(normal,0))).xyz;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 normals = i.normal; //normals local space code but is already converted to worldspace in vertex shader
                //half3 normals = normalWorld(i.normal); //normals world space
                half3 light = 0;
                unity_light(normals, light);
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return float4(light.rgb, 1);
            }
            ENDCG
        }
    }
}
