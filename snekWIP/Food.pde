PVector foodPos;
color foodColor;
float foodR;
float curFoodR;

void setFood() {
  foodR = maxR;
  foodPos = new PVector();
  foodColor = color(255);
}

void foodLight() {
  lightFalloff(1.0, 0.02, 0.0);  
  lightSpecular(255, 255, 255);
  pointLight(255, 255, 255, foodPos);
}

void drawFood() {
  fill(foodColor);
  translate(foodPos);
  sphere(curFoodR);
}
