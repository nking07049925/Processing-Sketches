void translate(PVector v) {
  translate(v.x, v.y, v.z);
}

void vertex(PVector v) {
  vertex(v.x, v.y, v.z);
}

void vertex(PVector vec, float u, float v) {
  vertex(vec.x, vec.y, vec.z, u, v);
}

void normal(PVector v) {
  normal(v.x, v.y, v.z);
}

void pointLight(float r, float g, float b, PVector p) {
  pointLight(r, g, b, p.x, p.y, p.z);
}

void camera(PVector eye, PVector look, PVector up) {
  PVector center = look.copy();
  center.setMag(camDist);
  center.add(eye);
  camera(eye.x, eye.y, eye.z, center.x, center.y, center.z, up.x, up.y, up.z);
}
