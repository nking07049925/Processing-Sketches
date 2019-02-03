boolean moved = false;

void mouseMoved() {
  if (dist(mouseX, mouseY, width/2, height/2) > 1 && mouseMove) {
    robot.mouseMove(width/2, height/2);
    float dy = (pmouseY - mouseY)/500f;
    dy = constrain(dy, -rotSpeed, rotSpeed);
    camera.mat.rotateX(dy);
    float dx = (mouseX - pmouseX)/500f;
    dx = constrain(dx, -rotSpeed, rotSpeed);
    camera.mat.rotateY(-dx);
    if (!paused && !gameOver) {
      head.mat.rotateX(dy);
      head.mat.rotateY(-dx);
    }
  }
}


boolean leftPressed;
boolean rightPressed;
boolean upPressed;
boolean downPressed;

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
  if (key == ' ')
    paused = !paused;
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
