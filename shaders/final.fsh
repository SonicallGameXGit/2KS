#version 120
#include "/lib/properties.glsl"

const bool colortex0MipmapEnabled = true;

uniform float viewWidth, viewHeight;
uniform sampler2D colortex0;
varying vec2 coord0;

void main() {
    #ifdef NO_POSTPROCESSING
        gl_FragData[0] = texture2D(colortex0, coord0);
        return;
    #endif
    
    vec2 texcoord = coord0;

    gl_FragData[0] = vec4(texture2D(colortex0, texcoord).rgb, 1.0);
    #ifdef TONEMAPPING_ENABLED
        #ifdef AUTO_EXPOSURE_ENABLED
            float brightness = dot(textureLod(colortex0, texcoord, 12.0).rgb, vec3(0.333));
            gl_FragData[0].rgb *= 1.0 - brightness * 0.4;
        #endif
    #endif

    gl_FragData[0].rgb = min(gl_FragData[0].rgb, vec3(1.0));
    #ifdef VIGNETTE_ENABLED
        gl_FragData[0].rgb *= pow(min(1.5 / VIGNETTE_STRENGTH - length(texcoord * 2.0 - 1.0), 1.0), 0.5);
    #endif

    gl_FragData[0].rgb += BRIGHTNESS_ADJUSTMENT;
}
