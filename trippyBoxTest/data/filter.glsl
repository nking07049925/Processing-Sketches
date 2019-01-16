#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D image;
uniform vec4 viewport;

varying vec4 vertColor;
varying vec4 backVertColor;
varying vec4 maskColor;

void main() {
	vec2 uv = gl_FragCoord.xy / viewport.zw;
	vec4 mask = texture(image, uv);
	if (distance(mask, maskColor) > 0.001) discard;
  gl_FragColor = gl_FrontFacing ? vertColor : backVertColor;
}