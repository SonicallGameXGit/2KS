// World layer
#version 130

#include "/lib/properties.glsl"
#include "/lib/shadow.glsl"
#include "/lib/noise.glsl"

const float sunPathRotation = 45.0;
const bool shadowHardwareFiltering = true;
const bool shadowtex0MipmapEnabled = true;

varying vec2 coord0;

uniform sampler2D texture, colortex3, depthtex0;
uniform mat4 gbufferModelView, gbufferProjection;
uniform int isEyeInWater;

#ifdef FOG_ENABLED
    uniform vec3 cameraPosition, previousCameraPosition;
    uniform vec3 fogColor, skyColor;
    uniform float frameTimeCounter, aspectRatio;
#endif

#if defined(SHADOWS_ENABLED) || defined(FOG_ENABLED)
    uniform mat4 gbufferProjectionInverse, gbufferModelViewInverse;
    uniform float far;
#endif
#ifdef SHADOWS_ENABLED
    // For some fucking reason OptiFine gives me fucking black screen because it's crap preprocessor unable to handle direct #define value usage
    #if SHADOWS_QUALITY == 512
        const int shadowMapResolution = 512;
    #elif SHADOWS_QUALITY == 1024
        const int shadowMapResolution = 1024;
    #elif SHADOWS_QUALITY == 2048
        const int shadowMapResolution = 2048;
    #elif SHADOWS_QUALITY == 4096
        const int shadowMapResolution = 4096;
    #elif SHADOWS_QUALITY == 8192
        const int shadowMapResolution = 8192;
    #else
        #error "Invalid SHADOWS_QUALITY value"
    #endif

    uniform sampler2D colortex1;
    uniform sampler2DShadow shadowtex0;
    uniform vec3 sunPosition, moonPosition;
    uniform mat4 shadowModelView, shadowProjection;
#else
    const int shadowMapResolution = 0;
#endif

