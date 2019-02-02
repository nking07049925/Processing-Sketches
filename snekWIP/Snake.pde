int snakeQuality = 20;
PVector[] baseShape = new PVector[snakeQuality];
PVector[] baseNorm = new PVector[snakeQuality];
ArrayList<Segment> curve = new ArrayList<Segment>();
int headSize = 7;
Segment[] headPositions = new Segment[headSize];
float[][] headNormals = new float[headSize][2];
float headLength;
Segment head;

float offs = 0.3;
float headFunc(float x) {
  return x < 0.5 ? 1+(1-cos(x*TWO_PI))/2*offs : sqrt(1-sq(2*x-1))*(1+offs);
}
float headAngleFunc(float x) {
  return x < 0.5 ? atan(sin(x*TWO_PI)*PI*offs)+HALF_PI : atan(-2*(1+offs)*(2*x-1)/sqrt(1-sq(2*x-1)))+HALF_PI;
}


float maxR;
int dist = 3;
int startLength = 200;
float moveSpeed;

void snakeSetup() {
  maxR = width/60f;
  moveSpeed = maxR/5;
  
  for (int i = 0; i < snakeQuality; i++) {
    float deg = -(i-0.5)*TWO_PI/snakeQuality - HALF_PI;
    baseShape[i] = new PVector(cos(deg), sin(deg));
  }
  baseNorm = baseShape.clone();
  int max = startLength*dist;
  headLength = maxR*4.0;
  for (int i = 0; i < max + 1; i++)
    curve.add(new Segment());

  for (int i = 0; i < headSize; i++) {
    float x = i/(headSize-1f);
    headPositions[i] = new Segment(new PVector(0, 0, x*headLength), new PMatrix3D(), maxR*headFunc(x));
    float deg = headAngleFunc(x);
    headNormals[i] = new float[] { cos(deg)*maxR/headLength, sin(deg) };
  }
  head = new Segment();
}

void drawSnake() {
  lightSpecular(255, 255, 255);
  specular(188);
  shininess(50);
  emissive(255);
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
    translate(0, -maxR, headLength*0.8);
    fill(0);
    translate(eyeDist/2, 0, 0);
    sphere(eyeR);
    translate(-eyeDist, 0, 0);
    sphere(eyeR);
    popMatrix();
  }
}

void drawHead() {
  for (int i = 0; i < headSize-1; i++) {
    drawBase(getHeadBase(headPositions[i], i), getHeadBase(headPositions[i+1], i+1));
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
    r = maxR*sqrt(ind/(max-1.0));
  }
}
