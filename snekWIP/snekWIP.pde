import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;
import java.awt.Robot;

int snakeQuality = 20;
PVector[] baseShape = new PVector[snakeQuality];
PVector[] baseNorm = new PVector[snakeQuality];
ArrayList<Segment> curve = new ArrayList<Segment>();
int headSize = 7;
Segment[] head = new Segment[headSize];
float[][] headNormals = new float[headSize][2];
float headLength;
Segment camera;
PVector startCamDir = new PVector(0, 0, 1);
PVector upCamDir = new PVector(0, 1, 0);
float camDist;

float maxR;
int dist = 3;
int startLength = 200;
float moveSpeed;

boolean mouseMove = true;
boolean frontView = true;

PShader phong;
PShader phongTex;
PShader skySphere;

PImage sky;
PImage skin;

PostFX fx;
Robot robot;

float offs = 0.3;
float headFunc(float x) {
  return x < 0.5 ? 1+(1-cos(x*TWO_PI))/2*offs : sqrt(1-sq(2*x-1))*(1+offs);
}
float headAngleFunc(float x) {
  return x < 0.5 ? atan(sin(x*TWO_PI)*PI*offs)+HALF_PI : atan(-2*(1+offs)*(2*x-1)/sqrt(1-sq(2*x-1)))+HALF_PI;
}

