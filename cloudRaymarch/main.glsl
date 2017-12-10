const float PRECISION = 0.01;
const float MAX_D = 1000.0;
const int MAX_STEPS = 3000;
const float STEP_SIZE = 1000.0 / 3000.0;
const float NO_INTERSECT = -1.0;

mat3 makeRot(vec3 forward, vec3 right, vec3 up) {
    mat3 cam;
    cam[0][0] = forward.x;
    cam[0][1] = forward.y;
    cam[0][2] = forward.z;
    cam[1][0] = right.x;
    cam[1][1] = right.y;
    cam[1][2] = right.z;
    cam[2][0] = up.x;
    cam[2][1] = up.y;
    cam[2][2] = up.z;
    
    return cam;
    
}

vec3 applyCameraTransform(vec3 point, mat3 cameraRot, vec3 cameraPos) {
    // Apply translation, then rotation
    return cameraRot * (point - cameraPos);
}
// Psuedo rand
float hash(float h) 
{
  return fract(sin(h) * 43758.5453123)
}

// Swiped noise function
float noise(vec3 x) 
{
  vec3 p = floor(x);
  vec3 f = fract(x);
  f = f * f * (3.0 - 2.0 * f);

  float n = p.x + p.y * 157.0 + 113.0 * p.z;
  return -1.0+2.0*mix(
    mix(mix(hash(n + 0.0), hash(n + 1.0), f.x), 
    mix(hash(n + 157.0), hash(n + 158.0), f.x), f.y), 
    mix(mix(hash(n + 113.0), hash(n + 114.0), f.x), 
    mix(hash(n + 270.0), hash(n + 271.0), f.x), f.y), f.z);
}

float cloudDensityMap(vec3 pos) {
	float offset = 0.4;
    float weight = 0.003;
    float density = noise(pos * 0.1);
    density -= offset;
    density = clamp(density, 0.0, 1.0) * weight;
        
    return density;
    
}

float depthTrace(vec3 origin, vec3 dir) {
    float density = 0.;
    float probeDist = 0.;
    float densityAcc = 0.;

    for(int i = 0; i < MAX_STEPS; i++) {
        density = cloudDensityMap(origin + dir * probeDist);
        densityAcc += density;
        probeDist += STEP_SIZE;
        if(probeDist > MAX_D || densityAcc >= 1.0) break;
    }

    if(probeDist > MAX_D) return NO_INTERSECT;
    return densityAcc;

}

void main() {
    vec2 uv = gl_FragCoord.xy - iResolution.xy/2.;
    vec2 mouse = (iMouse.xy / iResolution.xy - 0.5) * 2.;
    mat3 yawRot = makeRot(
        vec3(cos(mouse.x), 0., sin(mouse.x)),
        vec3(0., 1., 0.),
        vec3(-sin(mouse.x), 0., cos(mouse.x))
    );
    mat3 pitchRot = makeRot(
        vec3(1., 0., 0.),
        vec3(0., cos(mouse.y), sin(mouse.y)),
        vec3(0., -sin(mouse.y), cos(mouse.y))
    );
    mat3 camRot = yawRot * pitchRot;
    vec3 camPos = vec3(0., 0., 0.0);
    
    vec3 ro = vec3(uv, 200.);
    vec3 rd = normalize(ro - camPos);
    
    ro = applyCameraTransform(ro, camRot, camPos);
    rd = camRot * rd;
    
    float density = depthTrace(ro, rd);
   
    gl_FragColor = mix(
        vec4(0.1, 0.1, 0.1, 1.),
        vec4(0.8, 0.1, 0.1, 0.1),
        clamp(density, 0., 1.)
    );

    //gl_FragColor =  vec4(0., 0., 0., 0.);
}