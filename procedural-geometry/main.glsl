/*
 * Procedural geometry
 *  Phase 1: Sphere in solid color
 *  Phase 2: Raytrace render
 *  Phase 3: Orbiting camera
 *  Phase 4: Normal calculations & lighting
*/
float sdSphere(vec3 p, vec3 c, float r) {
    vec3 d = p - c;
    return length(d) - r;
}

float sdAxisAlignedCube(vec3 p, vec3 c, vec3 halfextents) {
    vec3 d = p - c;
    vec3 pen = abs(d) - halfextents;
    float farthest = max(max(pen.x, pen.y), pen.z);

    return farthest;
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
        vec3 point = origin + (dir * probeDist);
        //dist = sdSphere(point, vec3(.5,.5,.5), .25);
        dist = sdAxisAlignedCube(point, vec3(.5,.5,.5), vec3(.15,.25,.35));
        probeDist += dist;
        if(probeDist > MAX_D || abs(dist) < PRECISION) break;
    }

    if(probeDist > MAX_D) return NO_INTERSECT;
    return probeDist;

}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec3 cameraPos = vec3(0.7, 0.7, 1.5);
    vec3 forward = normalize(vec3(-1., -1., -1.));
    vec3 right = cross(forward, vec3(0., 1., 0.));
    vec3 up = cross(right, forward);
    vec3 raystart = cameraPos + right * uv.x + up * uv.y;
    float d = depthTrace(raystart, forward);
    if(d >= 0.) {
        gl_FragColor = mix(
            vec4(0.8, 0.1, 0.1, 1.),
            vec4(0.1, 0.1, 0.1, 0.1),
            d
        );
    } else {
        gl_FragColor = vec4(0.05, 0.1, 0.1, 1.);
    }
}