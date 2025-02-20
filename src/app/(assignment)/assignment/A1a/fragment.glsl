/////////////////////////////////////////////////////
//// CS 8803/4803 CGAI: Computer Graphics in AI Era
//// Assignment 1A: SDF and Ray Marching
/////////////////////////////////////////////////////

precision highp float;              //// set default precision of float variables to high precision

varying vec2 vUv;                   //// screen uv coordinates (varying, from vertex shader)
uniform vec2 iResolution;           //// screen resolution (uniform, from CPU)
uniform float iTime;                //// time elapsed (uniform, from CPU)

const vec3 CAM_POS = vec3(-0.35, 1.0, -3.0);
float sdf2(vec3 p);

/////////////////////////////////////////////////////
//// sdf functions
/////////////////////////////////////////////////////

struct material {
    float sdf;
    int id;
};
/////////////////////////////////////////////////////
//// Step 1: sdf primitives
//// You are asked to implement sdf primitive functions for sphere, plane, and box.
//// In each function, you will calculate the sdf value based on the function arguments.
/////////////////////////////////////////////////////

//// sphere: p - query point; c - sphere center; r - sphere radius
float sdfSphere(vec3 p, vec3 c, float r)
{
    //// your implementation starts
    
    return length(p - c) - r;
    
    //// your implementation ends
}

//// plane: p - query point; h - height
float sdfPlane(vec3 p, float h)
{
    //// your implementation starts
    
    return p.y - h;
    
    //// your implementation ends
}

//// box: p - query point; c - box center; b - box half size (i.e., the box size is (2*b.x, 2*b.y, 2*b.z))
float sdfBox(vec3 p, vec3 c, vec3 b)
{
    //// your implementation starts
    vec3 d = abs(p - c) - b;
    return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
    
    //// your implementation ends
}

/////////////////////////////////////////////////////
//// boolean operations
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
//// Step 2: sdf boolean operations
//// You are asked to implement sdf boolean operations for intersection, union, and subtraction.
/////////////////////////////////////////////////////

float sdfIntersection(float s1, float s2)
{
    //// your implementation starts
    
    return max(s1, s2);

    //// your implementation ends
}

float sdfUnion(float s1, float s2)
{
    //// your implementation starts
    
    return min(s1, s2);

    //// your implementation ends
}

float sdfSubtraction(float s1, float s2)
{
    //// your implementation starts
    
    return max(s1, -s2);

    //// your implementation ends
}

/////////////////////////////////////////////////////
//// sdf calculation
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
//// Step 3: scene sdf
//// You are asked to use the implemented sdf boolean operations to draw the following objects in the scene by calculating their CSG operations.
/////////////////////////////////////////////////////

//// sdf: p - query point
material sdf(vec3 p)
{
    float s = 0.;

    //// 1st object: plane
    float plane1_h = -0.1;
    
    //// 2nd object: sphere
    vec3 sphere1_c = vec3(-2.0, 1.0, 0.0);
    float sphere1_r = 0.25;

    //// 3rd object: box
    vec3 box1_c = vec3(-1.0, 1.0, 0.0);
    vec3 box1_b = vec3(0.2, 0.2, 0.2);

    //// 4th object: box-sphere subtraction
    vec3 box2_c = vec3(0.0, 1.0, 0.0);
    vec3 box2_b = vec3(0.3, 0.3, 0.3);

    vec3 sphere2_c = vec3(0.0, 1.0, 0.0);
    float sphere2_r = 0.4;

    //// 5th object: sphere-sphere intersection
    vec3 sphere3_c = vec3(1.0, 1.0, 0.0);
    float sphere3_r = 0.4;

    vec3 sphere4_c = vec3(1.3, 1.0, 0.0);
    float sphere4_r = 0.3;

    //// calculate the sdf based on all objects in the scene
    
    //// your implementation starts

    // p.z -= 0.5 * sin(iTime);
    float s1 = sdfPlane(p, plane1_h);
    float s2 = sdfSphere(p, sphere1_c, sphere1_r);
    float s3 = sdfBox(p, box1_c, box1_b);
    float s4 = sdfSubtraction(sdfBox(p, box2_c, box2_b), sdfSphere(p, sphere2_c, sphere2_r));
    float s5 = sdfIntersection(sdfSphere(p, sphere3_c, sphere3_r), sdfSphere(p, sphere4_c, sphere4_r));
    s = sdfUnion(s1, sdfUnion(s2, sdfUnion(s3, sdfUnion(s4, s5))));
    material m;
    m.sdf = s;
    m.id = 1;
    
    if (s2 <= 0.002) m.id = 2;
    if (s3 <= 0.002) m.id = 3;
    if (s4 <= 0.002) m.id = 4;
    if (s5 <= 0.002) m.id = 5;
    // s = sdfUnion(s1, s2);

    //// your implementation ends

    return m;
}

/////////////////////////////////////////////////////
//// Step 7: creative expression
//// You will create your customized sdf scene with new primitives and CSG operations in the sdf2 function.
//// Call sdf2 in your ray marching function to render your customized scene.
/////////////////////////////////////////////////////
float sdEllipsoid( vec3 p, vec3 r )
{
  float k0 = length(p/r);
  float k1 = length(p/(r*r));
  return k0*(k0-1.0)/k1;
}

mat3 rotate3D(vec3 axis, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat3(
        oc * axis.x * axis.x + c,       oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s,
        oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c,       oc * axis.y * axis.z - axis.x * s,
        oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c
    );
}

