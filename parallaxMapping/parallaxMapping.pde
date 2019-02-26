PShader shade;
PShader sobel;
PShader blur;
PGraphics main;
PGraphics normalMap;
PGraphics heightMap;
PGraphics brush;
PGraphics brushInverted;
float brushSize = 100;
float brushOpacity = 1;
color diffuse;

PShader customHeight; 

void setup() {
  fullScreen(P3D);
  main = createGraphics(width - height/2, height, P3D);
  shade = loadShader("PhongFrag.glsl", "PhongVert.glsl");
  sobel = loadShader("sobel.glsl");
  sobel.set("strength", 3.0);
  sobel.set("level", 5.0);
  customHeight = loadShader("custom.glsl");
  blur = loadShader("blur.glsl");
  heightMap = createGraphics(height/2, height/2, P2D);
  heightMap.beginDraw();
  heightMap.background(0);
  heightMap.endDraw();
  normalMap = createGraphics(height/2, height/2, P2D);
  updateNormal();
  brush = createGraphics(256, 256, P2D);
  brush.beginDraw();
  brush.blendMode(REPLACE);
  brush.noStroke();
  for (int i = 255; i > 0; i--) {
    brush.fill(255, 256-i);
    brush.circle(128, 128, sqrt(i/256f)*256);
  }
  brush.endDraw();
}

void draw() {
  drawMain();
  background(0);
  image(main, height/2, 0);
  image(heightMap, 0, 0);
  image(normalMap, 0, height/2);
  if (mouseX < height/2 && mouseY < height/2) {
   blendMode(EXCLUSION);
   noFill();
   stroke(255);
   strokeWeight(3);
   circle(mouseX, mouseY, brushSize);
   blendMode(BLEND);
   fill(255, 0, 0, 255 * brushOpacity);
   noStroke();
   circle(mouseX, mouseY, brushSize*0.3);
 }
}

void mousePressed() {
  drawHeight();
  updateNormal();
}

void mouseDragged() {
  drawHeight();
  updateNormal();
}

void mouseWheel(MouseEvent mv) {
  float e = mv.getCount();
  if (shift) {
    brushOpacity -= e * 0.05f;
    brushOpacity = constrain(brushOpacity, 0, 1);
  } else {
    brushSize -= e * 10f;
    brushSize = constrain(brushSize, 20, height/3);
  }
}

boolean shift;

void keyPressed() {
  if (key == CODED && keyCode == SHIFT)
    shift = true;
  else {
    heightMap.beginDraw();
    heightMap.filter(customHeight);
    heightMap.endDraw();
  }
}

void keyReleased() {
  if (key == CODED && keyCode == SHIFT)
    shift = false;
}
