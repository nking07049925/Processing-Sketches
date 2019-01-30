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

uniform mat4 modelviewMatrix;
uniform mat4 transformMatrix;
uniform mat3 normalMatrix;
uniform vec2 texOffset;
uniform mat4 texMatrix;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;
attribute vec2 texCoord;

out vec4 vColor;
out vec4 vertTexCoord;

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

void main() {
  // Vertex in clip coordinates
  gl_Position = transformMatrix * position;
    
  // Vertex in eye coordinates
  ecVertex = vec3(modelviewMatrix * position);
  
  // Normal vector in eye coordinates
  vEcNormal = normalize(normalMatrix * normal);

  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);        
	
	vColor = color;
	vAmbient = ambient;
	vSpecular = specular;
	vShininess = shininess;
}