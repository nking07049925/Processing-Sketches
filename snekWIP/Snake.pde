int snakeQuality = 20;
PVector[] baseShape = new PVector[snakeQuality];
PVector[] baseNorm = new PVector[snakeQuality];
ArrayList<Segment> snake = new ArrayList<Segment>();
int headSize = 7;
Segment[] headPositions = new Segment[headSize];
float[][] headNormals = new float[headSize][2];
float headLength;
Segment head;

color petrifiedColor = #2E2E2E;
color snakeColor = #4D984D;
color snakeBellyColor = #F8FFE5;

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
  int max = startLength*(dist+1);
  headLength = maxR*4.0;
  for (int i = 0; i < max+1; i++) {
    Segment seg = new Segment(new PVector(0, 0, -(max+1-i)*moveSpeed)); 
    snake.add(seg);
  }

  for (int i = 0; i < headSize; i++) {
    float x = i/(headSize-1f);
    headPositions[i] = new Segment(new PVector(0, 0, x*headLength), new PMatrix3D(), maxR*headFunc(x));
    float deg = headAngleFunc(x);
    headNormals[i] = new float[] { cos(deg)*maxR/headLength, sin(deg) };
  }
  head = new Segment();
}

void drawSnake() {
  specular(188);
  int s = snake.size();
  Segment last = snake.get(s - 1);
  if (s > dist) {
    PVector[] prev = getBase(snake.get(0));
    for (int i = (s-1)%dist; i < s; i+=dist) {
      Segment pa = snake.get(i);
      PVector[] cur = getBase(pa);
      drawBase(prev, cur, i-dist, i);
      prev = cur;
    }
    PVector[] cur = getBase(last);
    drawBase(prev, cur, s-dist-1, s-1);
    pushMatrix();
    translate(last.pos);
    applyMatrix(last.mat);
    drawHead();
    shader(phong);
    float eyeInd = snake.size()+headSize*0.8;
    boolean petr = gameOver && abs(eyeInd-collisionInd) < petrifyInd;
    boolean clear = gameOver && abs(eyeInd-collisionInd) < clearInd;
    float eyeDist = maxR*1.0;
    float eyeR = maxR*0.2;
    noTint();
    if (!clear) {
      translate(0, -maxR, headLength*0.8);
      if (petr) {
        fill(60);
        specular(60);
        shininess(10);
      } else {
        fill(10);
        specular(190);
        shininess(50);
      }
      translate(eyeDist/2, 0, 0);
      sphere(eyeR);
      translate(-eyeDist, 0, 0);
      sphere(eyeR);
    }
    popMatrix();
  }
}

void drawHead() {
  int s = snake.size();
  for (int i = 0; i < headSize-1; i++) {
    drawBase(getHeadBase(headPositions[i], i), getHeadBase(headPositions[i+1], i+1), i+s, i+1+s);
  }
}

void drawBase(PVector[] base1, PVector[] base2, int ind1, int ind2) {
  pushMatrix();
  beginShape(TRIANGLE_STRIP);
  texture(skin);
  float diff1 = abs(ind1-collisionInd);
  float diff2 = abs(ind2-collisionInd);
  boolean petr1 = gameOver && diff1 < petrifyInd;
  boolean petr2 = gameOver && diff2 < petrifyInd;
  boolean clear1 = gameOver && diff1 < clearInd;
  boolean clear2 = gameOver && diff2 < clearInd;
  float petr1k = smoothstep(petrifyInd-10, petrifyInd, diff1);
  float petr2k = smoothstep(petrifyInd-10, petrifyInd, diff2);
  float alpha1 = 255*smoothstep(clearInd-5, clearInd, diff1);
  float alpha2 = 255*smoothstep(clearInd-5, clearInd, diff2);
  float spec1 = lerp(40, 188, petr1k);
  float shin1 = lerp(10, 50, petr1k);
  float spec2 = lerp(40, 188, petr1k);
  float shin2 = lerp(10, 50, petr1k);
  for (int i = 0; i < snakeQuality+1; i++) {
    int j = i%snakeQuality;
    float pos = (float)i/snakeQuality;
    float k = 0.3;
    boolean belly = pos > k && pos < 1-k;
    color tint = belly?snakeBellyColor:snakeColor;
    color petr1Col = lerpColor(petrifiedColor, tint, petr1k);
    color petr2Col = lerpColor(petrifiedColor, tint, petr2k);
    specular(spec1);
    shininess(shin1);
    tint(petr1?petr1Col:tint, alpha1);
    normal(base1[j*2]);
    vertex(base1[j*2+1], pos, 0);
    specular(spec2);
    shininess(shin2);
    tint(petr2?petr2Col:tint, alpha2);
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

  Segment(PVector p) {
    this(p, new PMatrix3D(), 0);
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
