boolean[] controls = new boolean[10];
boolean sprint = false;
float fovSprint = 0;

void mouseClicked() {
  if (mouseButton == LEFT) {
    if (player.targetBlock[0].y != -1)
      removeBlock(find((int)player.targetBlock[1].x, (int)player.targetBlock[1].y), (int)player.targetBlock[0].x, (int)player.targetBlock[0].y, (int)player.targetBlock[0].z);
  } else if (mouseButton == RIGHT) {
    if (player.hotbar[player.hotbarPos] == 0)
      return;

    if (player.placeBlock[0].y != -1)
      addBlock(find((int)player.placeBlock[1].x, (int)player.placeBlock[1].y), (int)player.placeBlock[0].x, (int)player.placeBlock[0].y, (int)player.placeBlock[0].z, player.hotbar[player.hotbarPos]);
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e > 0)
    player.hotbarPos = (byte)min(player.hotbarPos+1, 9);
  else if (e < 0)
    player.hotbarPos = (byte)max(player.hotbarPos-1, 1);
}

void keyPressed() {
  if (keyCode == java.awt.event.KeyEvent.VK_F2 || keyCode == com.jogamp.newt.event.KeyEvent.VK_F2) {
    debug.show = !debug.show;
    hud.show = !hud.show;
    return;
  }
  if (keyCode == java.awt.event.KeyEvent.VK_F3 || keyCode == com.jogamp.newt.event.KeyEvent.VK_F3) {
    debug.show = !debug.show;
    return;
  }
  if (keyCode == java.awt.event.KeyEvent.VK_F4 || keyCode == com.jogamp.newt.event.KeyEvent.VK_F4) {
    chunks.redrawChunks();
    return;
  }

  if (((keyCode == java.awt.event.KeyEvent.VK_SHIFT || keyCode == com.jogamp.newt.event.KeyEvent.VK_SHIFT) && controls[0]) || key == 'W')
    sprint = true;

  if (key == 'w' || key == 'W')
    controls[0] = true;

  if (key == 's' || key == 'S')
    controls[1] = true;

  if (key == 'a' || key == 'A')
    controls[2] = true;

  if (key == 'd' || key == 'D')
    controls[3] = true;

  if (key == ' ')
    controls[4] = true;

  if (keyCode == java.awt.event.KeyEvent.VK_CONTROL || keyCode == com.jogamp.newt.event.KeyEvent.VK_CONTROL || key == 'c' || key == 'C')
    controls[5] = true;
}

void keyReleased() {
  if ((keyCode == java.awt.event.KeyEvent.VK_SHIFT || keyCode == com.jogamp.newt.event.KeyEvent.VK_SHIFT) || key == 'W')
    sprint = false;

  if (key == 'w' || key == 'W')
    controls[0] = false;

  if (key == 's' || key == 'S')
    controls[1] = false;

  if (key == 'a' || key == 'A')
    controls[2] = false;

  if (key == 'd' || key == 'D')
    controls[3] = false;

  if (key == ' ')
    controls[4] = false;

  if (keyCode == java.awt.event.KeyEvent.VK_CONTROL || keyCode == com.jogamp.newt.event.KeyEvent.VK_CONTROL || key == 'c' || key == 'C')
    controls[5] = false;

  if (key == '/')
    player.creative = !player.creative;
}

