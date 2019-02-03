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
boolean mouseEnabled = false;

void setup() {
  fullScreen(P3D);
  
  
  fx = new PostFX(this);
  noCursor();
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
  noStroke();
  fill(255);
  textSize(50);
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
boolean launch = true;

void draw() {
  drawBackground();
  setProjection();
  lightSetup();
  foodLight();
  PMatrix3D mat = new PMatrix3D();
  getMatrix(mat);
  phongTex.set("model", mat);
  phongTex.set("eatenFood", getFoodPosition(), 3);
  phongTex.set("eatenFoodColor", getFoodColor(), 3);
  phongTex.set("eatenFoodCount", eatenFoodCount);
  phongTex.set("foodBrightness", curFoodBrightness);
  phongTex.set("foodRad", maxR*2);
  shader(phongTex);
  drawSnake();
  noLights();
  fill(255,0,0);
  drawBorder();
  resetShader();
  drawFood();
  drawParticles();
  updateScene();
  perspective();
  fill(255);
  tint(255);
  fx.render().bloom(0.4, 30, 10).compose();
  camera();
  float textHeight = height*0.03;
  textSize(textHeight);
  textAlign(CENTER, CENTER);
  if (paused) {
    if (launch) text("PRESS SPACE TO START", width/2, height*3/4);
    else text("PRESS SPACE TO UNPAUSE", width/2, height*3/4);
    text("USE DIRECTIONAL KEYS TO CONTROL THE SNAKE", width/2, height*3/4+textHeight*1.5);
    text("PRESS CTRL TO ENABLE MOUSE CONTROLS", width/2, height*3/4+textHeight*3.0);
    text("PRESS SHIFT TO FLIP THE VERTICAL AXIS FOR KEYS", width/2, height*3/4+textHeight*4.5);
    text("PRESS ALT TO FLIP THE VERTICAL AXIS FOR MOUSE", width/2, height*3/4+textHeight*6.0);
  } if (gameOver) {
    text("GAME OVER", width/2, height*3/4);
    text("YOU HAVE EATEN " + foodEaten + " STAR" + (foodEaten==1?"":"S"), width/2, height*3/4+textHeight*1.5);
    text("PRESS SPACE TO RESTART", width/2, height*3/4+textHeight*3.0);
  }
}
