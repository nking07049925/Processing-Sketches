PShader shade;
PShader sobel;
PGraphics main;
PGraphics normalMap;
PGraphics heightMap;
PGraphics brush;
color diffuse;

void setup() {
  fullScreen(P3D);
  main = createGraphics(width - height/2, height, P3D);
  shade = loadShader("PhongFrag.glsl", "PhongVert.glsl");
  sobel = loadShader("sobel.glsl");
  sobel.set("strength", 3.0);
  sobel.set("level", 2.0);
  textureMode(NORMAL);
  heightMap = createGraphics(height/2, height/2, P2D);
  heightMap.beginDraw();
  heightMap.background(0);
  heightMap.endDraw();
  normalMap = createGraphics(height/2, height/2, P2D);
  normalMap.beginDraw();
  normalMap.image(heightMap,0,0);
  normalMap.filter(sobel);
  normalMap.endDraw();
  brush = createGraphics(256, 256, P2D);
  brush.beginDraw();
  brush.background(0);
  brush.noStroke();
  brush.fill(255,1);
  brush.blendMode(ADD);
  for (int i = 0; i < 256; i++) {
    brush.circle(128,128,sq(i/256f)*256); 
  }
  brush.endDraw();
}

void draw() {
  drawMain();
  background(0);
  image(main, height/2, 0);
}

void drawMain() {
  main.beginDraw();
  main.stroke(255);
  main.noStroke();
  main.tint(255);
  main.fill(255);
  main.background(0);
  main.translate(main.width/2, main.height/2);
  main.ambientLight(255, 255, 255);
  main.lightSpecular(256, 256, 256);
  main.directionalLight(255, 255, 220, -1, 1, -1);
  main.lightSpecular(0,0,32);
  main.directionalLight(64, 64, 90, 0, -1, 0);
  float deg = frameCount*0.01;
  main.rotate(deg, cos(deg), sin(deg), 0);
  main.specular(255);
  main.shininess(100);
  main.ambient(60);
  diffuse(120);
  main.shader(shade);
  uvbox(main, min(width,height)*0.5);
  main.endDraw();
}

void diffuse(float val) {
  diffuse = color(val);
}

void uvbox(PGraphics pg, float a) {
  float x1 = -a/2;
  float x2 =  a/2;
  float y1 = -a/2;
  float y2 =  a/2;
  float z1 =  a/2;
  float z2 = -a/2;
  float u1 = 0;
  float u2 = 1;
  float v1 = 1;
  float v2 = 0;
  pg.beginShape(QUADS);
  pg.texture(normalMap);
  pg.attrib("diffuse", red(diffuse)/255f, green(diffuse)/255f, blue(diffuse)/255f, 1.0);
  
  // front
  pg.normal(0, 0, 1);
  tangent(pg, 1, 0, 0);
  pg.vertex(x1, y1, z1, u2, v1);
  pg.vertex(x2, y1, z1, u1, v1);
  pg.vertex(x2, y2, z1, u1, v2);
  pg.vertex(x1, y2, z1, u2, v2);

  // right
  pg.normal(1, 0, 0);
  tangent(pg, 0, 0, -1);
  pg.vertex(x2, y1, z1, u2, v1);
  pg.vertex(x2, y1, z2, u1, v1);
  pg.vertex(x2, y2, z2, u1, v2);
  pg.vertex(x2, y2, z1, u2, v2);

  // back
  pg.normal(0, 0, -1);
  tangent(pg, -1, 0, 0);
  pg.vertex(x2, y1, z2, u2, v1);
  pg.vertex(x1, y1, z2, u1, v1);
  pg.vertex(x1, y2, z2, u1, v2);
  pg.vertex(x2, y2, z2, u2, v2);

  // left
  pg.normal(-1, 0, 0);
  tangent(pg, 0, 0, 1);
  pg.vertex(x1, y1, z2, u2, v1);
  pg.vertex(x1, y1, z1, u1, v1);
  pg.vertex(x1, y2, z1, u1, v2);
  pg.vertex(x1, y2, z2, u2, v2);

  // top
  pg.normal(0, -1, 0);
  tangent(pg, -1, 0, 0);
  pg.vertex(x1, y1, z2, u2, v2);
  pg.vertex(x2, y1, z2, u1, v2);
  pg.vertex(x2, y1, z1, u1, v1);
  pg.vertex(x1, y1, z1, u2, v1);

  // bottom
  pg.normal(0, 1, 0);
  tangent(pg, 1, 0, 0);
  pg.vertex(x1, y2, z1, u2, v1);
  pg.vertex(x2, y2, z1, u1, v1);
  pg.vertex(x2, y2, z2, u1, v2);
  pg.vertex(x1, y2, z2, u2, v2);
  pg.endShape();
}

void tangent(PGraphics pg, float x, float y, float z) {
  pg.attribNormal("tangent", x, y, z);
}
