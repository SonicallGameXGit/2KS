#version 120

#include "/lib/properties.glsl"
#include "/lib/noise.glsl"

uniform sampler2D texture;
uniform float frameTimeCounter;
uniform float viewWidth, viewHeight;

varying vec4 color;
varying vec2 coord0;

void main() {
    #ifdef NO_POSTPROCESSING
        gl_FragData[0] = texture2D(texture, coord0);
        return;
    #endif
    
    #ifdef CHROMATIC_ABBERATION_ENABLED
        float chromaticAberrationAmount = CHROMATIC_ABBERATION_STRENGTH / viewWidth * DOWNSAMPLING;
        float red = texture2D(texture, vec2(coord0.x + chromaticAberrationAmount, coord0.y)).r * color.r;
        float green = texture2D(texture, coord0).g * color.g;
        float blue = texture2D(texture, vec2(coord0.x - chromaticAberrationAmount, coord0.y)).b * color.b;

        gl_FragData[0] = vec4(red, green, blue, 1.0);
    #else
        gl_FragData[0] = texture2D(texture, coord0) * color;
    #endif
    #ifdef FILM_GRAIN_ENABLED
        gl_FragData[0].rgb *= mix(snoise(vec3(fract(coord0 * vec2(viewWidth, viewHeight) / max(DOWNSAMPLING, 1.0) / 75.0) * 75.0, frameTimeCounter * 10.0)) * 0.5 + 0.5, 1.0, 1.0 - FILM_GRAIN_STRENGTH);
    #endif
}
