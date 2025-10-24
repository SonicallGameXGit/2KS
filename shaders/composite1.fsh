#version 120

#include "/lib/properties.glsl"
#include "/lib/noise.glsl"

const bool colortex0MipmapEnabled = true;
uniform sampler2D texture, depthtex0;
uniform float viewWidth, viewHeight;
uniform float frameTimeCounter, aspectRatio;
uniform vec3 previousCameraPosition, cameraPosition;
uniform mat4 gbufferProjectionInverse, gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView, gbufferPreviousProjection;

varying vec4 color;
varying vec2 coord0;

#ifdef MOTION_BLUR_ENABLED
    // Source: https://modrinth.com/shader/motion-blur-fx?version=1.21.1&loader=iris
    vec3 MotionBlur(in vec3 color, in vec2 texcoord, in float z, in float dither) {
        const float DEPTH_THRESHOLD = 0.66;
        if (z <= DEPTH_THRESHOLD) return color;

        vec4 currentPosition = vec4(texcoord, z, 1.0) * 2.0 - 1.0;
        vec4 viewPos = gbufferProjectionInverse * currentPosition;
        viewPos = gbufferModelViewInverse * viewPos;
        viewPos /= viewPos.w;

        vec3 cameraOffset = cameraPosition - previousCameraPosition;
        vec4 previousPosition = gbufferPreviousProjection * gbufferPreviousModelView * (viewPos + vec4(cameraOffset, 0.0));
        previousPosition /= previousPosition.w;

        vec2 velocity = (currentPosition - previousPosition).xy;
        velocity = velocity / (1.0 + length(velocity)) * MOTION_BLUR_STRENGTH;

        vec3 mblur = vec3(0.0);
        float totalWeight = 0.0;

        for (int i = 0; i < MOTION_BLUR_SAMPLES; i++) {
            float t = (float(i) + dither) / float(MOTION_BLUR_SAMPLES - 1);
            vec2 offset = velocity * (t - 0.5);
            vec2 sampleCoord = texcoord + offset;
            
            vec3 sampleColor = texture2D(texture, sampleCoord).rgb;
            float noiseValue = random(sampleCoord * frameTimeCounter);
            float weight = mix(0.5, 1.0, noiseValue);
            
            mblur += sampleColor * weight;
            totalWeight += weight;
        }

        return mblur / totalWeight;
    }
#endif

#ifdef BLOOM_ENABLED
    const vec3[3] gaussianKernels = vec3[3](
        vec3(0.0625, 0.125,  0.0625),
        vec3( 0.125,  0.25,   0.125),
        vec3(0.0625, 0.125,  0.0625)
    );

    vec3 bloom(in vec2 texcoord, in float lod) {
        vec3 result = textureLod(texture, texcoord, lod).rgb;
        return result * pow(dot(result, vec3(0.333)), 12.0);
    }
#endif

mat2 rotate2D(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c, -s, s, c);
}