void setup() {
  fullScreen(P3D);
  //size(1080, 720, P3D);
  fx = new PostFX(this);
  noCursor();
  //noSmooth();
  textureMode(NORMAL);
  phong = loadShader("PhongFrag.glsl", "PhongVert.glsl");
  phongTex = loadShader("PhongTexFrag.glsl", "PhongTexVert.glsl");
  camDist = (height/2.0) / tan(PI*30.0 / 180.0);
  skySphere = loadShader("skyFrag.glsl");
  skySphere.set("camDist", camDist*0.7);
  sky = loadImage("sky.jpg");
  skin = loadImage("skin.jpg");
  maxR = width/60f;
  moveSpeed = maxR/5;
  //stroke(255);
  //noFill();
  noStroke();
  fill(255);
  for (int i = 0; i < snakeQuality; i++) {
    float deg = -(i-0.5)*TWO_PI/snakeQuality - HALF_PI;
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
  int max = startLength*dist;
  headLength = maxR*4.0;
  for (int i = 0; i < max; i++)
    curve.add(new Segment());
    
  for (int i = 0; i < headSize; i++) {
    float x = i/(headSize-1f);
    head[i] = new Segment(new PVector(0, 0, x*headLength), new PMatrix3D(), maxR*headFunc(x));
    float deg = headAngleFunc(x);
    headNormals[i] = new float[] { cos(deg)*maxR/headLength, sin(deg) };
  }
  camera = new Segment();
  try {
    robot = new Robot();
  } 
  catch (Exception e) {
    println("whoops");
  }
}

float rotSpeed = 0.05;

boolean paused = true;

void draw() {
  drawBackground();
  shader(phongTex);
  perspective(PI/2.0, (float)width/height, 1.0, camDist * 10.0);
  if (frontView)
    setCamera();
  else
    translate(width/2, height/2);
  ambientLight(28, 28, 28);
  directionalLight(68, 68, 48, -1, 1, -1);
  directionalLight(20, 20, 30, 1, 0, 1);
  //PosAngle pa = curve.get(curve.size()-1);
  lightFalloff(1.0, 0.02, 0.0);
  lightSpecular(255, 255, 255);
  specular(188);
  shininess(50);
  emissive(255);
  pointLight(255, 255, 255, 0, 0, 0);
  if (!paused) {
    curve.add(camera.copy());
    curve.remove(0);
    for (int i = 0; i < curve.size(); i++)
      curve.get(i).updateRad(i, curve.size());
  }
  drawSnake();
  resetShader();
  noLights();
  fill(255, 255, 255);
  sphere(maxR);
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
  camera.mat.mult(startCamDir, moveDir);
  moveDir.setMag(moveSpeed);
  if (!paused)
    camera.pos.add(moveDir);
}

void mouseMoved() {
  if (dist(mouseX, mouseY, width/2, height/2) > 1 && mouseMove) {
    robot.mouseMove(width/2, height/2);
    float dy = (pmouseY - mouseY)/500f;
    dy = constrain(dy, -rotSpeed, rotSpeed);
    camera.mat.rotateX(dy);
    float dx = (mouseX - pmouseX)/500f;
    dx = constrain(dx, -rotSpeed, rotSpeed);
    camera.mat.rotateY(-dx);
  }
}

void setCamera() {
  Segment temp = camera.copy();
  PVector ndir = new PVector();
  PVector nup = new PVector();
  temp.mat.mult(startCamDir, ndir);
  temp.mat.mult(upCamDir, nup);
  temp.pos.sub(PVector.mult(nup, maxR*4));
  temp.pos.sub(PVector.mult(ndir, maxR*moveSpeed));
  camera(temp.pos, ndir, nup);
  if (leftPressed) {
    camera.mat.rotateY(rotSpeed);
  }
  if (rightPressed) {
    camera.mat.rotateY(-rotSpeed);
  }
  if (upPressed) {
    camera.mat.rotateX(-rotSpeed);
  }
  if (downPressed) {
    camera.mat.rotateX(rotSpeed);
  }
}

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

void drawSnake() {
  //fill(#7EC67F);
  //fill(0);
  int s = curve.size();
  Segment last = curve.get(s - 1);
  if (s > dist) {
    PVector[] prev = getBase(curve.get(0));
    for (int i = dist; i < s; i+=dist) {
      Segment pa = curve.get(i);
      PVector[] cur = getBase(pa);
      drawBase(prev, cur);
      prev = cur;
    }
    PVector[] cur = getBase(last);
    drawBase(prev, cur);
    pushMatrix();
    translate(last.pos);
    applyMatrix(last.mat);
    drawHead();
    shader(phong);
    fill(0);
    tint(255);
    specular(190);
    shininess(50);
    float eyeDist = maxR*1.0;
    float eyeR = maxR*0.2;
    translate(0,-maxR,headLength*0.8);
    fill(0);
    translate(eyeDist/2,0,0);
    sphere(eyeR);
    translate(-eyeDist,0,0);
    sphere(eyeR);
    popMatrix();
  }
}

void drawHead() {
  for (int i = 0; i < headSize-1; i++) {
    drawBase(getHeadBase(head[i], i), getHeadBase(head[i+1], i+1));
  }
}

void drawBase(PVector[] base1, PVector[] base2) {
  pushMatrix();
  beginShape(TRIANGLE_STRIP);
  texture(skin);
  for (int i = 0; i < snakeQuality+1; i++) {
    int j = i%snakeQuality;
    float pos = (float)i/snakeQuality;
    float k = 0.3;
    if (pos > k && pos < 1-k)
      tint(#F8FFE5);
    else
      tint(#4D984D);
    normal(base1[j*2]);
    vertex(base1[j*2+1], pos, 0);
    normal(base2[j*2]);
    vertex(base2[j*2+1], pos, 1);
  }
  endShape();
  popMatrix();
}

PVector[] getBase(Segment seg) {
  PVector[] temp = new PVector[snakeQuality*2];
  for (int i = 0; i < snakeQuality; i++) {
    PVector curP = baseShape[i];
    PVector curN = baseNorm[i];
    temp[i*2] = new PVector();
    temp[i*2+1] = new PVector();
    seg.mat.mult(curN, temp[i*2]);
    seg.mat.mult(curP, temp[i*2+1]);
    temp[i*2+1].mult(seg.r);
    temp[i*2+1].add(seg.pos);
  }
  return temp;
}

PVector[] getHeadBase(Segment seg, int ind) {
  PVector[] temp = new PVector[snakeQuality*2];
  for (int i = 0; i < snakeQuality; i++) {
    PVector curP = baseShape[i];
    PVector curN = baseNorm[i].copy();
    curN.setMag(headNormals[ind][1]);
    curN.z = headNormals[ind][0];
    temp[i*2] = new PVector();
    temp[i*2+1] = new PVector();
    seg.mat.mult(curN, temp[i*2]);
    seg.mat.mult(curP, temp[i*2+1]);
    temp[i*2+1].mult(seg.r);
    temp[i*2+1].add(seg.pos);
  }
  return temp;
}

class Segment {
  PVector pos;
  PMatrix3D mat;
  float r;

  Segment() {
    this(new PVector(), new PMatrix3D(), 1);
  }

  Segment(float rad) {
    this(new PVector(), new PMatrix3D(), rad);
  }

  Segment(PVector p, PMatrix3D a, float rad) {
    pos = p;
    mat = a;
    r = rad;
  }

  Segment copy() {
    return new Segment(pos.copy(), new PMatrix3D(mat), r);
  }

  void updateRad(int ind, int max) {
    r = maxR*sqrt((float)ind/max);
  }
}

void translate(PVector v) {
  translate(v.x, v.y, v.z);
}

void vertex(PVector v) {
  vertex(v.x, v.y, v.z);
}

void vertex(PVector vec, float u, float v) {
  vertex(vec.x, vec.y, vec.z, u, v);
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
