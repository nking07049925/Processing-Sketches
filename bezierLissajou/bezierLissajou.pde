color pointColor = color(255);
color pressedPointColor = color(200);
color anchorColor = color(255, 128, 128);

color curveColor = color(128);

boolean editAnchors = false;

void setup() {
  //fullScreen();
  size(1080, 1080);
  strokeWeight(5);

  int n = 12;
  Point[] p = new Point[n];
  for (int i = 0; i < n; i++) {
    float r = height/3;
    float deg = -i*TWO_PI/n;
    p[i] = new Point(width/2 + r*cos(deg), height/2 + r*sin(deg));
  }
  shape = new Shape(p, false);
}

Shape shape;

void draw() {
  background(0);
  Point p = shape.point(frameCount*0.005);
  Point c = shape.center();
  float r = shape.maxDist(c);
  fill(20);
  noStroke();
  ellipse(c.x, c.y, 2*r, 2*r);
  stroke(64);
  line(p.x, 0, p.x, height);
  line(0, p.y, width, p.y);
  shape.draw();
  p.draw(color(255));
  shape.center().draw(color(40));
}

void keyPressed() {
  if (key == ' ')
    editAnchors = !editAnchors;
}

void mousePressed() {
  if (editAnchors) {
    shape.press(mouseX, mouseY, mouseButton == LEFT);
  }
}

void mouseDragged() {
  if (editAnchors) {
    shape.drag(pmouseX, pmouseY, mouseX, mouseY, mouseButton == LEFT);
  }
}

void mouseReleased() {
  if (editAnchors) {
    shape.release(mouseButton == LEFT);
  }
}
