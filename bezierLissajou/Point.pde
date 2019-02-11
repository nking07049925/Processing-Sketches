float pointRad = 10;
float dragDist = 20;
boolean pressed;

class Point {
  float x;
  float y;

  Point(float nx, float ny) {
    x = nx;
    y = ny;
  }

  Point get() {
    return new Point(x, y);
  }

  void draw(color c) {
    noStroke();
    fill(c);
    ellipse(x, y, pointRad * 2, pointRad * 2);
  }
}

class AnchorPoint {
  Point p;
  Point d1;
  Point d2;
  boolean pDrag;
  boolean d1Drag;
  boolean d2Drag;

  AnchorPoint(Point start, Point dir1, Point dir2) {
    p = start;
    d1 = dir1;
    d2 = dir2;
  }

  void draw() {
    stroke(anchorColor);
    line(p, d1);
    line(p, d2);
    p.draw(pDrag?pressedPointColor:pointColor);
    d1.draw(d1Drag?pressedPointColor:pointColor);
    d2.draw(d2Drag?pressedPointColor:pointColor);
  }

  void press(float x, float y, boolean left) {
    pressed = pressed && !left;
    if (!pressed || left)
      d1Drag = dist(x, y, d1.x, d1.y) < dragDist;
    pressed = pressed || d1Drag;
    if (!pressed || left)
      d2Drag = dist(x, y, d2.x, d2.y) < dragDist;
    pressed = pressed || d2Drag;
    if (!pressed || left)
      pDrag = (!pressed || left) && dist(x, y, p.x, p.y) < dragDist;
    pressed = pressed || pDrag;
  }

  void release(boolean left) {
    if (d1Drag || d2Drag || pDrag)
      pressed = false;
    if (d1Drag && dist(d1, p) < pointRad) {
      d1.x = p.x;
      d1.y = p.y;
    }  
    if (d2Drag && dist(d2, p) < pointRad) {
      d2.x = p.x;
      d2.y = p.y;
    }
    if ((d1Drag || d2Drag) && dist(d1, d2) < pointRad) {
      if (d1Drag) {
        d1.x = d2.x;
        d1.y = d2.y;
      }
      if (d2Drag) {
        d2.x = d1.x;
        d2.y = d1.y;
      }
    }
    
    d1Drag = false;
    d2Drag = false;
    pDrag = false;
  }

  void drag(float px, float py, float x, float y, boolean left) {
    if (d1Drag || (pDrag && left)) {
      d1.x += x - px;
      d1.y += y - py;
    }
    if (d2Drag || (pDrag && left)) {
      d2.x += x - px;
      d2.y += y - py;
    }
    if (pDrag) {
      p.x += x - px;
      p.y += y - py;
    }
  }
}

interface CurvedShape {
  void draw();
  Point point(float t);
}

class Curve implements CurvedShape {
  AnchorPoint p1;
  AnchorPoint p2;
  color c;

  Curve(AnchorPoint start, AnchorPoint end) {
    p1 = start;
    p2 = end;
  }

  void draw() {
    noFill();
    stroke(curveColor);
    bezier(p1, p2);
  }

  float coord(float t, float x1, float x2, float x3, float x4) {
    float t1 = 1-t;
    return t1*t1*t1*x1 + 3*t*t1*t1*x2 + 3*t*t*t1*x3 + t*t*t*x4;
  }

  Point point(float t) {
    t = constrain(t, 0, 1);
    float x = coord(t, p1.p.x, p1.d2.x, p2.d1.x, p2.p.x);
    float y = coord(t, p1.p.y, p1.d2.y, p2.d1.y, p2.p.y);
    return new Point(x, y);
  }
}

class Shape implements CurvedShape {
  ArrayList<Curve> curves = new ArrayList<Curve>();
  ArrayList<AnchorPoint> points = new ArrayList<AnchorPoint>();

  Shape(Point[] p, boolean polygon) {
    if (polygon) {
      AnchorPoint first = new AnchorPoint(p[0], p[0].get(), p[0].get());
      AnchorPoint prev = first;
      points.add(first);
      for (int i = 1; i < p.length; i++) {
        AnchorPoint cur = new AnchorPoint(p[i], p[i].get(), p[i].get());
        curves.add(new Curve(prev, cur));
        points.add(cur);
        prev = cur;
      }
      curves.add(new Curve(prev, first));
    } else {
      AnchorPoint first = new AnchorPoint(p[0], p[p.length-1], p[1]);
      points.add(first);
      AnchorPoint prev = first;
      for (int i = 3; i < p.length; i+=3) {
        int i1 = (i-1)%p.length;
        int i2 = i%p.length;
        int i3 = (i+1)%p.length;
        AnchorPoint cur = new AnchorPoint(p[i2], p[i1], p[i3]);
        curves.add(new Curve(prev, cur));
        points.add(cur);
        prev = cur;
      }
      curves.add(new Curve(prev, first));
    }
  }

  Shape(AnchorPoint[] p) {
    for (int i = 0; i < p.length/2; i++) {
      curves.add(new Curve(p[i*2], p[(i*2+1)%p.length]));
    }
  }

  void draw() {
    for (Curve c : curves) {
      c.draw();
    }
    if (editAnchors) {
      for (AnchorPoint p : points) {
        p.draw();
      }
    }
  }

  Point point(float t) {
    t = (t%1+1)%1;
    int n = curves.size();
    float k = t*n;
    int i = floor(k);
    Curve c = curves.get(i);
    return c.point(k%1);
  }

  void press(float x, float y, boolean left) {
    for (AnchorPoint p : points) {
      p.press(x, y, left);
    }
  }

  void release(boolean left) {
    for (AnchorPoint p : points) {
      p.release(left);
    }
  }

  void drag(float px, float py, float x, float y, boolean left) {
    for (AnchorPoint p : points) {
      p.drag(px, py, x, y, left);
    }
  }
  
  Point center() {
    float x = 0, y = 0;
    int n = points.size() * 3;
    for (AnchorPoint p : points) {
      x += p.p.x + p.d1.x + p.d2.x;
      y += p.p.y + p.d1.y + p.d2.y;
    }
    x /= n;
    y /= n;
    return new Point(x, y);
  }
  
  float maxDist(Point c) {
    float res = 0;
    for (AnchorPoint p : points) {
      float temp = dist(c, p.p); 
      if (temp > res) {
        res = temp;
      }
      temp = dist(c, p.d1);
      if (temp > res) {
        res = temp;
      }
      temp = dist(c, p.d2);
      if (temp > res) {
        res = temp;
      }
    }
    return res;
  }
}

void line(Point p1, Point p2) {
  line(p1.x, p1.y, p2.x, p2.y);
}

void bezier(AnchorPoint p1, AnchorPoint p2) {
  bezier(p1.p.x, p1.p.y, p1.d2.x, p1.d2.y, 
    p2.d1.x, p2.d1.y, p2.p.x, p2.p.y);
}

float dist(Point a, Point b) {
  return dist(a.x, a.y, b.x, b.y);
}
