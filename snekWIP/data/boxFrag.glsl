#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec4 pointPos;
uniform mat4 model;
uniform float boxSide;
uniform float start;

//uniform vec3 pos;
const float a = 0.2;
//const float b = 0.01;
const float w = 0.01;
const float d = 0.0003;

const float steps = 4.0;

varying vec4 vertColor;
varying vec3 vertPos;
varying vec4 vertTexCoord;

float grid(vec2 x, float side, float pixel, float smoothDist) {
	vec2 temp = smoothstep(side - pixel/2.0, side - pixel/2.0 + smoothDist, x);
	temp += (1.0 - smoothstep(pixel/2.0 - smoothDist, pixel/2.0, x));
	return temp.x * temp.y;
}

void main() {
	if (gl_FrontFacing)
		discard;

	vec3 pos = (pointPos * model).xyz;
	vec4 col = vertColor;

	float dist = distance(vertPos, pos);
	vec2 x = vertTexCoord.xy;
	col.a = 0.0;
	for (float i = 0.0; i < steps; i++) {
		float tr = (steps - i) * start / steps;
    if (dist < tr) {
    	float projR = 0.0;
    	float side = a / pow(2.0, i + 1.0);
    	vec2 dx = mod(x, side);
    	float distCoeff = 1.0 - smoothstep(tr - d * boxSide, tr, dist);
    	float indCoeff = (i+1.0)/steps;
      col.a = max(col.a, grid(dx, side, w, d) * indCoeff * distCoeff * 0.9);
    }
  }
  gl_FragColor = col;
}