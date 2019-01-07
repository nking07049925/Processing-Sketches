#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D image;
uniform vec4 viewport;

void main() {
	vec4 sampleSum = texture(image, gl_FragCoord.xy/viewport.zw);
	float off = 0.4;
	sampleSum += texture(image, (gl_FragCoord.xy + vec2( 0.0, off)) / viewport.zw);
	sampleSum += texture(image, (gl_FragCoord.xy + vec2( 0.0,-off)) / viewport.zw);
	sampleSum += texture(image, (gl_FragCoord.xy + vec2( off, 0.0)) / viewport.zw);
	sampleSum += texture(image, (gl_FragCoord.xy + vec2(-off, 0.0)) / viewport.zw);
	gl_FragColor = sampleSum / 5.0;
}