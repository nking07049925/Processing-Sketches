PShape model;

PShader fade;

PImage tex;

void setup() {
  size(640,640,P3D);
  model = loadShape("Toilet.obj");
  fade = loadShader("fadeFrag.glsl", "fadeVert.glsl");
  fill(0);
  noStroke();
}

PVector spherePos = new PVector(0,0,0);

void draw() {
  background(255);
  fade.set("ftime",(float)frameCount);
  spherePos.x = mouseX - width/2;
  spherePos.y = mouseY - height/2;
  spherePos.z = 100;
  fade.set("fadePos",spherePos.x,spherePos.y,spherePos.z-555);
  shader(fade);
  translate(width/2,height/2);
  //scale(4);
  ambientLight(128,128,180);
  directionalLight(60,60,20,-1,1,-1);
  pointLight(50 + abs(sin(frameCount*0.1))*50,0,0,spherePos);
  specular(20);
  emissive(1);
  lightSpecular(100,100,100);
  shininess(5);
  //rotateY(PI/1);
  pushMatrix();
  rotateZ(PI);
  //rotateY(frameCount*0.003-PI/2);
  rotateX(PI/6);
  scale(5);
  shape(model);
  fill(200);
  //box(width/3);
  //sphere(width/6);
  popMatrix();
  translate(spherePos);
  resetShader();
  noLights();
  fill(255,0,0);
  sphere(5 + abs(sin(frameCount*0.1))*5);
}

void translate(PVector v) {
  translate(v.x, v.y, v.z);
}

void pointLight(float r, float g, float b, PVector p) {
  pointLight(r,g,b,p.x,p.y,p.z);
}
