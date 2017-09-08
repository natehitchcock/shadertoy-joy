/*
 * Procedural geometry
 *  Phase 1: sphere in solid color
 *  Phase 2: Raytrace render
*/
float sdSphere(vec3 p, vec3 c, float r) {
    vec3 d = p - c;
    return length(d) < r ? 1. : 0.;
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    gl_FragColor = mix(
        vec4(0.1, 0.1, 0.1, 0.1),
        vec4(0.8, 0.1, 0.1, 1.),
        sdSphere(vec3(uv, .5), vec3(0.5, 0.5, 0.5), 0.25)
    );
}