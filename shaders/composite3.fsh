// Tonemapping & overlay layer
#version 120

#include "/lib/properties.glsl"
#include "/lib/noise.glsl"

const bool colortex0MipmapEnabled = true;
varying vec2 coord0;

uniform float frameTimeCounter, aspectRatio;
uniform float viewWidth, viewHeight;
uniform sampler2D depthtex0, colortex0;

uniform int worldTime, isEyeInWater;

const vec3[3] gaussianKernels = vec3[3](
    vec3(0.0625, 0.125,  0.0625),
    vec3( 0.125,  0.25,   0.125),
    vec3(0.0625, 0.125,  0.0625)
);

#ifdef DATE_TIME_ENABLED
    const uvec4 DIGITS[10] = uvec4[10](
        uvec4(0x3c, 0x7e666666, 0x6666667e, 0x3c000000),
        uvec4(0x8, 0x18387818, 0x1818187e, 0x7e000000),
        uvec4(0x3c, 0x7e66660e, 0x1c38707e, 0x7e000000),
        uvec4(0x3c, 0x7e66660c, 0xc06667e, 0x3c000000),
        uvec4(0x66, 0x66666666, 0x7e3e0606, 0x6000000),
        uvec4(0x3e, 0x7e60607e, 0x7e06067e, 0x7c000000),
        uvec4(0x3c, 0x7e66607c, 0x7e66667e, 0x3c000000),
        uvec4(0x7e, 0x7e06060c, 0xc181818, 0x18000000),
        uvec4(0x3c, 0x7e66663c, 0x3c66667e, 0x3c000000),
        uvec4(0x3c, 0x7e66667e, 0x3e06667e, 0x3c000000)
    );
    const uvec4 COLON = uvec4(0x0, 0x181800, 0x181800, 0x0);

    // Source: https://www.shadertoy.com/view/Mc3cW2
    vec2 character(in uvec4 bits, in vec2 texcoord, in vec2 position, in float height) {
        vec2  uv     = texcoord;
        vec2  tuv    = (vec2(uv.s, 1.0 - uv.t) - position) * (16.0 / height);
        ivec2 ituv   = ivec2(tuv);
        int   row    = ituv.y;
        int   word   = row >> 2;
        int   byte   = row & 0x3;
        int   bit    = ituv.x;
        float val    = 0.5;
        if (tuv.x >= 0.0 && tuv.x < 8.0 && tuv.y >= 0.0 && tuv.y < 16.0) {
            float v = float(((bits[word] >> ((3 - byte) << 3u)) >> (7 - bit)) & 1u) * (4.0 - pow(length(tuv / vec2(8.0, 16.0) - 0.5), 0.5) * 4.0);
            return vec2(v, 1.0);
        }
        return vec2(0.0);
    }
    void drawText() {
        const float textHeight = 0.05;
        vec2 text = vec2(0.0);
        float width = (8.0 / 16.0 * textHeight) * 4.0 + (4.0 / 16.0 * textHeight);
        #ifdef BORDER_ENABLED
            float cursor = (aspectRatio < 4.0 / 3.0 ? aspectRatio : ((aspectRatio + 4.0/3.0) * 0.5)) - width - 0.1;
        #else
            float cursor = (0.93 - width / aspectRatio) * aspectRatio;
        #endif

        float y = 1.0 - textHeight - 0.05;
        vec2 uv = coord0;
        uv.x *= aspectRatio;

        int time = (worldTime + 8000) % 24000;
        int hours = int(floor(float(time) / 1000.0));
        int minutes = int(floor(float(time - hours * 1000.0) / 1000.0 * 60.0)) % 60;

        text += character(DIGITS[hours / 10], uv, vec2(cursor, y), textHeight); cursor += 8.0 / 16.0 * textHeight;
        text += character(DIGITS[hours % 10], uv, vec2(cursor, y), textHeight); cursor += 8.0 / 16.0 * textHeight;
        text += character(COLON, uv, vec2(cursor - 2.0 / 16.0 * textHeight, y), textHeight); cursor += 4.0 / 16.0 * textHeight;
        text += character(DIGITS[minutes / 10], uv, vec2(cursor, y), textHeight); cursor += 8.0 / 16.0 * textHeight;
        text += character(DIGITS[minutes % 10], uv, vec2(cursor, y), textHeight); cursor += 8.0 / 16.0 * textHeight;

        gl_FragData[0].rgb = mix(mix(clamp(gl_FragData[0].rgb, vec3(0.0), vec3(1.0)), vec3(0.0), smoothstep(0.0, 1.0, text.y) * 0.4), vec3(DATE_TIME_RED, DATE_TIME_GREEN, DATE_TIME_BLUE) * 2.0, text.x);
    }
#endif

