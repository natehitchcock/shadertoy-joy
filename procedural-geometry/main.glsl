/*
 * Procedural geometry
 *  Phase 1: sphere in solid color
 *  Phase 2: Raytrace render
*/
float sdSphere(vec3 p, vec3 c, float r) {
    vec3 d = p - c;
    return length(d) - r;
}

#define PRECISION 0.01
#define MAX_D 1.0
#define MAX_STEPS 30
#define NO_INTERSECT -1.0
/*
    depth trace by walking the ray
    test distance to surface
    walk new depth
    repeat until close enough or past max distance
*/
float depthTrace(vec3 origin, vec3 dir) {
    float dist = 0.;
    float probeDist = 0.;

    for(int i = 0; i < MAX_STEPS; i++) {
        dist = sdSphere(origin + dir * probeDist, vec3(.5,.5,.5), .25);
        probeDist += dist;
        if(probeDist > MAX_D || abs(dist) < PRECISION) break;
    }

    if(probeDist > MAX_D) return NO_INTERSECT;
    return probeDist;

}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    float d = depthTrace(vec3(uv, 1.), vec3(0., 0., -1.));
    if(d >= 0.) {
        gl_FragColor = mix(
            vec4(0.8, 0.1, 0.1, 1.),
            vec4(0.1, 0.1, 0.1, 0.1),
            d
        );
    } else {
        gl_FragColor = vec4(0.1, 0.1, 0.1, 0.1);
    }
}