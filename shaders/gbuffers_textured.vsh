#version 120

attribute vec2 mc_Entity;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

varying vec4 v_Color;
varying vec2 v_TexCoord, v_LMCoord;
varying vec3 v_Normal;
varying vec3 v_EmissiveColor;

void main() {
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (gbufferModelViewInverse * vec4(pos, 1.0)).xyz;

    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos, 1.0);
    gl_FogFragCoord = length(pos);

    v_Normal = gl_NormalMatrix * gl_Normal;
    v_Normal = (gbufferModelViewInverse * vec4(v_Normal, 0.0)).xyz;

    v_Color = vec4(gl_Color.rgb, gl_Color.a);
    v_TexCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    v_LMCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    // v_EmissiveColor = vec3(0.0);
    // switch (int(mc_Entity.x)) {
    //     case 10001: {
    //         v_EmissiveColor = vec3(1.0, 0.0, 0.0);
    //         break;
    //     }
    //     case 10002: {
    //         v_EmissiveColor = vec3(1.0, 0.5, 0.1);
    //         break;
    //     }
    //     case 10003: {
    //         v_EmissiveColor = vec3(1.0, 0.9, 0.3);
    //         break;
    //     }
    //     case 10004: {
    //         v_EmissiveColor = vec3(0.6, 0.9, 0.6);
    //         break;
    //     }
    //     case 10005: {
    //         v_EmissiveColor = vec3(0.2, 0.9, 1.0);
    //         break;
    //     }
    //     case 10006: {
    //         v_EmissiveColor = vec3(0.5, 1.0, 0.85);
    //         break;
    //     }
    //     case 10007: {
    //         v_EmissiveColor = vec3(0.6, 0.2, 1.0);
    //         break;
    //     }
    //     case 10008: {
    //         v_EmissiveColor = vec3(0.8, 0.9, 1.0);
    //         break;
    //     }
    //     default: break;
    // }
}