void main() {
    float power = (1.0 - 1.0 / exp(distance(cameraPosition, previousCameraPosition) * 2.3)) * 0.5;
    vec2 texcoord = (coord0 * 2.0 - 1.0) / 1.1;
    float centerDistance = length(texcoord);
    texcoord *= centerDistance * FISHEYE_STRENGTH + (1.0 - FISHEYE_STRENGTH);
    texcoord.x *= aspectRatio;
    #ifdef SHAKE_ENABLED
        // base .x shake
        texcoord.x += sin(frameTimeCounter * 0.3 * SHAKE_FLOW_SPEED) * 0.04 * SHAKE_FLOW_STRENGTH * SHAKE_STRENGTH;
        // micro .x shake
        texcoord.x += clamp(sin(frameTimeCounter * 23.0 * SHAKE_MICRO_SPEED) * sin(frameTimeCounter * 9.0 * SHAKE_MICRO_SPEED) * max(sin(frameTimeCounter * 0.21 * SHAKE_MICRO_SPEED) * sin(frameTimeCounter * 12.0 * SHAKE_MICRO_SPEED) * sin(frameTimeCounter * 0.1 * SHAKE_MICRO_SPEED) * 20.0, 0.0) * 1.3 - 0.3, -1.0, 1.0) * 0.001 * SHAKE_MICRO_STRENGTH * SHAKE_STRENGTH;
        // rare small .x shake
        texcoord.x += pow(sin(frameTimeCounter * 7.0 * SHAKE_MICRO_SPEED) * cos(frameTimeCounter * 2.0 * SHAKE_MICRO_SPEED) * sin(frameTimeCounter * 0.9 * SHAKE_MICRO_SPEED + 0.32), 2.0) * 0.005 * (1.0 + power * 2.0) * SHAKE_MICRO_STRENGTH * SHAKE_STRENGTH;
        // rare .x dropping effect
        texcoord.x += clamp((sin(frameTimeCounter * 5.21 + 58.93) * cos(frameTimeCounter * 7.6843 - 12.6344)/*  + cos(frameTimeCounter * 1.934 - 12.324) */ + cos(frameTimeCounter * 0.312 * SHAKE_DROP_FREQUENCY + 0.324) * 4.0), -1.0, 1.0) * 0.01 * (1.0 + power * 3.5) * SHAKE_DROP_STRENGTH * SHAKE_STRENGTH;
        // base .y shake
        texcoord.y += sin(frameTimeCounter * 0.32 * SHAKE_FLOW_SPEED + 12.291) * 0.04 * (1.0 + power) * SHAKE_FLOW_STRENGTH * SHAKE_STRENGTH;
        // micro .y shake
        texcoord.y += clamp(sin(frameTimeCounter * 21.3 * SHAKE_MICRO_SPEED - 0.324) * sin(frameTimeCounter * 7.6 * SHAKE_MICRO_SPEED - 2.242) * max(sin(frameTimeCounter * 0.2834 * SHAKE_MICRO_SPEED + 0.23) * sin(frameTimeCounter * 11.23 * SHAKE_MICRO_SPEED + 3.42) * sin(frameTimeCounter * 0.132 * SHAKE_MICRO_SPEED - 0.324) * 20.0, 0.0) * 1.3 - 0.3, -1.0, 1.0) * 0.001 * SHAKE_MICRO_STRENGTH * SHAKE_STRENGTH;
        // rare small .y shake
        // texcoord.y += pow(sin(frameTimeCounter * 7.342 - 3.423724) * cos(frameTimeCounter * 2.324 - 0.324) * sin(frameTimeCounter * 0.74 + 3482.23842), 2.0) * 0.005 * (1.0 + power * 2.7);
        // rare .y dropping effect
        texcoord.y += clamp(pow(sin(frameTimeCounter * 4.3 + 32.24) * cos(frameTimeCounter * 8.392 - 0.324) + cos(frameTimeCounter * 2.392 - 31.324)/*  + cos(frameTimeCounter * 0.312 + 0.324) * 4.0 */, 3.0), -1.0, 1.0) * 0.01 * (1.0 + power * 3.5) * SHAKE_DROP_STRENGTH * SHAKE_STRENGTH;
        // constant mini-shake
        texcoord += vec2(sin(frameTimeCounter * 78.0 * (1.1 - power)), cos(frameTimeCounter * 86.0 * (1.1 - power))) * 0.01 * pow(power, 2.0) * SHAKE_STRENGTH;
    #endif
    #ifdef TILT_ENABLED
        float tiltAngle = 0.0;
        // base rotation
        tiltAngle += floor(sin(frameTimeCounter * 0.5 * TILT_FLOW_SPEED) * 10.0) / 10.0 * 0.2 * TILT_STRENGTH * TILT_FLOW_STRENGTH + power;
        // second layer base rotation
        tiltAngle += sin(frameTimeCounter * 0.32 * TILT_FLOW_SPEED + 3.14) * 0.2 * TILT_FLOW_STRENGTH * TILT_STRENGTH;
        // rare "camera interception" effect
        // tiltAngle += pow(sin(frameTimeCounter * 3.0 + 1.32) * cos(frameTimeCounter * 1.2 + 0.23) * sin(frameTimeCounter * 0.7 + 2.32), 3.0) * 0.5;
        // rare dropping effect
        // tiltAngle += clamp((sin(frameTimeCounter * 4.3 * (1.0 + power * 2.5) + 32.24) * cos(frameTimeCounter * 9.23) + cos(frameTimeCounter * 0.3 + 0.1) * 4.0) * 3.0, -1.0, 1.0) * 0.1 * (1.0 + power * 3.4);
        // constant shaking
        // tiltAngle += pow(sin(frameTimeCounter * 1.0), 3.0) * 0.6 * pow(power, 2.0) * 0.2;
        texcoord.xy *= rotate2D(tiltAngle * 0.1);
    #endif
    texcoord.x /= aspectRatio;
    texcoord = texcoord * 0.5 + 0.5;

    vec3 color = texture2D(texture, texcoord).rgb;
    #ifdef MOTION_BLUR_ENABLED
        color = MotionBlur(color, texcoord, texture2D(depthtex0, texcoord).r, random(texcoord * frameTimeCounter));
    #endif

    #ifdef BLOOM_ENABLED
        vec3 bloomColor = vec3(0.0);
        bloomColor += bloom(texcoord, 6.0);
        bloomColor += bloom(texcoord, 4.0) / 2.0;
        color += bloomColor * BLOOM_STRENGTH;
    #endif
    gl_FragData[0] = vec4(color * 0.8, 1.0);
}
