import java.awt.AWTException;
import java.awt.Robot;

class Player {
  //mouse handling
  float diffx = 0, diffy = 0;
  Robot robby;

  //camera stuff
  float angleLeftRight, angleUpDown;
  PVector camLookAt;

  //position & movement
  boolean creative, isOnGround;
  PVector acc, vel;
  float x, y, z;

  //looking at
  PVector[]  targetBlock = new PVector[2];
  PVector[]  placeBlock = new PVector[2];

  //hotbar stuff
  byte hotbarPos;
  byte[] hotbar;

  Player() {
    camLookAt = new PVector(width/2f, height/2f, y);
    targetBlock[0] = new PVector(1, 1, 1);
    targetBlock[1] = new PVector(1, 1, 1);
    placeBlock[0] = new PVector(1, 1, 1);
    placeBlock[1] = new PVector(1, 1, 1);
    vel = new PVector(0, 0, 0);
    acc = new PVector(0, 0, 0);
    creative = true;
    isOnGround = false;

    //hotbar
    hotbarPos = 1;
    hotbar = new byte[10];
    hotbar[1] = id("grass");
    hotbar[2] = id("dirt");
    hotbar[3] = id("stone");

    hotbar[4] = id("coblestone");
    hotbar[5] = id("sand");
    hotbar[6] = id("gravel");

    hotbar[7] = id("oak_log");
    hotbar[8] = id("glass");
    hotbar[9] = id("");

    //set saved position if posible
    if (playerPos.x == -1) {
      x = 8;
      y = 150;
      z = 8;
    } else {
      x = playerPos.x;
      y = playerPos.y;
      z = playerPos.z;
      playerPos = null;
    }

    //set saved orientation if posible
    if (playerOrt.x != -1) {
      angleLeftRight = playerOrt.x;
      angleUpDown = playerOrt.y;
    } else {
      angleLeftRight = 0;
      angleUpDown = 0;
    }

    //mouse hiding
    try {
      robby = new Robot();
    }
    catch (AWTException e) {
      println("Robot class not supported by your system!");
      exit();
    }
    noCursor();
  }

  void update() {
    //mose wrapping
    diffx = mouseX-pmouseX;
    if (diffx != 0) {
      if (mouseX == 0)
        robby.mouseMove(width-1, mouseY);
      else if (mouseX == width-1)
        robby.mouseMove(1, mouseY);
    }
    if (abs(diffx) < 500)
      angleLeftRight += radians(diffx * sensx);

    diffy = mouseY-pmouseY;
    if (diffy != 0) {
      if (mouseY == 0)
        robby.mouseMove(mouseX, height-2);
      else if (mouseY == height-1)
        robby.mouseMove(mouseX, 1);
    }
    if (abs(diffy) < 500 && abs(angleUpDown + radians(diffy * sensy)) <= 45)
      angleUpDown += radians(diffy * sensy);

    // camera
    float x1 = x + cos(angleLeftRight) * 10;
    float y1 = -(y+1) + 25 * tan(radians(angleUpDown * 2));
    float z1 = z + sin(angleLeftRight) * 10;
    camLookAt.set(x1, y1, z1);
    camera (x, -(y+1), z, camLookAt.x, camLookAt.y, camLookAt.z, 0, 1, 0);

    //loking at block
    noFill();
    strokeWeight(2);
    stroke(0);

    //highlight looking at
    if (targetBlock[0].y != 1 || targetBlock[0].y != -1) {
      pushMatrix();
      translate(targetBlock[1].x*16 + targetBlock[0].x, -targetBlock[0].y, targetBlock[1].y*16 + targetBlock[0].z);
      box(1, 1, 1);
      popMatrix();
    }
  }

