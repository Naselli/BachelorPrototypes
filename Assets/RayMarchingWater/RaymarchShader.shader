Shader "Hidden/RaymarchShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "DistanceFunctions.cginc"

            sampler2D _MainTex;
            // Setup
            uniform sampler2D _CameraDepthTexture;
            uniform float4x4 _CamFrustum, _CamToWorld;
            uniform float _maxDistance;
            uniform int _maxIterations;
            uniform float _accuracy;
            // Color
            uniform fixed4 _groundColor;
            uniform fixed4 _sphereColor[8];
            uniform float _colorIntensity;
            // Light
            uniform float3 _lightDirection, _lightColor;
            uniform float  _lightIntensity;
            // Shadow
            uniform float2 _shadowDist;
            uniform float _shadowIntensity, _shadowPenumbra;
            // Reflection
            uniform int _reflectionCount;
            uniform float _reflectionIntensity;
            uniform float _envRefIntensity;
            uniform samplerCUBE _reflectionCube;
            // Ambient Occlusion
            uniform float _ambientOcclStepSize, _ambientOcclIntensity;
            uniform int _ambientOcclIterations;
            // SDF
            uniform float4 _sphere;
            uniform float _sphereSmooth;
            uniform float _degreeRotate;
            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ray : TEXCOORD1;
            };

            /*
            float BoxSphere(float3 position) 
            {
                float sphere1 = sdSphere(position - _sphere1.xyz, _sphere1.w);
                float box1 = sdRoundBox(position - _box1.xyz, _box1.www, _box1Round);
                float combine1 = opSS(sphere1, box1, _boxSphereSmooth);

                float sphere2 = sdSphere(position - _sphere2.xyz, _sphere2.w);
                float combine2 = opIS(sphere2, combine1, _sphereIntersectSmooth);

                return combine2;
            }
            */

            float3 rotateY(float3 v, float degree) {
                float rad = 0.01745322925 * degree;
                float cosY = cos(rad);
                float sinY = sin(rad);
                return float3(cosY * v.x - sinY * v.z, v.y, sinY * v.x + cosY * v.z);
            }

            float4 distanceField(float3 position) {
                /*float plane = sdPlane(position, float4(0, 1, 0, 0));
                float boxSphere1 = BoxSphere(position);
                return opU(plane, boxSphere1);*/
                //loat4 plane = float4(_groundColor.rgb , sdPlane(position, float4(0, 1, 0, 0)));
                float4 sphere = float4(_sphereColor[0].rgb ,sdSphere(position - _sphere.xyz, _sphere.w));
                for (int i = 1; i < 8; i++) {
                    float4 sphereAdd = float4(_sphereColor[i].rgb, sdSphere(rotateY(position, _degreeRotate*i) - _sphere.xyz, _sphere.w));
                    sphere = opUS(sphere, sphereAdd, _sphereSmooth);
                }
                return sphere;
            }

            float3 getNormal(float3 position) {
                const float2 offset = float2(0.001, 0.0);
                float3 normal = float3(
                    distanceField(position + offset.xyy).w - distanceField(position - offset.xyy).w,
                    distanceField(position + offset.yxy).w - distanceField(position - offset.yxy).w,
                    distanceField(position + offset.yyx).w - distanceField(position - offset.yyx).w);
                return normalize(normal);
            }

            float hardShadow(float3 rayOrigin, float3 rayDirection, float minDistTravelled, float maxDistTravelled) {
                for (float t = minDistTravelled; t < maxDistTravelled;) {
                    float h = distanceField(rayOrigin + rayDirection * t).w;
                    if (h < 0.001) {
                        return 0.0;
                    }
                    t += h;
                }

                return 1.0;
            }

            float softShadow(float3 rayOrigin, float3 rayDirection, float minDistTravelled, float maxDistTravelled, float k) {
                float result = 1.0;
                
                for (float t = minDistTravelled; t < maxDistTravelled;) {
                    float h = distanceField(rayOrigin + rayDirection * t).w;
                    if (h < 0.001) {
                        return 0.0;
                    }
                    result = min(result, k * h / t);
                    t += h;
                }

                return result;
            }

            float ambientOcclusion(float3 position, float3 normal) {
                float step = _ambientOcclStepSize;
                float ambientOccl = 0.0;
                float dist;

                for (int i = 1; i <=_ambientOcclIterations; i++) {
                    dist = step * i;
                    ambientOccl += max(0.0, (dist - distanceField(position + normal * dist).w) / dist);    
                }
                return (1.0 - ambientOccl * _ambientOcclIntensity);

            }

            float3 Shading(float3 position, float3 normal, fixed3 color) {
                float3 result;
                // Diffuse color
                color = color.rgb * _colorIntensity;
                // Directionnal light
                float3 light = (_lightColor * dot(-_lightDirection, normal) * 0.5 + 0.5) * _lightIntensity;
                
                //Shadows
                float shadow = softShadow(position, -_lightDirection, _shadowDist.x, _shadowDist.y, _shadowPenumbra) *0.5 + 0.5;
                shadow = max(0.0, pow(shadow, _shadowIntensity));

                // Ambient occlusio
                float ambient = ambientOcclusion(position, normal);
                result = color * light * shadow * ambient;

                return result;
            }

            bool raymarching(float3 rayOrigin, float3 rayDirection, float depth, float maxDistance, float maxIterations, inout float3 position, inout fixed3 dColor) {
                bool hit;

                float distanceTravelled = 0; // distance travelled along the ray direction

                // We loop through the iterations
                for (int i = 0; i < maxIterations; i++) {
                    if (distanceTravelled > maxDistance || distanceTravelled > depth) {
                        // Envrionment color
                        hit = false;
                        break;
                    }

                    position = rayOrigin + rayDirection * distanceTravelled;
                    // Check for hit in distanceField
                    float4 distance = distanceField(position);
                    if (distance.w < _accuracy) { // We have hit something
                        dColor = distance.rgb;
                        hit = true;
                        break;
                    }
                    distanceTravelled += distance.w;
                }

                return hit;
            }

            v2f vert (appdata v)
            {
                v2f o;
                half index = v.vertex.z;
                v.vertex.z = 0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.ray = _CamFrustum[(int)index].xyz;

                o.ray /= abs(o.ray.z);

                o.ray = mul(_CamToWorld, o.ray);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, i.uv).r);
                depth *= length(i.ray);
                fixed3 col = tex2D(_MainTex, i.uv);
                float3 rayDirection = normalize(i.ray.xyz);
                float3 rayOrigin = _WorldSpaceCameraPos;
                fixed4 result;
                float3 hitPosition;
                fixed3 dColor;
                
                bool hit = raymarching(rayOrigin, rayDirection, depth, _maxDistance, _maxIterations, hitPosition, dColor);

                if (hit) { // Hit
                    // Shading
                    float3 normal = getNormal(hitPosition);
                    float3 shading = Shading(hitPosition, normal, dColor);
                    result = fixed4(shading, 1);
                    result += fixed4(texCUBE(_reflectionCube, normal).rgb * _envRefIntensity * _reflectionIntensity, 0);
                    // Reflection
                    if (_reflectionCount > 0) {
                        rayDirection = normalize(reflect(rayDirection, normal));
                        rayOrigin = hitPosition + (rayDirection * 0.01);
                        hit = raymarching(rayOrigin, rayDirection, _maxDistance, _maxDistance * 0.5f, _maxIterations / 2, hitPosition, dColor);
                        if (hit) {
                            // Shading
                            float3 normal = getNormal(hitPosition);
                            float3 shading = Shading(hitPosition, normal, dColor);
                            result += fixed4(shading * _reflectionIntensity, 0);
                            if (_reflectionCount > 1) {
                                rayDirection = normalize(reflect(rayDirection, normal));
                                rayOrigin = hitPosition + (rayDirection * 0.01);
                                hit = raymarching(rayOrigin, rayDirection, _maxDistance, _maxDistance * 0.25f, _maxIterations / 4, hitPosition, dColor);
                                if (hit) {
                                    // Shading
                                    float3 normal = getNormal(hitPosition);
                                    float3 shading = Shading(hitPosition, normal, dColor);
                                    result += fixed4(shading * _reflectionIntensity * 0.5f, 0);

                                }

                            }
                        }
                    }
                }
                else { // Miss
                    result = fixed4(0, 0, 0, 0);
                }


                return fixed4(col* (1.0 - result.w) + result.xyz*result.w, 1.0);
            }
            ENDCG
        }
    }
}
