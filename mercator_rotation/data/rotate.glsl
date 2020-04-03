// The resolution of the graphics the shader is applied to
uniform vec2 resolution;
// The original undeformed mercator projection
uniform sampler2D mercatorTexture;
// Revered rotation matrix
uniform mat3 rotationMatrix;

// PI constant
const float PI  = 3.14159265359;

// Calculating the 3D position of the point on the sphere
// based on latitude and longitude
vec3 sphericalToCartesian(vec2 pos) {
	float sinA = sin(pos.x);
	float cosA = cos(pos.x);
	float sinB = sin(pos.y);
	float cosB = cos(pos.y);
	return vec3(cosB*sinA, sinB, cosB*cosA);
}

// Reverse of the above function
vec2 cartesianToSpherical(vec3 pos) {
	return vec2(PI-atan(pos.x, -pos.z), atan(length(pos.xz), pos.y));
	// TODO - There are some issues on the edge of the deformed image caused by the atan(?)
}

void main() {
	// Every pixel of the mercator image corresponds to a point on the sphere
	// The X and Y position of the pixel is latitude and longitude respectively
	vec2 uv = gl_FragCoord.xy / resolution;
	// Remapping the range from texture coordinates to angles
	vec2 angles = uv * vec2(2.0 * PI, PI) - vec2(0.0, PI*.5);
	// Calculating the position of the point on the sphere based on latitude and longitude
	// And applying the rotation to that point

	// The matrix had to be inverted because the shader is being called for every pixel 
	// of the deformed mercator graphics, so we have to find where that pixel 
	// was in the original mercator image
	vec3 dir = sphericalToCartesian(angles) * rotationMatrix;
	// Calculating the undeformed latitude and longitude of the point 
	// and remapping them into texture coordinates
	uv = cartesianToSpherical(dir) / vec2(2.0 * PI, PI);
	// Setting the color value based on the calculated position in the original projection
	gl_FragColor = texture2D(mercatorTexture, uv);
}