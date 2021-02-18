const float PI = 3.1415926535897932384626433832795;
uniform vec3 uColor;
uniform vec3 uPosition;
uniform vec3 uRotation;

uniform sampler2D uTexture;
uniform float uFrequency;

varying vec2 vUv;
varying float vElevation;
varying float vTime;

float random(vec2 st)
{
  return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

//	Classic Perlin 2D Noise
//	by Stefan Gustavson
//
vec4 permute(vec4 x)
{
    return mod(((x*34.0)+1.0)*x, 289.0);
}


vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec2 P){
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;
  vec4 i = permute(permute(ix) + iy);
  vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;
  vec2 g00 = vec2(gx.x,gy.x);
  vec2 g10 = vec2(gx.y,gy.y);
  vec2 g01 = vec2(gx.z,gy.z);
  vec2 g11 = vec2(gx.w,gy.w);
  vec4 norm = 1.79284291400159 - 0.85373472095314 *
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;
  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));
  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}



vec3 cosPalette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

float circ(vec2 p){
  float r = 0.2;
  return length(p) + r;
}



float sdEquilateralTriangle( in vec2 p )
{
    const float k = sqrt(3.0);

    p.x = abs(p.x) - 1.0;
    p.y = p.y + 1.0/k;
    if( p.x + k*p.y > 0.0 ) p = vec2( p.x - k*p.y, -k*p.x - p.y )/2.0;
    p.x -= clamp( p.x, -2.0, 0.0 );
    return -length(p)*sign(p.y);
}

void pMod2(inout vec2 p, vec2 size){
  p = mod(p, size) -size * 0.5;
}


float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,vec2(0))) + min(max(d.x,d.y),0.0);
}

float pModPolar(inout vec2 p, float repetitions) {
    float angle = 2.*PI/repetitions;
    float a = atan(p.y, p.x) + angle/2.;
    float r = length(p);
    float c = floor(a/angle);
    a = mod(a,angle) - angle/2.;
    p = vec2(cos(a), sin(a))*r;
    // For an odd number of repetitions, fix cell index of the cell in -x direction
    // (cell index would be e.g. -5 and 5 in the two halves of the cell):
    if (abs(c) >= (repetitions/2.)) c = abs(c);
    return c;
}



void main()
{

vec2 pos = vUv - 0.5;
vec2 size = vec2(0.5, 0.5);
pModPolar(pos, cos(vTime * 0.2)*8.0);
pModPolar(pos, sin(vTime * 0.2)*4.0);


vec3 brightness = vec3(cos(vTime * 0.5));
vec3 contrast = vec3(sin(vTime * 0.5));
vec3 contrast2 = vec3(0.6);
vec3 osc = vec3(0.4,0.3,0.2);
vec3 phase = vec3(0.5);

float shape = circ(pos);
pModPolar(pos, cos(vTime * 0.2)*4.0);
float shape2 = sdEquilateralTriangle(pos);


pos -= vec2(sin(vTime) * 0.2, cos(vTime) * 0.2);

float shape3 = sdBox(pos, vec2(0.09));
shape3 = ceil(shape3);

vec3 col = cosPalette((vTime* 0.2) + min(shape, shape3), brightness, contrast, osc, phase);
vec3 col2 = cosPalette((vTime* 0.2) + shape2, brightness, contrast2, osc, phase);

float strength = cnoise(vUv * 10.0+sin(vTime)*2.0 + +cos(vTime));

col *= col2;

col.r *= strength;

gl_FragColor = vec4(col, 0.8);

}
