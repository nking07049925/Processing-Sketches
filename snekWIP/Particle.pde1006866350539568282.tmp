ArrayList<Particle> particles = new ArrayList<Particle>();

int particleSegment = 30;
float particleSpeed = 1;

void initParticles() {
  lifeTime = 60;
  travelDist = maxR*2;
  particleSize = maxR*0.2;
  float r = red(petrifiedColor)/255f;
  float g = green(petrifiedColor)/255f;
  float b = blue(petrifiedColor)/255f;
  particleCol = new PVector(r, g, b);
}

void addParticle(PVector pos) {
  PVector dir = new PVector(random(-1, 1), random(-1, 1), random(-1, 1));
  particles.add(new Particle(pos, dir));
}

void addParticle(PVector pos, PVector dir) {
  particles.add(new Particle(pos, dir));
}

void addParticle(PVector pos, PVector dir, float ns) {
  PVector noise = new PVector(random(-1, 1), random(-1, 1), random(-1, 1));
  noise.mult(ns);
  noise.add(dir);
  particles.add(new Particle(pos, noise));
}

void drawParticles() {
  pointShader.set("time", frameCount*particleSpeed);
  PMatrix3D mat = new PMatrix3D();
  getMatrix(mat);
  pointShader.set("model", mat, true);
  pointShader.set("col", particleCol);
  pointShader.set("travelDist", travelDist);
  shader(pointShader, POINTS);
  strokeWeight(particleSize);
  beginShape(POINTS);
  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    if (p.ttl > 1) {
      particles.remove(i);
    } else {
      stroke(p.d.x, p.d.y, p.d.z, p.ttl*255);
      vertex(p.p);
    }
  }
  println();
  endShape();
  noStroke();
}

float lifeTime;
float travelDist;
float particleSize;
PVector particleCol;

class Particle {
  PVector p;
  PVector d;
  float r;
  float ttl;
  int spawnFrame;

  Particle(PVector pos, PVector dir) {
    p = pos;
    d = dir;
    r = particleSize;
    spawnFrame = frameCount;
    d.normalize();
    d.add(new PVector(1, 1, 1));
    d.mult(128);
  }

  void update() {
    ttl = (frameCount - spawnFrame)/lifeTime;
    r = particleSize*(1-ttl);
  }
}
