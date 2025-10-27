varying vec4 v_Color;
varying vec2 v_TexCoord;
varying vec2 v_LMCoord;
varying vec3 v_Normal;
// varying vec3 v_EmissiveColor;

uniform sampler2D texture, lightmap;
uniform vec4 entityColor;
uniform float blindness;
uniform int blockEntityId;

void main() {
    vec3 light = (1.0 - blindness) * texture2D(lightmap, v_LMCoord).rgb;
    vec4 col = v_Color * vec4(light, 1.0) * texture2D(texture, v_TexCoord);
    col.rgb = mix(col.rgb, entityColor.rgb, entityColor.a);

    /* RENDERTARGETS: 0,1,3 */
    gl_FragData[0] = col;
    gl_FragData[1] = vec4(v_Normal * 0.5 + 0.5, 1.0);
    gl_FragData[2] = vec4(vec3(1.3, 0.6, 0.3) * 2.0 * v_LMCoord.x, 1.0);
}