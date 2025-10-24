#version 130

#include "/lib/properties.glsl"
#include "/lib/shadow.glsl"
#include "/lib/noise.glsl"

const float sunPathRotation = 45.0;
const bool shadowHardwareFiltering = true;
const int shadowMapResolution = SHADOWS_QUALITY;
const bool shadowtex0MipmapEnabled = true;

uniform sampler2D texture, depthtex0;
uniform sampler2DShadow shadowtex0;
uniform vec3 cameraPosition, previousCameraPosition;
uniform vec3 skyColor;
uniform float far;
uniform float frameTimeCounter;

uniform mat4 gbufferProjectionInverse, gbufferModelViewInverse, gbufferPreviousModelView, gbufferPreviousProjection;
uniform mat4 shadowModelView, shadowProjection;

varying vec4 color;
varying vec2 coord0;

void main() {
    gl_FragData[0] = color * texture2D(texture, coord0);

    float depth = texture2D(depthtex0, coord0).r;
    if (depth >= 1.0) {
        return;
    }

    #if defined(SHADOWS_ENABLED) || defined(FOG_ENABLED)
        vec3 NDCPos = vec3(coord0, depth) * 2.0 - 1.0;
        vec4 viewPos = gbufferProjectionInverse * vec4(NDCPos, 1.0);
        viewPos.xyz /= viewPos.w;
        vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos.xyz, 1.0)).xyz;
    #endif

    #ifdef SHADOWS_ENABLED
        vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
        vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
        shadowClipPos.z -= 0.0025;
        shadowClipPos.xyz = distort(shadowClipPos.xyz);
        vec3 shadowNDCPos = shadowClipPos.xyz / shadowClipPos.w;
        vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;

        float shadow = 0.0;
        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
                shadow += texture(shadowtex0, shadowScreenPos + vec3(float(x), float(y), 0.0) / float(shadowMapResolution));
            }
        }
        shadow /= 9.0;
        #ifdef FOG_ENABLED
            shadow = mix(0.5, shadow, pow(FOG_DISTANCE - 0.1, 0.6));
        #endif

        gl_FragData[0].rgb = mix(gl_FragData[0].rgb * 0.5, gl_FragData[0].rgb * (shadow * SHADOWS_STRENGTH + (1.0 - SHADOWS_STRENGTH)), 1.0 - clamp(length(viewPos.xyz) / far * 4.0, 0.0, 1.0));
    #endif
    #ifdef FOG_ENABLED
        float fogFactor = exp(-FOG_DENSITY * (1.0 - length(viewPos.xyz) / far / FOG_DISTANCE));
        fogFactor *= 1.0 + snoise((cameraPosition + feetPlayerPos) / 24.0 + frameTimeCounter * 0.3) * 0.2;
        gl_FragData[0].rgb = mix(gl_FragData[0].rgb, skyColor, clamp(fogFactor, 0.0, 1.0));
    #endif
}