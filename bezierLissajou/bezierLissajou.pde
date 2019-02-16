color pointColor = color(255);
color pressedPointColor = color(200);
color anchorColor = color(255, 128, 128);
color activeAnchorColor = color(255, 210, 210);

color curveColor = color(128);

boolean editAnchors = true;

int animationCount = 4;
float shapeSize;
Point[] pos = new Point[animationCount];
Point[] ppos = new Point[animationCount];
Point center;
float radius;
float scale = 0.7;

float animationSpeed = 0.002;
float animationPos = 0;

PGraphics render;

void setup() {
  //fullScreen();
  size(1080, 1080);
  shapeSize = min(width, height)/animationCount;
  int size = floor(shapeSize * (animationCount-1));
  render = createGraphics(size, size);
  cleanRender();
  strokeWeight(5);

  int n = 5;
  Point[] p = new Point[n];
  for (int i = 0; i < n; i++) {
    float r = height/3;
    float deg = -i*TWO_PI/n;
    p[i] = new Point(width/2 + r*cos(deg), height/2 + r*sin(deg));
  }
  shape = new Shape(p, true);
  resetPositions();
}

void cleanRender() {
  render.beginDraw();
  render.background(0);
  render.endDraw();
}

void resetPositions() {
  center = shape.center();
  radius = shape.maxDist(center);
  animationPos = 0;
  for (int i = 0; i < animationCount; i++) {
    pos[i] = shape.point(0);
    pos[i].sub(center);
    pos[i].div(radius);
    pos[i].mult(shapeSize/2*scale);
    ppos[i] = pos[i].get();
  }
}

void readPositions() {
  for (int i = 0; i < animationCount; i++) {
    pos[i] = shape.point(animationPos*(i+1));
    pos[i].sub(center);
    pos[i].div(radius);
    pos[i].mult(shapeSize/2*scale);
  }
}

void updatePrevs() {
  for (int i = 0; i < animationCount; i++) {
    ppos[i] = pos[i];
  }
}

Shape shape;

void draw() {
  background(0);
  if (editAnchors) {
    Point p = shape.point(frameCount * animationSpeed);
    Point c = shape.center();
    float r = shape.maxDist(c);
    fill(20);
    noStroke();
    ellipse(c.x, c.y, 2*r, 2*r);
    stroke(64);
    line(p.x, 0, p.x, height);
    line(0, p.y, width, p.y);
    shape.center().draw(color(40));
    shape.draw();
    p.draw(color(255));
  } else {
    animationPos+=animationSpeed;
    readPositions();
    render.beginDraw();
    render.translate(shapeSize/2, shapeSize/2);
    render.stroke(200);
    render.strokeWeight(2);
    for (int i = 0; i < animationCount; i++) {
      for (int j = 0; j < animationCount; j++) {
        render.pushMatrix();
        render.translate(i*shapeSize, j*shapeSize);
        Point p = new Point(pos[i].x, pos[j].y);
        Point pp = new Point(ppos[i].x, ppos[j].y);
        line(render, p, pp);
        render.popMatrix();
      }
    }
    updatePrevs();
    render.endDraw();
    image(render, shapeSize, shapeSize);
    translate(shapeSize, shapeSize);
    pointRad = 5;
    for (int i = 0; i < animationCount; i++) {
      for (int j = 0; j < animationCount; j++) {
        pushMatrix();
        translate((i+0.5)*shapeSize, (j+0.5)*shapeSize);
        Point p = new Point(pos[i].x, pos[j].y);
        p.draw(255);
        popMatrix();
      }
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    editAnchors = !editAnchors;
    if (!editAnchors) {
      cleanRender();
      resetPositions();
    }
  }
  if (key == 'a')
    shape.addPoint(new Point(width/2, height/2));

  if (key == CODED && keyCode == SHIFT)
    shift = true;
}

void keyReleased() {
  if (key == CODED && keyCode == SHIFT)
    shift = false;
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
