#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertColor;

void main() {
	if (!gl_FrontFacing) discard;
  gl_FragColor = vertColor;
}