void updateControls() {
  if (sprint)
    fovSprint = min(fovSprint + 5, 10);
  else
    fovSprint = max(fovSprint - 3, 0);

  if (player.creative)
    maxVel = 0.2;
  else
    maxVel = 0.1;

  float deltaAccel = maxVel/10f;
  float deltaDecel = maxVel/15f;

  //x axis;
  if (controls[0]) //w
    if (sprint)
      player.vel.x = min(maxVel*2, player.vel.x + deltaAccel);
    else
      player.vel.x = min(maxVel, player.vel.x + deltaAccel);

  if (controls[1]) //s
    player.vel.x = max(-maxVel, player.vel.x - deltaAccel);

  if (!controls[0] && !controls[1])
    if (player.vel.x > 0)
      player.vel.x = max(0, player.vel.x - deltaDecel);
    else
      player.vel.x = min(0, player.vel.x + deltaDecel);

  //z axis
  if (controls[2]) //a
    player.vel.z = min(maxVel, player.vel.z + deltaAccel);

  if (controls[3]) //d
    player.vel.z = max(-maxVel, player.vel.z - deltaAccel);

  if (!controls[2] && !controls[3])
    if (player.vel.z > 0)
      player.vel.z = max(0, player.vel.z - deltaDecel);
    else
      player.vel.z = min(0, player.vel.z + deltaDecel);

  //y axis
  if (player.creative) {
    if (controls[4]) //up
      player.vel.y = maxVel;

    if (controls[5]) //down
      player.vel.y = -maxVel;

    if (!controls[4] && !controls[5])
      player.vel.y = 0;

    player.x += cos(player.angleLeftRight) * player.vel.x;
    player.z += sin(player.angleLeftRight) * player.vel.x;
    player.x += cos(player.angleLeftRight-HALF_PI) * player.vel.z;
    player.z += sin(player.angleLeftRight-HALF_PI) * player.vel.z;
    player.y += player.vel.y;
  } else {
    int x = round(player.x);
    int y = round(player.y);
    int z = round(player.z);

    Chunk ch = find((x>=0 ? x : x+16)/16, (z>=0 ? z : z+16)/16);

    if (ch.blocks[(x>=0 ? x : 16+x)%16][y-1][(z>=0 ? z : 16+z)%16] == 0)
      player.isOnGround = false;
    else
      player.isOnGround = true;

    if (controls[4]) { //up
      player.vel.y = jumpStrength;
      controls[4] = false;
      player.isOnGround = false;
    }

    if (ch.blocks[(x>=0 ? x : 16+x)%16][round(player.y + player.vel.y)+1][(z>=0 ? z : 16+z)%16] != 0)
      player.vel.y = 0;

    //apply movement
    if (!player.isOnGround) {
      maxVel = 0.1 / 4;
      player.vel.y = min(player.vel.y - maxVel, player.vel.y - deltaAccel/4);
    } else {
      maxVel = 0.1;
      player.vel.y = 0;
      player.y = y + 0.3;
    }

    if (cos(player.angleLeftRight) * player.vel.x + cos(player.angleLeftRight-HALF_PI) * player.vel.z > 0) {
      if (round(player.x + cos(player.angleLeftRight) * player.vel.x + cos(player.angleLeftRight-HALF_PI) * player.vel.z + 0.3) < x+1) {
        player.x += cos(player.angleLeftRight) * player.vel.x;
        player.x += cos(player.angleLeftRight-HALF_PI) * player.vel.z;
      }
      if (ch.blocks[(x>=0 ? x : 16+x)%16 + 1][y+1][(z>=0 ? z : 16+z)%16] == 0 && ch.blocks[(x>=0 ? x : 16+x)%16 + 1][y][(z>=0 ? z : 16+z)%16] == 0) {
        player.x += cos(player.angleLeftRight) * player.vel.x;
        player.x += cos(player.angleLeftRight-HALF_PI) * player.vel.z;
      }
    } else if (cos(player.angleLeftRight) * player.vel.x + cos(player.angleLeftRight-HALF_PI) * player.vel.z < 0) {
      if (round(player.x + cos(player.angleLeftRight) * player.vel.x + cos(player.angleLeftRight-HALF_PI) * player.vel.z - 0.3) > x-1) {
        player.x += cos(player.angleLeftRight) * player.vel.x;
        player.x += cos(player.angleLeftRight-HALF_PI) * player.vel.z;
      }
      if (ch.blocks[(x>=0 ? x : 16+x)%16 - 1][y+1][(z>=0 ? z : 16+z)%16] == 0 && ch.blocks[(x>=0 ? x : 16+x)%16 - 1][y][(z>=0 ? z : 16+z)%16] == 0) {
        player.x += cos(player.angleLeftRight) * player.vel.x;
        player.x += cos(player.angleLeftRight-HALF_PI) * player.vel.z;
      }
    }

    if (sin(player.angleLeftRight) * player.vel.x + sin(player.angleLeftRight-HALF_PI) * player.vel.z > 0) {
      if (round(player.z + sin(player.angleLeftRight) * player.vel.x + sin(player.angleLeftRight-HALF_PI) * player.vel.z + 0.3) < z+1) {
        player.z += sin(player.angleLeftRight) * player.vel.x;
        player.z += sin(player.angleLeftRight-HALF_PI) * player.vel.z;
      }
      if (ch.blocks[(x>=0 ? x : 16+x)%16][y+1][(z>=0 ? z : 16+z)%16 + 1] == 0 && ch.blocks[(x>=0 ? x : 16+x)%16][y][(z>=0 ? z : 16+z)%16 + 1] == 0) {
        player.z += sin(player.angleLeftRight) * player.vel.x;
        player.z += sin(player.angleLeftRight-HALF_PI) * player.vel.z;
      }
    } else if (sin(player.angleLeftRight) * player.vel.x + sin(player.angleLeftRight-HALF_PI) * player.vel.z < 0) {
      if (round(player.z + sin(player.angleLeftRight) * player.vel.x + sin(player.angleLeftRight-HALF_PI) * player.vel.z - 0.3) > z-1) {
        player.z += sin(player.angleLeftRight) * player.vel.x;
        player.z += sin(player.angleLeftRight-HALF_PI) * player.vel.z;
      }
      if (ch.blocks[(x>=0 ? x : 16+x)%16][y+1][(z>=0 ? z : 16+z)%16 - 1] == 0 && ch.blocks[(x>=0 ? x : 16+x)%16][y][(z>=0 ? z : 16+z)%16 - 1] == 0) {
        player.z += sin(player.angleLeftRight) * player.vel.x;
        player.z += sin(player.angleLeftRight-HALF_PI) * player.vel.z;
      }
    }

    player.y += player.vel.y;
  }
}
