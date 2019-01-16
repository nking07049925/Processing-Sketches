PShape getCube(float size, float w) {
  w = constrain(abs(w), 0, size/2);
  float a1 = size/2;
  float a2 = -a1;
  float b1 = a1-w/2;
  float b2 = -b1;
  float[][] vert = {
    {1, 0, 0}, 
    {a1, a1, a1}, {a1, b1, b1}, {a1, b1, b2}, {a1, a1, a2}, 
    {a1, b1, b1}, {a1, a1, a1}, {a1, a2, a1}, {a1, b2, b1}, 
    {a1, b2, b2}, {a1, a2, a2}, {a1, a1, a2}, {a1, b1, b2}, 
    {a1, a2, a2}, {a1, b2, b2}, {a1, b2, b1}, {a1, a2, a1}, 
    {b2, b2, a1}, {b2, b2, b1}, {b2, b1, b1}, {b2, b1, a1}, 
    {b2, a2, b2}, {b2, b2, b2}, {b2, b2, b1}, {b2, a2, b1}, 
    {b2, b1, a2}, {b2, b1, b2}, {b2, b2, b2}, {b2, b2, a2}, 
    {b2, a1, b1}, {b2, b1, b1}, {b2, b1, b2}, {b2, a1, b2}
  };
  return getShape(vert);
}

PShape getCross(float size, float w) {
  w = constrain(abs(w), 0, size/2);
  float a1 = size/2;
  float a2 = -a1;
  float b1 = w/2;
  float b2 = -b1;
  float[][] vert = {
    {1, 0, 0}, 
    {a1, b1, b1}, {a1, b2, b1}, {a1, b2, b2}, {a1, b1, b2}, 
    {b1, b2, a1}, {b1, b2, b1}, {b1, b1, b1}, {b1, b1, a1}, 
    {b1, a2, b2}, {b1, b2, b2}, {b1, b2, b1}, {b1, a2, b1},
    {b1, b1, a2}, {b1, b1, b2}, {b1, b2, b2}, {b1, b2, a2},
    {b1, a1, b1}, {b1, b1, b1}, {b1, b1, b2}, {b1, a1, b2}
  };
  return getShape(vert);
}

PShape getShape(float[][] verts) {
  PShape res = createShape();
  res.disableStyle();
  res.beginShape(QUADS);
  for (int i = 0; i < 6; i++) {
    addVert(res, verts, i);
  }
  res.endShape();
  return res;
}

void addVert(PShape ps, float[][] vert, int n) {
  float[] temp = rot(vert[0], n);
  ps.normal(temp[0], temp[1], temp[2]);
  for (int j = 1; j < vert.length; j++) {
    temp = rot(vert[j], n);
    ps.vertex(temp[0], temp[1], temp[2]);
  }
}

float[] rot(float[] v, int n) {
  if (n < 4)
    return rotY(v, n);
  else
    return rotZ(v, (n-4)*2+1);
}

float[] rotY(float[] v, int n) {
  switch(n) {
  case 0: 
    return v;
  case 1: 
    return new float[]{ v[2], v[1], -v[0]};
  case 2: 
    return new float[]{-v[0], v[1], -v[2]};
  case 3: 
    return new float[]{-v[2], v[1], v[0]};
  }
  return null;
}

float[] rotZ(float[] v, int n) {
  switch(n) {
  case 0: 
    return v;
  case 1: 
    return new float[]{ v[1], -v[0], v[2]};
  case 2: 
    return new float[]{-v[0], -v[1], v[2]};
  case 3: 
    return new float[]{-v[1], v[0], v[2]};
  }
  return null;
}
