import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;
import java.awt.Robot;

int snakeQuality = 20;
PVector[] baseShape = new PVector[snakeQuality];
PVector[] baseNorm = new PVector[snakeQuality];
ArrayList<PosAngle> curve = new ArrayList<PosAngle>();
PosAngle camera;
PVector startCamDir = new PVector(0, 0, 1);
PVector upCamDir = new PVector(0, 1, 0);
float camDist;

float r;
int dist = 3;
int startLength = 200;
float moveSpeed;

boolean frontView = true;

PShader phong;
PShader skySphere;

PImage sky;

PostFX fx;
Robot robot;

void setup() {
  fullScreen(P3D);
  //size(720, 480, P3D);
  fx = new PostFX(this);
  noCursor();
  //noSmooth();
  textureMode(NORMAL);
  phong = loadShader("PhongFrag.glsl", "PhongVert.glsl");
  camDist = (height/2.0) / tan(PI*30.0 / 180.0);
  skySphere = loadShader("skyFrag.glsl");
  skySphere.set("camDist", camDist*0.7);
  sky = loadImage("sky.jpg");
  r = width/60f;
  moveSpeed = r/5;
  //stroke(255);
  //noFill();
  noStroke();
  fill(255);
  for (int i = 0; i < snakeQuality; i++) {
    float deg = -i*TWO_PI/snakeQuality;
    baseShape[i] = new PVector(cos(deg), sin(deg));
  }
  baseNorm = baseShape.clone();/*
  for (int i = -10; i < 11; i++) {
   PMatrix3D temp = new PMatrix3D();
   temp.scale(r);
   curve.add(new PosAngle(
   new PVector(0,0,i*40),
   temp
   ));
   }*/
  for (int i = 0; i < startLength*dist; i++)
    curve.add(new PosAngle());
  camera = new PosAngle();
  try {
    robot = new Robot();
  } 
  catch (Exception e) {
    println("whoops");
  }
}

float rotSpeed = 0.05;

boolean paused;

void draw() {
  drawBackground();
  shader(phong);
  perspective(PI/2.0, (float)width/height, 1.0, camDist * 10.0);
  if (frontView)
    setCamera();
  else
    translate(width/2, height/2);
  fill(#7EC67F);
  ambientLight(28, 28, 28);
  directionalLight(68, 68, 48, -1, 1, -1);
  directionalLight(20, 20, 30, 1, 0, 1);
  //PosAngle pa = curve.get(curve.size()-1);
  lightFalloff(1.0, 0.02, 0.0);
  lightSpecular(255, 255, 255);
  specular(128);
  shininess(30);
  pointLight(120, 120, 120, 0, 0, 0);
  if (!paused) {
    curve.add(camera.copy());
    curve.remove(0);
  }
  drawSnake();
  resetShader();
  noLights();
  fill(255, 255, 255);
  sphere(r);
  updateScene();
  perspective();
  fx.render().bloom(0.9, 30, 10).compose();
}

boolean leftPressed;
boolean rightPressed;
boolean upPressed;
boolean downPressed;

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      leftPressed = true;
    }
    if (keyCode == RIGHT) {
      rightPressed = true;
    }
    if (keyCode == UP) {
      upPressed = true;
    }
    if (keyCode == DOWN) {
      downPressed = true;
    }
  }
  if (key == ' ')
    paused = !paused;
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      leftPressed = false;
    }
    if (keyCode == RIGHT) {
      rightPressed = false;
    }
    if (keyCode == UP) {
      upPressed = false;
    }
    if (keyCode == DOWN) {
      downPressed = false;
    }
  }
}

void updateScene() {
  PVector moveDir = new PVector();
  camera.angle.mult(startCamDir, moveDir);
  moveDir.setMag(moveSpeed);
  if (!paused)
    camera.pos.add(moveDir);
}

void mouseMoved() {
  if (dist(mouseX, mouseY, width/2, height/2) > 1) {
    robot.mouseMove(width/2, height/2);
    float dy = (pmouseY - mouseY)/500f;
    dy = constrain(dy, -rotSpeed, rotSpeed);
    camera.angle.rotateX(dy);
    float dx = (mouseX - pmouseX)/500f;
    dx = constrain(dx, -rotSpeed, rotSpeed);
    camera.angle.rotateY(-dx);
  }
}

void setCamera() {
  PosAngle temp = camera.copy();
  PVector ndir = new PVector();
  PVector nup = new PVector();
  temp.angle.mult(startCamDir, ndir);
  temp.angle.mult(upCamDir, nup);
  temp.pos.sub(PVector.mult(nup, r*4));
  temp.pos.sub(PVector.mult(ndir, r*moveSpeed));
  camera(temp.pos, ndir, nup);
  if (leftPressed) {
    camera.angle.rotateY(rotSpeed);
  }
  if (rightPressed) {
    camera.angle.rotateY(-rotSpeed);
  }
  if (upPressed) {
    camera.angle.rotateX(-rotSpeed);
  }
  if (downPressed) {
    camera.angle.rotateX(rotSpeed);
  }
}

void drawBackground() {
  PMatrix3D rot = camera.angle.get();
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

void drawSnake() {
  int s = curve.size();
  if (s > dist) {
    PVector[] prev = getBase(curve.get(0), 0, s);
    for (int i = dist; i < s-dist; i+=dist) {
      PosAngle pa = curve.get(i);
      PVector[] cur = getBase(pa, i, s);
      drawBase(prev, cur);
      prev = cur;
    }
    if (s%dist>0) {
      PosAngle pa = curve.get(s-1);
      PVector[] cur = getBase(pa, s-1, s);
      drawBase(prev, cur);
    }
  }
}

void drawBase(PVector[] base1, PVector[] base2) {
  pushMatrix();
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < snakeQuality+1; i++) {
    int j = i%snakeQuality;
    normal(base1[j*2]);
    vertex(base1[j*2+1]);
    normal(base2[j*2]);
    vertex(base2[j*2+1]);
  }
  endShape();
  popMatrix();
}

PVector[] getBase(PosAngle pa, int ind, int max) {
  PVector[] temp = new PVector[snakeQuality*2];
  for (int i = 0; i < snakeQuality; i++) {
    PVector curP = baseShape[i];
    PVector curN = baseNorm[i];
    temp[i*2] = new PVector();
    temp[i*2+1] = new PVector();
    pa.angle.mult(curN, temp[i*2]);
    pa.angle.mult(curP, temp[i*2+1]);
    temp[i*2+1].mult(r*sqrt((float)ind/max));
    temp[i*2+1].add(pa.pos);
  }
  return temp;
}

class PosAngle {
  PVector pos;
  PMatrix3D angle;

  PosAngle() {
    this(new PVector(), new PMatrix3D());
  }

  PosAngle(PVector p, PMatrix3D a) {
    pos = p;
    angle = a;
  }

  PosAngle copy() {
    return new PosAngle(pos.copy(), new PMatrix3D(angle));
  }
}

void translate(PVector v) {
  translate(v.x, v.y, v.z);
}

void vertex(PVector v) {
  vertex(v.x, v.y, v.z);
}

void normal(PVector v) {
  normal(v.x, v.y, v.z);
}

void pointLight(float r, float g, float b, PVector p) {
  pointLight(r, g, b, p.x, p.y, p.z);
}

void camera(PVector eye, PVector look, PVector up) {
  PVector center = look.copy();
  center.setMag(camDist);
  center.add(eye);
  camera(eye.x, eye.y, eye.z, center.x, center.y, center.z, up.x, up.y, up.z);
}
