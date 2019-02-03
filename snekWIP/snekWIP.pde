import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;
import java.awt.Robot;

boolean mouseMove = true;
boolean frontView = true;

PShader phong;
PShader phongTex;
PShader skySphere;
PShader boxShader;
PShader pointShader;

PImage sky;
PImage skin;

PostFX fx;
Robot robot;

boolean gameOver = false;

void setup() {
  fullScreen(P3D);
  //size(1080, 720, P3D);
  fx = new PostFX(this);
  noCursor();
  //noSmooth();
  textureMode(NORMAL);
  phong = loadShader("PhongFrag.glsl", "PhongVert.glsl");
  phongTex = loadShader("PhongTexFrag.glsl", "PhongTexVert.glsl");
  boxShader = loadShader("boxFrag.glsl", "boxVert.glsl");
  pointShader = loadShader("pointFrag.glsl","pointVert.glsl");
  camDist = (height/2.0) / tan(PI*30.0 / 180.0);
  skySphere = loadShader("skyFrag.glsl");
  skySphere.set("camDist", camDist*0.7);
  sky = loadImage("sky.jpg");
  skin = loadImage("skin.jpg");
  //stroke(255);
  //noFill();
  noStroke();
  fill(255);
  textSize(50);/*
  for (int i = -10; i < 11; i++) {
   PMatrix3D temp = new PMatrix3D();
   temp.scale(r);
   curve.add(new PosAngle(
   new PVector(0,0,i*40),
   temp
   ));
   }*/
  snakeSetup();
  sceneSetup();
  initParticles();
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
  setProjection();
  lightSetup();
  foodLight();
  drawSnake();
  noLights();
  fill(255,0,0);
  drawBorder();
  resetShader();
  drawFood();
  drawParticles();
  updateScene();
  perspective();
  fx.render().bloom(0.95, 30, 10).compose();
  fill(255,0,0);
  camera();
  //text(gameOver?"dead":"alive", 0, 50);
  fill(255);
}
