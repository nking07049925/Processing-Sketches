void mouseMoved() {
  if (dist(mouseX, mouseY, width/2, height/2) > 1 && mouseEnabled) {
    robot.mouseMove(width/2, height/2);
    float dy = (pmouseY - mouseY)/500f;
    dy = constrain(dy, -rotSpeed, rotSpeed);
    camera.mat.rotateX(dy * mouseYFlip);
    float dx = (mouseX - pmouseX)/500f;
    dx = constrain(dx, -rotSpeed, rotSpeed);
    camera.mat.rotateY(-dx);
    if (!paused && !gameOver) {
      head.mat.rotateX(dy * mouseYFlip);
      head.mat.rotateY(-dx);
    }
  }
}

void mousePressed() {
  setFood();
}


boolean leftPressed;
boolean rightPressed;
boolean upPressed;
boolean downPressed;

int keyYFlip = 1;
int mouseYFlip = 1;

void turnSnake() {
  if (leftPressed) {
    camera.mat.rotateY(rotSpeed);
    if (!paused && !gameOver) {
      head.mat.rotateY(rotSpeed);
    }
  }
  if (rightPressed) {
    camera.mat.rotateY(-rotSpeed);
    if (!paused && !gameOver) {
      head.mat.rotateY(-rotSpeed);
    }
  }
  if (upPressed) {
    camera.mat.rotateX(rotSpeed * keyYFlip);
    if (!paused && !gameOver) {
      head.mat.rotateX(rotSpeed * keyYFlip);
    }
  }
  if (downPressed) {
    camera.mat.rotateX(-rotSpeed * keyYFlip);
    if (!paused && !gameOver) {
      head.mat.rotateX(-rotSpeed * keyYFlip);
    }
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      leftPressed = true;
    }
    if (keyCode == RIGHT) {
      rightPressed = true;
    }
    if (keyCode == UP) {
      upPressed = true;
    }
    if (keyCode == DOWN) {
      downPressed = true;
    }
  }
  if (key == ' ') {
    launch = false;
    paused = !paused;
    if (gameOver) {
      paused = true;
      snakeSetup();
      sceneSetup();
      setFood();
      cleanFood();
      foodEaten = 0;
      gameOver = false;
      launch = true;
      curFoodBrightness = foodBrightness;
    }
  }
  if (key == CODED) {
    if (keyCode == CONTROL) {
      mouseEnabled = !mouseEnabled;
      if (!mouseEnabled) {
        camera.mat = head.mat.get();
      }
    }
    
    if (keyCode == SHIFT) {
      keyYFlip = -keyYFlip;
    }
    if (keyCode == ALT) {
      mouseYFlip = -mouseYFlip;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      leftPressed = false;
    }
    if (keyCode == RIGHT) {
      rightPressed = false;
    }
    if (keyCode == UP) {
      upPressed = false;
    }
    if (keyCode == DOWN) {
      downPressed = false;
    }
  }
}
