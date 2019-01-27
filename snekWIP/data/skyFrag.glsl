#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

const float PI = 3.14159265359;

uniform sampler2D texture;
uniform vec2 texOffset;
uniform float camDist;
uniform vec4 viewport;
uniform mat3 rot;

varying vec4 vertColor;
varying vec4 vertTexCoord;

// getting the color from a panoramic background image using a directional vector
vec3 getSkybox(vec3 dir) {
	// cartesian to spherical
	float sqrtXZ = sqrt(dir.x * dir.x + dir.z * dir.z);
	vec2 angles = vec2(atan(-dir.z, dir.x) + PI,
  	atan(-dir.y, sqrtXZ) + 0.5 * PI);
  // normalizing coords
	vec2 texPos = angles / vec2(2.0 * PI, PI);
	return texture2D(texture, texPos).xyz;
}

void main() {
	vec3 viewDir = rot * vec3(gl_FragCoord.xy - viewport.zw * 0.5, -camDist);
	gl_FragColor = vec4(getSkybox(viewDir), 1.0);
}