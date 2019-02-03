Segment camera;
PVector startDir = new PVector(0, 0, 1);
PVector upCamDir = new PVector(0, 1, 0);
float camDist;

float boxSide;
int collisionInd = -1;
float petrifyInd = 0;
float clearInd = 0;
int step = 0;

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
  boxSide = maxR*50;
  setFood();
}

void updateScene() {
  if (!paused && !gameOver) {
    moveSpeed += (desiredSpeed - moveSpeed)*speedEasing;
    PVector moveDir = new PVector();
    head.mat.mult(startDir, moveDir);
    moveDir.setMag(moveSpeed);
    head.pos.add(moveDir);
    camera.mat = head.mat.get();
    camera.pos = head.pos.copy();
    Segment temp = head.copy();
    snake.add(head);
    head = temp.copy();
    if (snake.size() >= curSnakeLength * dist) {
      if (eatenFoodCount > 0 && snake.get(0) == eaten[0].seg) {
        removeFood();
      }
      snake.remove(0);
    }
    for (int i = 0; i < snake.size(); i++)
      snake.get(i).updateRad(i, snake.size());
    head.mat.mult(startDir, headPos);
    headPos.setMag(headLength * 2/3);
    headPos.add(head.pos);
  }
  curFoodR = constrain(headPos.dist(foodPos)-maxR, 0, foodR);
  if (curFoodR <= maxR*0.5) {
    foodEaten++;
    addFood(head);
    setFood();
    curSnakeLength += snakeIncrease;
    desiredSpeed += speedIncrease;
  }
  if (checkBorder(headPos)) {
    gameOver = true;
    collisionInd = snake.size() + headSize;
  } else {
    if (checkSelfCollision(headPos)) {
      gameOver = true;
    }
  }
  if (gameOver) {
    curFoodBrightness *= 0.95;
    petrifyInd += step * 0.04;
    particleSpeed = step;
    clearInd = petrifyInd/2;
    step++;
  }
  phongTex.set("backCull", !gameOver);
  turnSnake();
}

boolean checkBorder(PVector pos) {
  if (abs(pos.x) > boxSide/2 - maxR) return true;
  if (abs(pos.y) > boxSide/2 - maxR) return true;
  if (abs(pos.z) > boxSide/2 - maxR) return true;
  return false;
}

boolean checkSelfCollision(PVector pos) {
  for (int i = 0; i < snake.size(); i++) {
    Segment s = snake.get(i);
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
  temp.pos.sub(PVector.mult(ndir, maxR*3 + maxR*moveSpeed*0.3));
  camera(temp.pos, ndir, nup);
}

void drawBorder() {
  fill(255, 255, 255);
  boxShader.set("pointPos", headPos.x, headPos.y, headPos.z, 1.0);
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
