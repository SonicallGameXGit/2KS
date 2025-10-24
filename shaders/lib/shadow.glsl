#ifndef SHADOW_GLSL
#define SHADOW_GLSL

// Source: https://shaders.properties/current/guides/your-first-shaderpack/4_shadows/
vec3 distort(vec3 shadowClipPos) {
    float distortionFactor = length(shadowClipPos.xy); // distance from the player in shadow clip space
    distortionFactor += 0.1; // very small distances can cause issues so we add this to slightly reduce the distortion

    shadowClipPos.xy /= distortionFactor;
    shadowClipPos.z *= 0.5; // increases shadow distance on the Z axis, which helps when the sun is very low in the sky
    return shadowClipPos;
}

#endif