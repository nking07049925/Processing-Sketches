PVector foodPos;
float foodRed;
float foodGreen;
float foodBlue;
float foodR;
float curFoodR;

int foodEaten = 0;

int foodAddFrame;
float foodAnim = 60;
float curFoodBrightness = 0.7;
float foodBrightness = 0.7;

void setFood() {
  foodR = maxR;
  float halfSide = boxSide/2-foodR-maxR*5.0;
  float x = random(-halfSide,halfSide);
  float y = random(-halfSide,halfSide);
  float z = random(-halfSide,halfSide);
  foodPos = new PVector(x, y, z);
  int n = floor(random(3));
  float rk = 1 - 0.2125;
  float gk = 1 - 0.7154;
  float bk = 1 - 0.0721;
  foodRed = random(rk*255, 255);
  foodGreen = random(gk*255, 255);
  foodBlue = random(bk*255, 255);
  foodAddFrame = frameCount;
}

void foodLight() {
  float x = constrain((frameCount - foodAddFrame)/foodAnim, 0, 1);
  lightFalloff(1.0, 0.02, 0.0);
  lightSpecular(lerp(0,foodRed,x), lerp(0,foodGreen,x), lerp(0,foodBlue,x));
  pointLight(lerp(0,foodRed,x), lerp(0,foodGreen,x), lerp(0,foodBlue,x), foodPos);
  lightFalloff(1.0, 0.05, 0.0);
  for (int i = 0; i < eatenFoodCount; i++) {
    lightSpecular(eaten[i].red*foodBrightness, eaten[i].green*foodBrightness, eaten[i].blue*foodBrightness);
    pointLight(eaten[i].red*foodBrightness, eaten[i].green*foodBrightness, eaten[i].blue*foodBrightness, eaten[i].seg.pos);
  }
}

void drawFood() {
  float x = constrain((frameCount - foodAddFrame)/foodAnim, 0, 1);
  fill(foodRed, foodGreen, foodBlue);
  pushMatrix();
  translate(foodPos);
  sphere(lerp(0,curFoodR,x));
  popMatrix();
}


class EatenFood {
  Segment seg;
  float red;
  float green;
  float blue;
  
  EatenFood(Segment s, float r, float g, float b) {
    seg = s;
    red = r;
    green = g;
    blue = b;
  }
}

int eatenFoodCount = 0;
int maxFood = 4;

EatenFood[] eaten = new EatenFood[maxFood];

float[] getFoodPosition() {
  float[] res = new float[eatenFoodCount*3];
  for (int i = 0; i < eatenFoodCount; i++) {
    res[i*3+0] = eaten[i].seg.pos.x;
    res[i*3+1] = eaten[i].seg.pos.y;
    res[i*3+2] = eaten[i].seg.pos.z;
  }
  return res;
}

float[] getFoodColor() {
  float[] res = new float[eatenFoodCount*3];
  for (int i = 0; i < eatenFoodCount; i++) {
    res[i*3+0] = constrain(eaten[i].red,0,255)/255;
    res[i*3+1] = constrain(eaten[i].green,0,255)/255;
    res[i*3+2] = constrain(eaten[i].blue,0,255)/255;
  }
  return res;
}

void addFood(Segment seg) {
  if (eatenFoodCount < maxFood) {
    eaten[eatenFoodCount] = new EatenFood(seg, foodRed, foodGreen, foodBlue);
    eatenFoodCount++;
  } else {
    for (int i = 0; i < maxFood-1; i++)
      eaten[i] = eaten[i+1];
    eaten[maxFood-1] = new EatenFood(seg, foodRed, foodGreen, foodBlue);
  }
}

void removeFood() {
  for (int i = 0; i < eatenFoodCount-1; i++)
    eaten[i] = eaten[i+1];
  eatenFoodCount--; 
}

void cleanFood() {
  eatenFoodCount = 0;
}