void main() {
    #ifdef NO_POSTPROCESSING
        gl_FragData[0] = texture2D(texture, coord0);
        return;
    #endif
    gl_FragData[0] = texture2D(texture, coord0);

    float depth = texture2D(depthtex0, coord0).r;
    #if defined(SHADOWS_ENABLED) || defined(FOG_ENABLED)
        vec3 NDCPos = vec3(coord0, depth) * 2.0 - 1.0;
        vec4 viewPos = gbufferProjectionInverse * vec4(NDCPos, 1.0);
        viewPos.xyz /= viewPos.w;
        vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos.xyz, 1.0)).xyz;
    #endif

    if (depth >= 1.0) {
        return;
    }

    vec3 emissiveColor = texture2D(colortex3, coord0).rgb;
    float emission = max(dot(emissiveColor, vec3(0.333)), 0.0);

    #ifdef SHADOWS_ENABLED
        vec3 normal = texture2D(colortex1, coord0).rgb * 2.0 - 1.0;
        float sunNormalProduct = max(dot(normal, (gbufferModelViewInverse * vec4(sunPosition * 0.01, 1.0)).xyz), 0.0);
        float moonNormalProduct = max(dot(normal, (gbufferModelViewInverse * vec4(moonPosition * 0.01, 1.0)).xyz), 0.0);
        vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
        vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
        shadowClipPos.z -= max(0.001 * (sunNormalProduct + moonNormalProduct), 0.0001);
        shadowClipPos.xyz = distort(shadowClipPos.xyz);
        vec3 shadowNDCPos = shadowClipPos.xyz / shadowClipPos.w;
        vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;

        float shadow = 0.0;
        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
                shadow += texture(shadowtex0, shadowScreenPos + vec3(float(x), float(y), 0.0) / float(SHADOWS_QUALITY));
            }
        }
        shadow /= 9.0;
        shadow *= min(sunNormalProduct + moonNormalProduct, 1.0);
        #ifdef FOG_ENABLED
            shadow = mix(0.5, shadow, pow(FOG_DISTANCE - 0.1, 0.6));
        #endif

        gl_FragData[0].rgb = mix(
            gl_FragData[0].rgb * mix(emissiveColor.rgb, vec3(emission), pow(1.0 - emission, 0.3)),
            mix(
                gl_FragData[0].rgb,
                gl_FragData[0].rgb * (shadow * SHADOWS_STRENGTH + (1.0 - SHADOWS_STRENGTH)),
                (1.0 - clamp(length(viewPos.xyz) / far * 4.0, 0.0, 1.0))
            ),
            1.0 - emission
        );
    #endif

    #ifdef FOG_ENABLED
        vec3 finalFogColor = skyColor * 0.7;
        float fogDensityModifier = 1.0;
        float fogDistanceModifier = 1.0;
        vec3 viewVector = (gbufferModelView * vec4(0.0, 0.0, 1.0, 0.0)).xyz;

        switch (isEyeInWater) {
            case 0: break;
            case 1: { // Water
                finalFogColor *= fogColor * 1.5;
                finalFogColor = mix(finalFogColor, vec3(0.1, 0.6, 0.2), (snoise(vec3(coord0, frameTimeCounter * 0.2) + viewVector * 0.5 + 0.5) * 0.5 + 0.5) * 0.4);
                finalFogColor = mix(finalFogColor, vec3(0.2, 0.3, 0.1), (snoise(vec3(coord0, frameTimeCounter * 0.321) + viewVector * 0.5 + 0.5 + vec3(0.2342, -3.234, 12.2931)) * 0.5 + 0.5) * 0.4);
                gl_FragData[0].rgb = mix(gl_FragData[0].rgb, finalFogColor, 0.2);

                vec2 texcoord = coord0;
                texcoord.x *= aspectRatio;
                float dust = snoise(vec3(texcoord * 64.0, fract(frameTimeCounter * 1.2 / 4.0) * 4.0 + abs(viewVector.x) + abs(viewVector.y) + abs(viewVector.z)) + length(cameraPosition - previousCameraPosition) * 32.0) * 0.5 + 0.5;
                dust *= (snoise(vec3(texcoord * 39.0, fract(frameTimeCounter * 1.342 / 4.0) * 4.0 + (abs(viewVector.x) + abs(viewVector.y) + abs(viewVector.z)) * 4.0 + abs(length(cameraPosition - previousCameraPosition)) * 32.0)) * 0.5 + 0.5);
                dust = smoothstep(0.0, 0.04, dust);

                finalFogColor *= dust * 0.05 + 0.95;
                
                fogDensityModifier = WATER_FOG_DENSITY;
                fogDistanceModifier = WATER_FOG_DISTANCE;
                break;
            }
            case 2: { // Lava
                finalFogColor = vec3(1.0, 0.1, 0.02) * 2.0;
                gl_FragData[0].rgb = mix(gl_FragData[0].rgb, finalFogColor, 0.3);

                fogDensityModifier = LAVA_FOG_DENSITY;
                fogDistanceModifier = LAVA_FOG_DISTANCE;
                break;
            }
            case 3: { // Powdered Snow
                finalFogColor *= fogColor * 2.0;
                gl_FragData[0].rgb = mix(gl_FragData[0].rgb, finalFogColor, 0.3);

                fogDensityModifier = SNOW_FOG_DENSITY;
                fogDistanceModifier = SNOW_FOG_DISTANCE;
                break;
            }
            default: break;
        }

        float fogFactor = exp(-FOG_DENSITY * fogDensityModifier * (1.0 - length(viewPos) / far / (FOG_DISTANCE * fogDistanceModifier)));
        fogFactor = clamp(fogFactor, 0.0, 1.0) + snoise((cameraPosition + feetPlayerPos) / 24.0 + frameTimeCounter * 0.3) * (0.3 / far / (FOG_DISTANCE * fogDistanceModifier));
        gl_FragData[0].rgb = mix(gl_FragData[0].rgb, finalFogColor, clamp(fogFactor, 0.0, 1.0));
    #endif
}