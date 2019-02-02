Segment camera;
PVector startDir = new PVector(0, 0, 1);
PVector upCamDir = new PVector(0, 1, 0);
float camDist;

float boxSide;
int collisionInd = -1;
int petrifyInd = -1;

void drawBackground() {
  PMatrix3D rot = camera.mat.get();
  rot.invert();
  skySphere.set("rot", rot, true);
  shader(skySphere);
  hint(DISABLE_DEPTH_TEST);
  camera();
  beginShape();
  texture(sky);
  vertex(0, 0, 0, 0, 0);
  vertex(width, 0, 0, 1, 0);
  vertex(width, height, 0, 1, 1);
  vertex(0, height, 0, 0, 1);
  endShape();
  hint(ENABLE_DEPTH_TEST);
}

void setProjection() {
  perspective(PI/2.0, (float)width/height, 1.0, camDist * 10.0);
  if (frontView) {
    //beginCsetCamerasetCamera()ProjectionendCamera();
    beginCamera();
    setCamera();
    endCamera();
  } else {
    translate(width/2, height/2);
  }
}

void sceneSetup() {
  camera = new Segment();
  setFood();
  boxSide = maxR*50;
}

void updateScene() {
  PVector moveDir = new PVector();
  head.mat.mult(startDir, moveDir);
  moveDir.setMag(moveSpeed);
  if (!paused) {
    head.pos.add(moveDir);
    camera.pos = head.pos.copy();
    curve.add(camera.copy());
    curve.remove(0);
    for (int i = 0; i < curve.size(); i++)
      curve.get(i).updateRad(i, curve.size());
  }
  PVector pos = new PVector();
  head.mat.mult(startDir, pos);
  pos.setMag(headLength * 2/3);
  pos.add(head.pos);
  curFoodR = constrain(pos.dist(foodPos)-maxR,0,foodR);
  if (checkBorder(pos)) {
    gameOver = true;
    collisionInd = curve.size();
  } else {
    if (checkSelfCollision(pos)) {
      gameOver = true;
    }
  }
  if (gameOver)
    petrifyInd+=3;
  paused = gameOver;
}

boolean checkBorder(PVector pos) {
  if (abs(pos.x) > boxSide/2 - maxR) return true;
  if (abs(pos.y) > boxSide/2 - maxR) return true;
  if (abs(pos.z) > boxSide/2 - maxR) return true;
  return false;
}

boolean checkSelfCollision(PVector pos) {
  for (int i = 0; i < curve.size(); i++) {
    Segment s = curve.get(i);
    if (PVector.sub(pos, s.pos).mag() < maxR + s.r) {
      collisionInd = i;
      return true;
    }
  }
  return false;
}

void lightSetup() {
  ambientLight(28, 28, 28);
  directionalLight(68, 68, 48, -1, 1, -1);
  directionalLight(20, 20, 30, 1, 0, 1);
}
  
void setCamera() {  
  Segment temp = camera.copy();
  PVector ndir = new PVector();
  PVector nup = new PVector();
  temp.mat.mult(startDir, ndir);
  temp.mat.mult(upCamDir, nup);
  temp.pos.sub(PVector.mult(nup, maxR*4));
  temp.pos.sub(PVector.mult(ndir, maxR*moveSpeed));
  camera(temp.pos, ndir, nup);
}

void drawBorder() {
  fill(255, 255, 255);
  PVector pos = new PVector();
  head.mat.mult(startDir, pos);
  pos.setMag(headLength * 2/3);
  pos.add(head.pos);
  boxShader.set("pointPos", pos.x, pos.y, pos.z, 1.0);
  PMatrix3D mat = new PMatrix3D();
  getMatrix(mat);
  boxShader.set("model", mat);
  boxShader.set("boxSide", boxSide);
  boxShader.set("start", boxSide*0.4);
  shader(boxShader);
  border(boxSide);
}

void border(float a) {
  float x1 = -a/2;
  float x2 =  a/2;
  float y1 = -a/2;
  float y2 =  a/2;
  float z1 = -a/2;
  float z2 =  a/2;
  float u1 = 0;
  float u2 = 1;
  float v1 = 0;
  float v2 = 1;
  beginShape(QUADS);
  // front
  normal(0, 0, 1);
  vertex(x2, y1, z1, u2, v1);
  vertex(x1, y1, z1, u1, v1);
  vertex(x1, y2, z1, u1, v2);
  vertex(x2, y2, z1, u2, v2);

  // right
  normal(1, 0, 0);
  vertex(x2, y1, z2, u2, v1);
  vertex(x2, y1, z1, u1, v1);
  vertex(x2, y2, z1, u1, v2);
  vertex(x2, y2, z2, u2, v2);

  // back
  normal(0, 0, -1);
  vertex(x1, y1, z2, u2, v1);
  vertex(x2, y1, z2, u1, v1);
  vertex(x2, y2, z2, u1, v2);
  vertex(x1, y2, z2, u2, v2);

  // left
  normal(-1, 0, 0);
  vertex(x1, y1, z1, u2, v1);
  vertex(x1, y1, z2, u1, v1);
  vertex(x1, y2, z2, u1, v2);
  vertex(x1, y2, z1, u2, v2);

  // top
  normal(0, 1, 0);
  vertex(x2, y1, z2, u2, v1);
  vertex(x1, y1, z2, u1, v1);
  vertex(x1, y1, z1, u1, v2);
  vertex(x2, y1, z1, u2, v2);

  // bottom
  normal(0, -1, 0);
  vertex(x2, y2, z1, u2, v1);
  vertex(x1, y2, z1, u1, v1);
  vertex(x1, y2, z2, u1, v2);
  vertex(x2, y2, z2, u2, v2);
  endShape();
}