void main() {
    #ifdef NO_POSTPROCESSING
        gl_FragData[0] = texture2D(colortex0, coord0);
        return;
    #endif
    
    vec2 texcoord = coord0;
    float centerDistance = length(texcoord * 2.0 - 1.0);

    float depth = pow(texture2D(depthtex0, texcoord).r, 128.0);
    #ifdef DISTANCE_BLUR_ENABLED
        float downsampling = mix(DOWNSAMPLING, DOWNSAMPLING + 1.0, depth);
    #else
        float downsampling = DOWNSAMPLING;
    #endif
    if (isEyeInWater > 0) {
        downsampling += float(UNDERWATER_BLUR_STRENGTH);
    }

    vec2 viewResolution = vec2(viewWidth, viewHeight);
    vec2 downsampledWidth = pow(2.0, downsampling) / viewResolution;

    vec3 blurred = vec3(0.0);
    blurred += textureLod(colortex0, texcoord + vec2(-1.0, -1.0) * downsampledWidth, downsampling).rgb * gaussianKernels[0][0];
    blurred += textureLod(colortex0, texcoord + vec2( 0.0, -1.0) * downsampledWidth, downsampling).rgb * gaussianKernels[1][0];
    blurred += textureLod(colortex0, texcoord + vec2( 1.0, -1.0) * downsampledWidth, downsampling).rgb * gaussianKernels[2][0];
    blurred += textureLod(colortex0, texcoord + vec2(-1.0,  1.0) * downsampledWidth, downsampling).rgb * gaussianKernels[0][2];
    blurred += textureLod(colortex0, texcoord + vec2( 0.0,  1.0) * downsampledWidth, downsampling).rgb * gaussianKernels[1][2];
    blurred += textureLod(colortex0, texcoord + vec2( 1.0,  1.0) * downsampledWidth, downsampling).rgb * gaussianKernels[2][2];
    blurred += textureLod(colortex0, texcoord + vec2(-1.0,  0.0) * downsampledWidth, downsampling).rgb * gaussianKernels[0][1];
    blurred += textureLod(colortex0, texcoord + vec2( 1.0,  0.0) * downsampledWidth, downsampling).rgb * gaussianKernels[2][1];

    vec3 source = textureLod(colortex0, texcoord, downsampling).rgb;
    vec3 middleBlurred = source * gaussianKernels[1][1];

    vec3 sharpenning = source - blurred;
    gl_FragData[0] = vec4(middleBlurred + blurred, 1.0);
    gl_FragData[0].rgb += max(pow(sharpenning, vec3(2.0)) * 64.0 * SHARPNESS_STRENGTH, 0.0) * (1.0 - min(isEyeInWater, 1.0));
    #ifdef TONEMAPPING_ENABLED
        gl_FragData[0].rgb = pow(gl_FragData[0].rgb, vec3(1.0 / GAMMA_CORRECTION));
        gl_FragData[0].rgb -= 0.3;
    #endif

    #ifdef TONEMAPPING_ENABLED
        #ifdef DISTORTIONS_ENABLED
            gl_FragData[0].rgb = mix(gl_FragData[0].rgb, pow(floor(textureLod(colortex0, vec2(
                texcoord.s + sin(texcoord.s * 124.4) * cos(texcoord.t * 84.234) * 0.001,
                texcoord.t + sin(texcoord.t * 124.4) * cos(texcoord.s * 84.234) * 0.001
            ), downsampling).rgb * 16.0) / 16.0, vec3(2.0)) * 4.0, 0.1);
        #endif
    #endif

    #ifdef TONEMAPPING_ENABLED
        gl_FragData[0].rgb = pow(gl_FragData[0].rgb, vec3(EXPOSURE_ADJUSTMENT));
    #endif
    #ifdef TONEMAPPING_ENABLED
        #ifdef FLICKERING_ENABLED
            gl_FragData[0].rgb = mix(
                gl_FragData[0].rgb,
                vec3(dot(clamp(gl_FragData[0].rgb, 0.0, 1.0), vec3(0.3333))),
                max(sin(frameTimeCounter * 2.6), 0.0) *
                pow(sin(frameTimeCounter * 46.4 + 0.3) +
                    cos(frameTimeCounter * 32.3 - 0.4),
                2.0) * 0.05 + 0.2
            );
            gl_FragData[0].rgb = mix(
                clamp(gl_FragData[0].rgb, 0.0, 1.0),
                clamp(gl_FragData[0].brg, 0.0, 1.0),
                (sin(frameTimeCounter * 1.4) * 0.5 + 0.5) * 0.1 + 0.1
            );
        #endif
    #endif

    #if defined(TONEMAPPING_ENABLED)
        #ifdef GRADIENTS_ENABLED
            gl_FragData[0].rgb *= vec3(0.8 + pow(texcoord.x, 2.0) * 0.1, 0.9 + pow(texcoord.y, 2.0) * 0.3, 0.9 + pow(texcoord.y, 2.0) * 0.5);
        #endif
    #endif
    #ifdef TONEMAPPING_ENABLED
        gl_FragData[0].rgb *= vec3(ADJUST_RED, ADJUST_GREEN, ADJUST_BLUE);
    #endif

    #ifdef BORDER_ENABLED
        float aspectOffset = pow(max(random(texcoord + sin(frameTimeCounter) * 10.0), 0.0), 64.0) * 0.2;
        gl_FragData[0].rgb *= abs((coord0.x * 2.0 - 1.0) * aspectRatio) + aspectOffset < 4.0 / 3.0 ? 1.0 : 0.0;
    #endif

    #ifdef DATE_TIME_ENABLED
        drawText();
    #endif
}