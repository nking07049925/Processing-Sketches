// Main shader responsible for the deformation of the projection
PShader deformationShader;
// Source mercator image
PImage mercatorImage;
// Render target for the sphere
PGraphics sphereGraphics;
// Size of the sphere
float sphereR;
// Render target for the deformed mercator
PGraphics rotateGraphics;
PShape sphereShape;
// Matrix rotations are applied to
PMatrix3D rotationMatrix;

// Screen position of the sphere for mouse interaction
float cx;
float cy;

void setup() {
  fullScreen(P3D);
  fill(255);
  
  mercatorImage = loadImage("tex.png");
  
  // Creating the PGraphics object for the sphere 
  sphereGraphics = createGraphics(width-height, height, P3D);
  sphereR = sphereGraphics.width/2.2;
  cx = height/2 + width/2;
  cy = height/2;
  
  // Creating the PGraphics object for the deformed mercator
  rotateGraphics = createGraphics(height, height/2, P2D);
  rotateGraphics.beginDraw();
  rotateGraphics.image(mercatorImage,0,0);
  rotateGraphics.endDraw();
  
  // Creating the PShape of the sphere
  sphereShape = createShape(SPHERE, sphereR);
  // Setting the texture
  sphereShape.setTexture(mercatorImage);
  // disableStyle is needed to disable stroke
  sphereShape.disableStyle();

  // Loading the shader and setting the texture uniform
  deformationShader = loadShader("rotate.glsl");
  deformationShader.set("mercatorTexture", mercatorImage);

  // Initialising the rotation matrix
  rotationMatrix = new PMatrix3D();
  
  // Setting up text
  textSize(width/40);
  textAlign(CENTER, BOTTOM);
}

void draw() {
  // Updating the sphere PGraphics
  
  sphereGraphics.beginDraw();
  sphereGraphics.background(0);
  // Moving the sphere to the center of the PGraphics
  sphereGraphics.translate(sphereGraphics.width/2, sphereGraphics.height/2);
  // Applying the rotation to the sphere
  sphereGraphics.applyMatrix(rotationMatrix);
  // Compensating the rotation of the texture on the sphere, 
  // so it matches up with the mercator image
  sphereGraphics.rotateY(HALF_PI);
  sphereGraphics.noStroke();
  // Draw the textured sphere
  sphereGraphics.shape(sphereShape);
  sphereGraphics.endDraw();

  // Updating the deformed mercator graphics
  
  // The rotation matrix applied to the mercator has to inverted 
  // so it matches up with the sphere 
  // (explained more in depth in comments in the shader) 
  PMatrix3D tempMatrix = rotationMatrix.get();
  tempMatrix.invert();
  // Setting the rotation matrix uniform in the shader
  deformationShader.set("rotationMatrix", tempMatrix, true);
  rotateGraphics.beginDraw();
  // Applying the shader to the graphics
  rotateGraphics.filter(deformationShader);
  rotateGraphics.endDraw();

  // Drawing the image and graphics to the screen
  image(mercatorImage, 0, 0, height, height/2);
  image(rotateGraphics, 0, height/2, height, height/2);
  image(sphereGraphics, height, 0);
  
  // Showing the message
  text("Press r to reset the rotation", cx, height);
}

// Flag for the inital press being within the sphere
// clicking inside allows the user to drag - rotate
// and clicking outside rotates it around the Z axis
boolean spherePressed = false;

void mousePressed() {
  // Updating the flag
  float cx = height/2 + width/2;
  float cy = height/2;
  spherePressed = dist(mouseX, mouseY, cx, cy) < sphereR*1.05;
}

void mouseReleased() {
  // Updating the flag
  spherePressed = false;
}

void mouseDragged() {
  // Temporary matrix for the current rotation 
  PMatrix3D temp = new PMatrix3D();
  if (spherePressed) {
    // Drag - rotation
    float x = mouseX - pmouseX;
    float y = mouseY - pmouseY;
    // Rotating by an angle that is equivalent to the distance the mouse moved
    float angle = mag(x, y) / sphereR;
    // Applying the rotation to the temporary matrix
    temp.rotate(angle, -y, x, 0);
  } else {
    // Z rotation
    // The sphere is rotated based on the change of the angle of the mouse
    // relative to the center of the sphere
    
    // Current angle
    float currentAngle = atan2(mouseY - cy, mouseX - cx);
    // Previous angle
    float previousAngle = atan2(pmouseY - cy, pmouseX - cx);
    // Applying the rotation to the temporary matrix
    temp.rotateZ(currentAngle - previousAngle);
  }
  // Applying the temporary rotation to the main matrix
  rotationMatrix.preApply(temp);
}

// Resetting the rotation when pressing the R key
void keyPressed() {
  if (key == 'r') {
    rotationMatrix.reset();
  }
}
