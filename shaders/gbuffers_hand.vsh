#version 120
#include "/lib/properties.glsl"

#ifdef HAND_VISIBLE
    #include "/gbuffers_textured_vert.glsl"
#else
    void main() {}
#endif