//// sdf2: p - query point
material sdf2(vec3 p)
{
    float s = 0.0;
    
    //// your implementation starts
    float s1 = sdfPlane(p, -0.1);
    p = rotate3D(vec3(0.0, 1.0, 0.0), 1.14) * p;
    float s2 = sdfSphere(p, vec3(-0.75 + mod(iTime, 3.0), 1.4, 0.0), 0.3);
    float s3 = sdEllipsoid(p - vec3(-1.2 + mod(iTime, 3.0), 1.0, 0.0), vec3(0.7, 0.3, 0.2));
    float s4 = sdfUnion(s2, s3);
    float s5 = sdEllipsoid(p - vec3(-1.2 + mod(iTime, 3.0), 1.0, 0.0), vec3(0.3, 0.1, 0.6));
    float mouth = sdEllipsoid(p - vec3(-0.6 + mod(iTime, 3.0), 1.4, 0.0), vec3(0.3, 0.05, 0.1));

    s = sdfUnion(sdfUnion(sdfUnion(s1, s4), sdfUnion(s4, s5)), mouth);

    material m;
    m.sdf = s;
    m.id = 1;

    if (s4 <= 0.002) m.id = 2;
    if (s5 <= 0.002) m.id = 3;
    if (mouth <= 0.002) m.id = 4;

    //// your implementation ends

    return m;
}


/////////////////////////////////////////////////////
//// ray marching
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
//// Step 4: ray marching
//// You are asked to implement the ray marching algorithm within the following for-loop.
/////////////////////////////////////////////////////

//// ray marching: origin - ray origin; dir - ray direction 
float rayMarching(vec3 origin, vec3 dir)
{
    float s = 0.0;
    float delta = 0.0;
    for(int i = 0; i < 100; i++)
    {
        //// your implementation starts
        vec3 p = origin + dir * s;
        delta = sdf(p).sdf;
        s += delta;
        if (delta < 0.001 || s > 100.0) break;
        //// your implementation ends
    }
    
    return s;
}

/////////////////////////////////////////////////////
//// normal calculation
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
//// Step 5: normal calculation
//// You are asked to calculate the sdf normal based on finite difference.
/////////////////////////////////////////////////////

//// normal: p - query point
vec3 normal(vec3 p)
{
    float s = sdf(p).sdf;          //// sdf value in p
    float dx = 0.01;           //// step size for finite difference

    //// your implementation starts
    
    return normalize(vec3(
        sdf(p + vec3(dx, 0.0, 0.0)).sdf - s,
        sdf(p + vec3(0.0, dx, 0.0)).sdf - s,
        sdf(p + vec3(0.0, 0.0, dx)).sdf - s));

    //// your implementation ends
}

/////////////////////////////////////////////////////
//// Phong shading
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
//// Step 6: lighting and coloring
//// You are asked to specify the color for each object in the scene.
//// Each object must have a separate color without mixing.
//// Notice that we have implemented the default Phong shading model for you.
/////////////////////////////////////////////////////

vec3 phong_shading(vec3 p, vec3 n)
{
    //// background
    if(p.z > 10.0){
        return vec3(0.9, 0.6, 0.2);
    }

    //// phong shading
    vec3 lightPos = vec3(4.*sin(iTime), 4., 4.*cos(iTime));  
    // vec3 lightPos = vec3(4., 4., -4.);  
    vec3 l = normalize(lightPos - p);               
    float amb = 0.1;
    float dif = max(dot(n, l), 0.) * 0.7;
    vec3 eye = CAM_POS;
    float spec = pow(max(dot(reflect(-l, n), normalize(eye - p)), 0.0), 128.0) * 0.9;

    vec3 sunDir = vec3(0, 1, -1);
    float sunDif = max(dot(n, sunDir), 0.) * 0.2;

    //// shadow
    float s = rayMarching(p + n * 0.02, l);
    if(s < length(lightPos - p)) dif *= .2;

    vec3 color = vec3(1.0, 1.0, 1.0);
    material m = sdf(p);
    //// your implementation for coloring starts
    if (m.id == 1) color = vec3(128.0/256.0, 128.0/256.0, 128.0/256.0);
    else if (m.id == 2) color = vec3(0.4, 0.8, 0.1);
    else if (m.id == 3) color = vec3(1.0, 0.0, 0.0);
    else if (m.id == 4) color = vec3(55.0/256.0, 165.0/256.0, 0.8);
    else if (m.id == 5) color = vec3(105.0/256.0, 0.0, 165.0/256.0);

    //// your implementation for coloring ends

    return (amb + dif + spec + sunDif) * color;
}


/////////////////////////////////////////////////////
//// main function
/////////////////////////////////////////////////////

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord.xy - .5 * iResolution.xy) / iResolution.y;         //// screen uv
    vec3 origin = CAM_POS;                                                  //// camera position 
    vec3 dir = normalize(vec3(uv.x, uv.y, 1));                              //// camera direction
    float s = rayMarching(origin, dir);                                     //// ray marching
    vec3 p = origin + dir * s;                                              //// ray-sdf intersection
    vec3 n = normal(p);                                                     //// sdf normal
    vec3 color = phong_shading(p, n);                                       //// phong shading
    fragColor = vec4(color, 1.);                                            //// fragment color
}

void main() 
{
    mainImage(gl_FragColor, gl_FragCoord.xy);
}