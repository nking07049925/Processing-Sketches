#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec2 resolution;

const float radK = 0.45;
const float PI = 3.1415926535;

void main() {
    vec2 pos = gl_FragCoord.xy - resolution * 0.5;
    float rad = min(resolution.x, resolution.y) * radK;
	
    float col = 1.0;
    vec2 pos1 = pos + vec2(rad, 0.0);
    vec2 pos2 = pos - vec2(rad, 0.0);
    float deg1 = atan(pos1.y, pos1.x) * 2.0;
    deg1 = deg1 > 0.0 ? deg1 : 0.0;
    float deg2 = atan(pos2.y, pos2.x) * 2.0;
    deg2 = deg2 < 0.0 ? deg2 : 0.0;
    vec2 c1 = vec2(-rad * 0.25 + cos(deg1) * rad * 0.75, sin(deg1) * rad * 0.75);
    vec2 c2 = vec2( rad * 0.25 - cos(deg2) * rad * 0.75, -sin(deg2) * rad * 0.75);
    float col1 = 1.0 - deg1 / PI;
    float col2 = 1.0 - mod(deg2 + PI, PI) / PI;
    float k1 = sqrt(abs(2.0 + 2.0 * cos(deg1)));
    float k2 = sqrt(abs(2.0 + 2.0 * cos(deg2)));
    float dist1  = min(distance(pos, c1)                    / (rad * 0.25 * k1), 1.0);
    float dist1h = min(distance(pos, vec2( rad * 0.5, 0.0)) / (rad * 0.25),      1.0);
    float dist2  = min(distance(pos, c2)                    / (rad * 0.25 * k2), 1.0);
    float dist2h = min(distance(pos, vec2(-rad * 0.5, 0.0)) / (rad * 0.25),      1.0);
    col += sqrt(1.0 - dist1  * dist1) * col1;
    col -= sqrt(1.0 - dist1h * dist1h) * 0.5;
    col -= sqrt(1.0 - dist2  * dist2) * col2;
    col += sqrt(1.0 - dist2h * dist2h) * 0.5;
        
    // Output to screen
    gl_FragColor = vec4(vec3(col * 0.5), 1.0);
}