class Hud {
  boolean show;
  int textSpacing, textSize;
  int size = 50;

  Hud() {
    show = true;
    textSpacing = 5;
    textSize = 20;
  }

  void update() {
  }

  void show() {
    hint(DISABLE_DEPTH_TEST);
    camera();
    ortho();
    noStroke();
    textFont(regular);
    textSize(textSize);
    textAlign(LEFT, TOP);

    //beginDraw

    //crosshair
    strokeWeight(2);
    stroke(255);
    line(width/2-10, height/2, width/2+10, height/2);
    line(width/2, height/2-10, width/2, height/2+10);
    strokeWeight(1);

    //hotbar
    rectMode(CENTER);
    pushMatrix();
    translate(width/2, height - 10 - size/2);
    textureMode(NORMAL);
    int aux = size/2 - 2;

    for (int i=-4; i<=4; i++) {
      strokeWeight(3);
      stroke(100);
      fill(0, 150);
      rect(size*i, 0, size, size);
      noStroke();

      int  id = player.hotbar[i+5];
      if (id != 0) {
        beginShape();
        texture(img);
        vertex(-0.866025 * aux + size*i, -0.5 * aux, map(uvs[id].topx*16, 0, 256, 0, 1), map((uvs[id].topy+1)*16, 0, 256, 0, 1));
        vertex(0 + size*i, -1 * aux, map((uvs[id].topx+1)*16, 0, 256, 0, 1), map((uvs[id].topy+1)*16, 0, 256, 0, 1));
        vertex(0.866025 * aux + size*i, -0.5 * aux, map((uvs[id].topx+1)*16, 0, 256, 0, 1), map(uvs[id].topy*16, 0, 256, 0, 1));
        vertex(0 + size*i, 0, map(uvs[id].topx*16, 0, 256, 0, 1), map(uvs[id].topy*16, 0, 256, 0, 1));
        endShape();
        beginShape();
        fill(255, 20);
        vertex(-0.866025 * aux + size*i, -0.5 * aux);
        vertex(0 + size*i, -1 * aux);
        vertex(0.866025 * aux + size*i, -0.5 * aux);
        vertex(0 + size*i, 0);
        endShape();

        beginShape();
        texture(img);
        vertex(-0.866025 * aux + size*i, -0.5 * aux, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
        vertex(-0.866025 * aux + size*i, 0.5 * aux, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
        vertex(0 + size*i, 1 * aux, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
        vertex(0 + size*i, 0, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
        endShape();
        beginShape();
        fill(0, 70);
        vertex(-0.866025 * aux + size*i, -0.5 * aux);
        vertex(-0.866025 * aux + size*i, 0.5 * aux);
        vertex(0 + size*i, 1 * aux);
        vertex(0 + size*i, 0);
        endShape();

        beginShape();
        texture(img);
        vertex(0.866025 * aux + size*i, -0.5 * aux, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
        vertex(0.866025 * aux + size*i, 0.5 * aux, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
        vertex(0 + size*i, 1 * aux, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
        vertex(0 + size*i, 0, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
        endShape();
        beginShape();
        fill(0, 100);
        vertex(0.866025 * aux + size*i, -0.5 * aux);
        vertex(0.866025 * aux + size*i, 0.5 * aux);
        vertex(0 + size*i, 1 * aux);
        vertex(0 + size*i, 0);
        endShape();
      }
    }

    noFill();
    strokeWeight(3.5);
    stroke(200);
    rect(size * (player.hotbarPos - 5), 0, size, size);
    strokeWeight(1);
    popMatrix();
    
    //endDraw
    hint(ENABLE_DEPTH_TEST);
  }
}
