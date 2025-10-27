#version 120
#include "/lib/properties.glsl"
#include "/lib/noise.glsl"

varying vec4 color;

uniform float blindness;
uniform float far;
uniform float frameTimeCounter;
uniform float viewWidth, viewHeight;
uniform mat4 gbufferProjectionInverse, gbufferModelViewInverse;
uniform vec3 skyColor;

void main() {
    gl_FragData[0] = vec4(color.rgb * 0.7, color.a) * vec4(vec3(1.0 - blindness), 1.0);

    #ifdef FOG_ENABLED
        vec2 texcoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
        vec3 NDCPos = vec3(texcoord, 1.0) * 2.0 - 1.0;
        vec4 viewPos = gbufferProjectionInverse * vec4(NDCPos, 1.0);
        viewPos.xyz /= viewPos.w;
        vec3 worldPos = (gbufferModelViewInverse * vec4(viewPos.xyz, 0.0)).xyz;

        gl_FragData[0].rgb = mix(gl_FragData[0].rgb, skyColor * 0.7, 1.0 - clamp(worldPos.y * 0.002 - 0.5, 0.0, 1.0));
    #endif
}
