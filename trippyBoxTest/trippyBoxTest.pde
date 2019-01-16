PGraphics mainScene, secScene;
PShape[] shapes = new PShape[6];
PShape cube;
PShape cross;
float boxSize;
float boxWeight;

PShader backDiscard;
PShader filterShader;

void setup() {
  fullScreen(P3D);
  //size(720,480,P3D);
  mainScene = createGraphics(width, height, P3D);
  secScene = createGraphics(width, height, P3D);
  boxSize = height/2;
  boxWeight = boxSize/6;
  //stroke(0);
  noStroke();
  fill(255);
  textSize(20);
  cube = getCube(boxSize, boxWeight);
  cross = getCross(boxSize, boxSize/6);
  backDiscard = loadShader("backFrag.glsl", "backVert.glsl");
  filterShader = loadShader("filter.glsl", "lightVert.glsl");
}

float rotY = -HALF_PI;
float rotX = 0;

boolean drawPanels = false;
boolean useShader = true;

void draw() {
  mainScene.beginDraw();
  mainScene.resetShader();
  mainScene.noStroke();
  mainScene.fill(255);
  mainScene.background(0);
  mainScene.translate(width/2, height/2);
  mainScene.ambientLight(128, 128, 128);
  mainScene.directionalLight(128, 128, 128, -1, 1, -1);
  //mainScene.pushMatrix();
  mainScene.rotateX(rotX);
  mainScene.rotateY(rotY);
  mainScene.shape(cube);
  //mainScene.popMatrix();
  secScene.beginDraw();
  secScene.shader(backDiscard);
  secScene.rectMode(CENTER);
  secScene.noStroke();
  secScene.fill(255, 0, 0);
  secScene.clear();
  secScene.translate(width/2, height/2);
  secScene.rotateX(rotX);
  secScene.rotateY(rotY);
  float a = boxSize/2;
  float b = a - boxWeight/4;
  secScene.beginShape(QUADS);
  secScene.fill(255, 200, 200);
  secScene.vertex( b, b, a);
  secScene.vertex(-b, b, a);
  secScene.vertex(-b, -b, a);
  secScene.vertex( b, -b, a);
  secScene.fill(100, 100, 255);
  secScene.vertex( b, a, b);
  secScene.vertex( b, a, -b);
  secScene.vertex(-b, a, -b);
  secScene.vertex(-b, a, b);
  secScene.fill(101, 100, 255);
  secScene.vertex(-a, b, b);
  secScene.vertex(-a, b, -b);
  secScene.vertex(-a, -b, -b);
  secScene.vertex(-a, -b, b);
  secScene.fill(255, 255, 255);
  secScene.vertex( b, b, -a);
  secScene.vertex( b, -b, -a);
  secScene.vertex(-b, -b, -a);
  secScene.vertex(-b, b, -a);
  secScene.endShape();
  secScene.endDraw();
  if (useShader) {
    filterShader.set("image", secScene);
    mainScene.shader(filterShader);
  }
  float c = boxSize*2/3;

  mainScene.fill(255, 200, 200);
  
  mainScene.pushMatrix();
  float x = (noise(frameCount*0.001,0)*2-1)*boxSize/3;
  float y = (noise(frameCount*0.001,10)*2-1)*boxSize/3;
  float z = (noise(frameCount*0.001,20)*2-1)*boxSize/3;
  mainScene.rotateY(-rotY);
  mainScene.rotateX(-rotX);
  mainScene.translate(x,y,z);
  mainScene.sphere(boxSize/3);
  mainScene.popMatrix();

  mainScene.fill(101, 100, 255);
  mainScene.shape(cross);

  mainScene.fill(255, 255, 255);
  mainScene.pushMatrix();
  for (int i = 0; i < 10; i++) {
    mainScene.scale(0.7);
    switch(i%3) {
      case 0: 
        mainScene.rotateX(frameCount*0.01);
        break;
      case 1: 
        mainScene.rotateY(frameCount*0.01);
        break;
      case 2: 
        mainScene.rotateZ(frameCount*0.01);
        break;
    }
    mainScene.shape(cube);
  }
  mainScene.popMatrix();

  mainScene.fill(100, 100, 255);
  mainScene.translate(-c, -c, -c);
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 2; j++) {
      for (int k = 0; k < 3; k++) {
        mainScene.pushMatrix();
        mainScene.translate(i*c, j*c, k*c);
        mainScene.shape(cross);
        mainScene.popMatrix();
      }
    }
  }
  mainScene.endDraw();
  image(mainScene, 0, 0);
  if (drawPanels)
    image(secScene, 0, 0);
}

void keyPressed() {
  if (key == '1') {
    drawPanels = !drawPanels;
  }
  if (key == '2') {
    useShader = !useShader;
  }
}

void mouseDragged() {
  rotY += (mouseX - pmouseX)/300f;
  rotX -= (mouseY - pmouseY)/300f;
  rotX = constrain(rotX, -HALF_PI, HALF_PI);
}
