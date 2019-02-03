PVector foodPos;
float foodRed;
float foodGreen;
float foodBlue;
float foodR;
float curFoodR;

int foodEaten = 0;

int foodAddFrame;
float foodAnim = 60;

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
}

void drawFood() {
  float x = constrain((frameCount - foodAddFrame)/foodAnim, 0, 1);
  fill(foodRed, foodGreen, foodBlue);
  pushMatrix();
  translate(foodPos);
  sphere(lerp(0,curFoodR,x));
  popMatrix();
}
