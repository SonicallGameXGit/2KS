#version 120

in vec2 texcoord;
in vec4 color;
uniform sampler2D gtexture;

void main() {
    gl_FragData[0] = texture(gtexture, texcoord) * color;
}