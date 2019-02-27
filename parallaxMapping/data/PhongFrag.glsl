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
 
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform int lightCount;
uniform vec4 lightPosition[8];
uniform vec3 lightNormal[8];
uniform vec3 lightAmbient[8];
uniform vec3 lightDiffuse[8];
uniform vec3 lightSpecular[8];      
uniform vec3 lightFalloff[8];
uniform vec2 lightSpot[8];
uniform sampler2D texture;
uniform sampler2D heightMap;
uniform sampler2D normalMap;
uniform sampler2D sky;

in vec4 vAmbient;
in vec4 vSpecular;
in vec4 vEmissive;
in vec4 vDiffuse;
in float vShininess;

in vec4 vertTexCoord;

in vec4 vColor;

in vec3 ecVertex;
in vec3 vNormal;
in vec3 vTangent;

const float zero_float = 0.0;
const float one_float = 1.0;
const vec3 zero_vec3 = vec3(0);

const float height_scale = 0.1;
const float PI = 3.14159265359;

float falloffFactor(vec3 lightPos, vec3 vertPos, vec3 coeff) {
  vec3 lpv = lightPos - vertPos;
  vec3 dist = vec3(one_float);
  dist.z = dot(lpv, lpv);
  dist.y = sqrt(dist.z);
  return one_float / dot(dist, coeff);
}

float spotFactor(vec3 lightPos, vec3 vertPos, vec3 lightNorm, float minCos, float spotExp) {
  vec3 lpv = normalize(lightPos - vertPos);
  vec3 nln = -one_float * lightNorm;
  float spotCos = dot(nln, lpv);
  return spotCos <= minCos ? zero_float : pow(spotCos, spotExp);
}

float lambertFactor(vec3 lightDir, vec3 vecNormal) {
  return max(zero_float, dot(lightDir, vecNormal));
}

float blinnPhongFactor(vec3 lightDir, vec3 vertPos, vec3 vecNormal, float shine) {
  vec3 np = normalize(vertPos);
  vec3 ldp = normalize(lightDir - np);
  return pow(max(zero_float, dot(ldp, vecNormal)), shine);
}

vec2 parallaxMap(vec2 texCoords, vec3 viewDir) {
  const float numLayers = 30.0;
  float layerHeight = 1.0 / numLayers;
  float currentLayerHeight = 1.0;
  vec2 p = viewDir.xy / viewDir.z * height_scale * vec2(1.0, -1.0);
  //vec2 p = -viewDir.xy * height_scale * 0.001 * vec2(1.0, -1.0);
  vec2 deltaTexCoords = p / numLayers;
  vec2  currentTexCoords      = texCoords;
  float currentHeightMapValue = texture(heightMap, currentTexCoords).r;
  float prevHeightMapValue = 1.0 + layerHeight;

  while(currentLayerHeight > currentHeightMapValue) {
    currentTexCoords += deltaTexCoords;
    prevHeightMapValue = currentHeightMapValue;
    currentHeightMapValue = texture(heightMap, currentTexCoords).r;
    currentLayerHeight -= layerHeight;  
  }

  float hPrev = prevHeightMapValue - currentLayerHeight - layerHeight;
  float hCur = currentHeightMapValue - currentLayerHeight;

  return currentTexCoords - deltaTexCoords * hCur / (hCur - hPrev);
  //return currentTexCoords;
}

// getting the color from a panoramic background image using a directional vector
vec3 getSkybox(vec3 dir) {
  // cartesian to spherical
  float sqrtXZ = sqrt(dir.x * dir.x + dir.z * dir.z);
  vec2 angles = vec2(atan(-dir.z, dir.x) + PI,
    atan(dir.y, sqrtXZ) + 0.5 * PI);
  // normalizing coords
  vec2 texPos = angles / vec2(2.0 * PI, PI);
  return texture2D(sky, texPos).xyz;
  //return vec3(texPos, 0.0);
}