  void checkLookAt() {
    PVector position = new PVector(x, -(y+1), z);
    PVector pointInBetween, neigh, pointInBetweenCentered;
    float aux, aux2, mini, dist;


    for (int i=0; i<10; i++) {
      position.x += cos(angleLeftRight);
      position.z += sin(angleLeftRight);

      aux = max(25 * tan(radians(angleUpDown * 2)), -150);
      aux2 = map(min(aux, 150), -50, 50, -5, 5);
      position.y += aux2;
    }

    for (float i=0; i<=10; i+=0.05) {
      pointInBetween = new PVector((x*(10-i) + position.x*i)/10f + 0.5, ((y+1)*(10-i) - position.y*i)/10f + 0.5, (z*(10-i) + position.z*i)/10f + 0.5);
      if (pointInBetween.y < 0 || pointInBetween.y >= 256 || PVector.dist(new PVector(x, y, z), pointInBetween) > 9) {
        targetBlock[0].y = -1;
        placeBlock[0].y = -1;
        break;
      }

      PVector[] coords = getCoords(pointInBetween.x, pointInBetween.y, pointInBetween.z);
      Chunk ch = find((int)coords[1].x, (int)coords[1].y);

      if (ch != null && ch.blocks[(int)coords[0].x][(int)coords[0].y][(int)coords[0].z] != 0 && ch.blocks[(int)coords[0].x][(int)coords[0].y][(int)coords[0].z] != 110) {
        targetBlock[0] = coords[0].copy();
        targetBlock[1] = coords[1].copy();

        mini = 10000;
        pointInBetweenCentered = pointInBetween.copy().sub(new PVector(0.5, 0.5, 0.5));
        neigh = coords[0].copy();
        neigh.x += 16 * coords[1].x;
        neigh.z += 16 * coords[1].y;

        neigh.y--;
        dist = PVector.dist(pointInBetweenCentered, neigh);
        if (dist < mini) {
          mini = dist;
          placeBlock = getCoords(pointInBetween.x, pointInBetween.y - 1, pointInBetween.z);
        }
        neigh.y++;

        neigh.y++;
        dist = PVector.dist(pointInBetweenCentered, neigh);
        if (dist < mini) {
          mini = dist;
          placeBlock = getCoords(pointInBetween.x, pointInBetween.y + 1, pointInBetween.z);
        }
        neigh.y--;

        neigh.z--;
        dist = PVector.dist(pointInBetweenCentered, neigh);
        if (dist < mini) {
          mini = dist;
          placeBlock = getCoords(pointInBetween.x, pointInBetween.y, pointInBetween.z - 1);
        }
        neigh.z++;

        neigh.z++;
        dist = PVector.dist(pointInBetweenCentered, neigh);
        if (dist < mini) {
          mini = dist;
          placeBlock = getCoords(pointInBetween.x, pointInBetween.y, pointInBetween.z + 1);
        }
        neigh.z--;

        neigh.x--;
        dist = PVector.dist(pointInBetweenCentered, neigh);
        if (dist < mini) {
          mini = dist;
          placeBlock = getCoords(pointInBetween.x - 1, pointInBetween.y, pointInBetween.z);
        }
        neigh.x++;

        neigh.x++;
        dist = PVector.dist(pointInBetweenCentered, neigh);
        if (dist < mini) {
          mini = dist;
          placeBlock = getCoords(pointInBetween.x + 1, pointInBetween.y, pointInBetween.z);
        }
        neigh.x--;

        if (mini == 10000)
          placeBlock[0].y = -1;

        break;
      }
    }
  }

  PVector[] getCoords(float x, float y, float z) {
    PVector[] coords = new PVector[2];

    if (x < 0 && z >= 0) {
      coords[0] = new PVector(floor(16+x%16), floor(y), floor(z%16));
      coords[1] = new PVector((int)x/16-1, (int)z/16);
    } else if (x >= 0 && z < 0) {
      coords[0] = new PVector(floor(x%16), floor(y), floor(16+z%16));
      coords[1] = new PVector((int)x/16, (int)z/16-1);
    } else if (x < 0 && z < 0) {
      coords[0] = new PVector(floor(16+x%16), floor(y), floor(16+z%16));
      coords[1] = new PVector((int)x/16-1, (int)z/16-1);
    } else if (x >= 0 && z >= 0) {
      coords[0] = new PVector(floor(x%16), floor(y), floor(z%16));
      coords[1] = new PVector((int)x/16, (int)z/16);
    }

    coords[0].x = min(coords[0].x, 15);
    coords[0].z = min(coords[0].z, 15);
    return coords;
  }
}
