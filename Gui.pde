class Gui {
  ArrayList<String> entries;
  NumberFormat dec1 = new DecimalFormat("0.0");
  NumberFormat dec2 = new DecimalFormat("0.00");
  NumberFormat dec3 = new DecimalFormat("0.000");
  boolean show;
  int textSpacing, textSize;

  Gui() {
    entries = new ArrayList<>();
    show = true;
    textSpacing = 5;
    textSize = 20;
  }

  void update() {
    entries = new ArrayList<>();
    entries.add("Framerate/tickrate  " + dec1.format(frameRate) + "   " + dec1.format(framerate / (frameRate/tickrate)));
    entries.add("Framerate/tickrate  " + cos(player.angleLeftRight) * player.vel.x + cos(player.angleLeftRight-HALF_PI) * player.vel.z);
    entries.add("X/Y/Z  " + dec2.format(player.x) + "   " + dec2.format(player.y) + "   " + dec2.format(player.z) + "   " + int((player.x>0 ? player.x+0.5 : player.x-15.5)/16) + "   " + int((player.z>0 ? player.z+0.5 : player.z-15.5)/16));
    entries.add("Buffer sizes  " + loadBuffer.size() + "   " + updateBuffer.size() + "   " + saveBuffer.size() + "   " + chunks.chunks.size());
    entries.add("Rotation vert/horz  " + dec3.format(degrees(player.angleLeftRight)) + " " + dec3.format(player.angleUpDown));
    entries.add("Looking at  " + player.targetBlock[0].x + "   " + player.targetBlock[0].y + "   " + player.targetBlock[0].z + "   " + player.targetBlock[1].x + "   " + player.targetBlock[1].y);
    entries.add("Placing at  " + player.placeBlock[0].x + "   " + player.placeBlock[0].y + "   " + player.placeBlock[0].z + "   " + player.placeBlock[1].x + "   " + player.placeBlock[1].y);
    entries.add("Hotbar  " + player.hotbarPos + "   " + player.hotbar[player.hotbarPos]);
    entries.add("Velocity  " + dec1.format(player.vel.x) + "   " + dec1.format(player.vel.y) + "   " + dec1.format(player.vel.z));
    entries.add("Cnt/Ers/VH  " + dec3.format(Noise(player.x, player.z, 0.002)) + "   " + dec3.format(Noise(player.x, player.z, 0.01)) + "   " + dec3.format(Noise(player.x, player.z, 0.02)));
  }

  void show() {
    hint(DISABLE_DEPTH_TEST);
    camera();
    ortho();
    noStroke();
    textFont(regular);
    textSize(textSize);
    textAlign(LEFT, TOP);
    rectMode(CORNER);

    //beginDraw
    int nr = 0;
    for (String obj : entries) {
      fill(0, 100);
      rect(10, 3 + textSpacing*(nr+1) + textSize*nr, textWidth(obj) + 10, textSize + textSpacing);

      fill(255);
      text(obj.toString(), 15, 5 + textSpacing*(nr+1) + textSize*nr++);
    }
    //endDraw

    hint(ENABLE_DEPTH_TEST);
  }
}
