uniform mat4 transformMatrix;
uniform mat4 modelviewMatrix;
uniform mat4 texMatrix;

uniform vec3 pos;

attribute vec4 position;
attribute vec4 color;

attribute vec2 texCoord;

varying vec4 vertColor;
varying vec3 vertPos;
varying vec4 vertTexCoord;

void main() {
  gl_Position = transformMatrix * position;
    
  vertPos = (modelviewMatrix * position).xyz;
  vertColor = color;
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);
}