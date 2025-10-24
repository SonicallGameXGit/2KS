/*
    XorDev's "Default Shaderpack"

    This was put together by @XorDev to make it easier for anyone to make their own shaderpacks in Minecraft (Optifine).
    You can do whatever you want with this code! Credit is not necessary, but always appreciated!

    You can find more information about shaders in Optfine here:
    https://github.com/sp614x/optifine/blob/master/OptiFineDoc/doc/shaders.txt

*/
//Declare GL version.
#version 120

//0-1 amount of blindness.
uniform float blindness;

//Vertex color.
varying vec4 color;

void main() {
    vec4 col = color;

    //Output the result.
    gl_FragData[0] = col * vec4(vec3(1.-blindness),1);
}
