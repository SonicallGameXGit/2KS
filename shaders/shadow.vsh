#version 120
#include "/lib/shadow.glsl"

out vec2 texcoord;
out vec4 color;

void main() {
    gl_Position = ftransform();
    gl_Position.xyz = distort(gl_Position.xyz);
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    color = gl_Color;
}