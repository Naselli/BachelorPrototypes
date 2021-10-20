Shader "USB/USB_simple_color"
{
    Properties
    {
         //Shader Properties
        _MainTex ("Texture", 2D) = "white" {}
        _Reflection ("Reflection", Cube) = "black" {}
        _3DTexture ("3D Texture", 3D) = "White" {}
        _Specular ("Specular", Range(0.0, 1.1)) = 0.3
        _Factor ("Color Factor", Float) = 0.3
        _Cid ("Color id", int) = 2
        _Color("Tint", Color) = (1,1,1,1)
        _VPos("Vertex Position", Vector) = (0,0,0,1)
        
        [Space(30)]
        //Material Property Drawers
        [Header(Material Property Drawers)]
        [Toggle] _Enable ("Enable ?", Float) = 0
        [KeywordEnum(Off, Red, Blue)] _Option ("Color Option", Float) = 0
        
        [PowerSlider(3.0)] _Brightness ("Brightness", Range(0.01, 1)) = 0.08
        [IntRange] _Samples ("Samples", Range(0,225)) = 100
        
        [Space(30)]
        [Header(Blend modes)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("SrcFactor", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("DstFactor", Float) = 1
        [Enum(Off, 0, Front, 1 , Back, 2)] _Face ("FaceCulling", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 0
    }
    SubShader
    {
        Tags { 
        //"RenderType"="Opaque" 
        //"Queue" = "Geometry"
        "RenderType" = "Transparent"
        "Queue" = "Transparent"
        }
        //Blend [_SrcBlend] [_DstBlend]
        ZWrite Off
        Blend OneMinusDstColor One 
        AlphaToMask On
        ColorMask RGB
        LOD 100
        Cull [_Cull]
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _ENABLE_ON
            #pragma multi_compile_fog
            #pragma multi_compile _OPTIONS_OFF _OPTIONS_RED _OPTIONS_BLUE

            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Brightness;
            int _Samples;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

void FakeLight_float (in float3 Normal, out float3 Out)
{
    float3 operation = Normal;
    Out = operation; 
}
            fixed4 frag (v2f i) : SV_Target
            {
                float3 n = i.normal;      // declare the normals. 
                 float3 col = 0;           // declare the output. 
            FakeLight_float (n, col); // pass both values ​​as arguments.

    return float4(col.rgb, 1);
                UNITY_APPLY_FOG(i.fogCoord, col);
                #if _OPTIONS_OFF
                return col;
                #elif _OPTIONS_RED
                return col * float4(1,0,0,1)
                #elif _OPTIONS_BLUE
                return col * float4(0,0,1,1)
                #endif
            }
            ENDCG
        }
    }
}