void main() {
	vec3 ecNormal = normalize(vNormal);
  vec3 tangent = normalize(vTangent);
  vec3 binormal = cross(ecNormal, tangent);

  mat3 objLocal = transpose(mat3(tangent, binormal, ecNormal));
  mat3 invLocal = inverse(objLocal);

  vec3 viewDir = objLocal * ecVertex;

  //vec4 color = vec4(getSkybox(invLocal * viewDir), 1.0);

  vec2 uv = parallaxMap(vertTexCoord.st, viewDir);
	
	vec4 color = vColor * texture2D(texture, uv);

  vec3 normal = normalize(vec3(2.0 * texture2D(normalMap, uv) - 1.0));
  vec3 normalInv = -normal;

  vec3 refl = reflect(viewDir, normal);
  vec3 reflCol = mix(getSkybox(invLocal * refl), vec3(1.0), 0.2);
  color *= vec4(reflCol, 1.0);
	
	vec4 ambient = vAmbient;
	vec4 specular = vSpecular;
	vec4 emissive = vEmissive;
  vec4 diffuse = vDiffuse;
	float shininess = vShininess;
	
	// Light calculations
  //vec3 totalAmbient = color.rgb;
  vec3 totalAmbient = vec3(0, 0, 0);
  
  vec3 totalFrontDiffuse = vec3(0, 0, 0);
  vec3 totalFrontSpecular = vec3(0, 0, 0);
  
  vec3 totalBackDiffuse = vec3(0, 0, 0);
  vec3 totalBackSpecular = vec3(0, 0, 0);
  
  for (int i = 0; i < 8; i++) {
    if (lightCount == i) break;
    
    vec3 lightPos = lightPosition[i].xyz;
    bool isDir = lightPosition[i].w < one_float;
    float spotCos = lightSpot[i].x;
    float spotExp = lightSpot[i].y;
    
    vec3 lightDir;
    float falloff;    
    float spotf;
      
    if (isDir) {
      falloff = one_float;
      lightDir = -one_float * lightNormal[i];
    } else {
      falloff = falloffFactor(lightPos, ecVertex, lightFalloff[i]);  
      lightDir = normalize(lightPos - ecVertex);
    }

    lightDir = objLocal * lightDir;
  
    spotf = spotExp > zero_float ? spotFactor(lightPos, ecVertex, lightNormal[i], 
                                              spotCos, spotExp) 
                                 : one_float;
    
    if (any(greaterThan(lightAmbient[i], zero_vec3))) {
      totalAmbient       += lightAmbient[i] * falloff;
    }
    
    if (any(greaterThan(lightDiffuse[i], zero_vec3))) {
      totalFrontDiffuse  += lightDiffuse[i] * falloff * spotf * 
                            lambertFactor(lightDir, normal);
      totalBackDiffuse   += lightDiffuse[i] * falloff * spotf * 
                            lambertFactor(lightDir, normalInv);
    }
    
    if (any(greaterThan(lightSpecular[i], zero_vec3))) {
      totalFrontSpecular += lightSpecular[i] * falloff * spotf * 
                            blinnPhongFactor(lightDir, viewDir, normal, shininess);
      totalBackSpecular  += lightSpecular[i] * falloff * spotf * 
                            blinnPhongFactor(lightDir, viewDir, normalInv, shininess);
    }     
  }    

  // Calculating final color as result of all lights (plus emissive term).
  // Transparency is determined exclusively by the diffuse component.
  vec4 vertColor =			vec4(totalAmbient, 0.0) * ambient+ 
												vec4(totalFrontDiffuse, 1.0) * diffuse + 
												vec4(totalFrontSpecular, 0.0) * specular + 
												vec4(emissive.rgb, 0.0);
              
  vec4 backVertColor = 	vec4(totalAmbient, 0.0) * ambient + 
												vec4(totalBackDiffuse, 1.0) * diffuse + 
												vec4(totalBackSpecular, 0.0) * specular + 
												vec4(emissive.rgb, 0.0);
	
  gl_FragColor = color * (gl_FrontFacing ? vertColor : backVertColor);
}