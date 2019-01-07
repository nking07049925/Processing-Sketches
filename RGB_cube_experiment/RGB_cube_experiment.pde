boolean colors[][][] = new boolean[256][256][256];
float size;
float voxel;

PShader pointShader;
PImage img;
PGraphics render;
PShape box;

PGraphics renderSSAA;
PShader downScale;
float upscale = 2;

int rotationFrames = 800;
boolean saveFrames = false;
int startFrame = 0;

void setup() {
  //fullScreen(P3D);
  size(640, 640, P3D);
  pointShader = loadShader("pointFrag.glsl", "pointVert.glsl");
  downScale = loadShader("downscale.glsl");
  render = createGraphics(floor(width*upscale), floor(height*upscale), P3D);
  size = min(render.width, render.height)/2;
  voxel = size/256f;
  renderSSAA = createGraphics(width, height, P3D);
  img = loadImage("img.png");
  img.loadPixels();
  for (int i = 0; i < img.width; i++) {
    for (int j = 0; j < img.height; j++) {
      int c = img.pixels[i+j*img.width];
      int r = c >> 16 & 0xFF;
      int g = c >> 8 & 0xFF;
      int b = c & 0xFF;
      colors[r][g][b] = true;
    }
  }
  box = createShape();
  box.beginShape(LINES);
  box.strokeWeight(5);
  for (int i = 0; i < 7; i++) {
    int x = i&1;
    int y = i>>1&1;
    int z = i>>2;
    for (int j = 0; j < 3; j++) {
      if ((i>>j&1)==0) {
        int t = i|1<<j;
        int x1 = t&1;
        int y1 = t>>1&1;
        int z1 = t>>2;
        box.stroke(x * 255, y * 255, z * 255);
        box.vertex(x * size, y * size, z * size);
        box.stroke(x1 * 255, y1 * 255, z1 * 255);
        box.vertex(x1 * size, y1 * size, z1 * size);
      }
    }
  }
  box.endShape();
}

void draw() {
  int frameDelta = frameCount - startFrame;
  background(128);
  render.beginDraw();
  render.noFill();
  render.shader(pointShader, POINTS);
  render.strokeWeight(voxel*1.2);
  render.strokeCap(SQUARE);
  render.clear();
  render.translate(render.width/2, render.height/2);
  float deg = frameCount*TWO_PI/rotationFrames;
  render.rotateY(deg);
  render.translate(-size/2, -size/2, -size/2);
  for (int i = 0; i < 255; i++) {
    for (int j = 0; j < 255; j++) {
      for (int k = 0; k < 255; k++) {
        if (colors[i][j][k]) {
          render.stroke(i, j, k);
          render.point(i * voxel, j * voxel, k * voxel);
        }
      }
    }
  }
  render.shape(box);
  render.endDraw();
  downScale.set("image", render);
  renderSSAA.filter(downScale);
  image(img, 0, 0);
  image(renderSSAA, 0, 0);
  if (saveFrames && frameDelta <= rotationFrames)
    saveFrame("/frames/frame"+nf(frameDelta,3)+".png");
}

void mousePressed() {
  if (mouseButton == LEFT) {
    img = loadImage("https://picsum.photos/640/640/?random", "png");
    img.loadPixels();
    colors = new boolean[256][256][256];
    for (int i = 0; i < img.width; i++) {
      for (int j = 0; j < img.height; j++) {
        int c = img.pixels[i+j*img.width];
        int r = c >> 16 & 0xFF;
        int g = c >> 8 & 0xFF;
        int b = c & 0xFF;
        colors[r][g][b] = true;
      }
    }
  }
  if (mouseButton == RIGHT) {
    startFrame = frameCount;
    saveFrames = true;
  }
}

void setBox() {
  box = createShape();
}
