uniform mat4 transformMatrix;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;

varying vec4 vertColor;

void main() {
  gl_Position = transformMatrix * position;

  vertColor = color;
}