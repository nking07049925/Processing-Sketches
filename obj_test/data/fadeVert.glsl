/*
  Part of the Processing project - http://processing.org
  Copyright (c) 2012-15 The Processing Foundation
  Copyright (c) 2004-12 Ben Fry and Casey Reas
  Copyright (c) 2001-04 Massachusetts Institute of Technology
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation, version 2.1.
  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.
  You should have received a copy of the GNU Lesser General
  Public License along with this library; if not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA
*/

//Phong shader based on Processing default Gourad shader

uniform mat4 modelviewMatrix;
uniform mat4 transformMatrix;
uniform mat3 normalMatrix;

uniform int lightCount;
uniform vec4 lightPosition[8];
uniform vec3 lightNormal[8];
uniform vec3 lightAmbient[8];
uniform vec3 lightDiffuse[8];
uniform vec3 lightSpecular[8];      
uniform vec3 lightFalloff[8];
uniform vec2 lightSpot[8];

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;

out vec4 vColor;

attribute vec4 ambient;
attribute vec4 specular;
attribute vec4 emissive;
attribute float shininess;

out vec4 vAmbient;
out vec4 vSpecular;
out vec4 vEmissive;
out float vShininess;

out vec3 ecVertex;
out vec3 vEcNormal;
uniform float ftime;

uniform vec3 fadePos;

const float zero_float = 0.0;
const float one_float = 1.0;
const vec3 zero_vec3 = vec3(0);

float f(float x) {
  return -(1.0-smoothstep(0.0,100.0,x))*x/5.0;
}

void main() {  
  vec3 dir = (modelviewMatrix * position).xyz - fadePos;
  float dist = length(dir);
  dir = normalize(dir);
  dir *= f(dist - 30.0 + abs(sin(ftime*0.1 + 3.14159265/2.0))*30.0);
  
  // Vertex in clip coordinates
  gl_Position = transformMatrix * (position + vec4(dir,0.0));
    
  // Vertex in eye coordinates
  ecVertex = vec3(modelviewMatrix * position);
  
  // Normal vector in eye coordinates
  vEcNormal = normalize(normalMatrix * normal);
	
	vColor = color;
	vAmbient = ambient;
	vSpecular = specular;
	vShininess = shininess;
}