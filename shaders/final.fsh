#version 120
#include "/lib/properties.glsl"

const bool colortex0MipmapEnabled = true;

uniform float viewWidth, viewHeight;
uniform sampler2D colortex0;
varying vec2 coord0;

const vec3[3] gaussianKernels = vec3[3](
    vec3(0.0625, 0.125,  0.0625),
    vec3( 0.125,  0.25,   0.125),
    vec3(0.0625, 0.125,  0.0625)
);

vec3 bloom(in vec2 texcoord, in float lod) {
    vec2 texelSize = pow(2.0, lod) / vec2(viewWidth, viewHeight);
    vec3 color = vec3(0.0);
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(float(x), float(y)) * texelSize;
            vec3 sample = textureLod(colortex0, texcoord + offset, lod).rgb;
            sample = pow(sample, vec3(2.0));
            sample = max(sample * 3.0 - 0.3, 0.0);
            color += clamp(sample, vec3(0.0), vec3(1.0)) * gaussianKernels[x + 1][y + 1];
        }
    }
    return color;
}

void main() {
    #ifdef NO_POSTPROCESSING
        gl_FragData[0] = texture2D(colortex0, coord0);
        return;
    #endif
    
    vec2 texcoord = coord0;
    vec3 color = vec3(0.0);
    color += bloom(texcoord, 8.0) * 2.0;
    color += bloom(texcoord, 6.0);

    gl_FragData[0] = vec4(texture2D(colortex0, texcoord).rgb + dot(color, vec3(0.333)) * 0.2, 1.0);
    #if defined(TONEMAPPING_ENABLED)
        #ifdef AUTO_EXPOSURE_ENABLED
            float brightness = dot(textureLod(colortex0, texcoord, 12.0).rgb, vec3(0.333));
            gl_FragData[0].rgb *= 1.0 - brightness * 0.75;
        #endif
    #endif
}
