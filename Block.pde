void removeBlock(Chunk ch, int x, int y, int z) {
  if (ch.blocks[x][y][z] == 0)
    return;

  if (y < ch.miny + 128)
    ch.miny = byte(y - 128 - 1);

  ch.blocks[x][y][z] = 0;

  //for saving
  ch.modified = x * 16 + y * 256 + z;
  ch.modifiedId = ch.blocks[x][y][z];
  saveBuffer.add(ch);

  //fill with water
  floodFill(ch, x, y, z, 1);
  updateBuffer.add(ch);

  if (x == 0) {
    updateBuffer.add(ch.neigh[2]);
    ch.neigh[2].miny = (byte)min(y - 128, ch.neigh[2].miny);

    ch.neigh[2].modified = -2;
    saveBuffer.add(ch.neigh[2]);
  } else if (x == 15) {
    updateBuffer.add(ch.neigh[1]);
    ch.neigh[1].miny = (byte)min(y - 128, ch.neigh[1].miny);

    ch.neigh[1].modified = -2;
    saveBuffer.add(ch.neigh[2]);
  }

  if (z == 0) {
    updateBuffer.add(ch.neigh[3]);
    ch.neigh[3].miny = (byte)min(y - 128, ch.neigh[3].miny);

    ch.neigh[3].modified = -2;
    saveBuffer.add(ch.neigh[2]);
  } else if (z == 15) {
    updateBuffer.add(ch.neigh[0]);
    ch.neigh[0].miny = (byte)min(y - 128, ch.neigh[0].miny);

    ch.neigh[0].modified = -2;
    saveBuffer.add(ch.neigh[2]);
  }
}

void addBlock(Chunk ch, int x, int y, int z, byte type) {
  if (ch.blocks[x][y][z] != 0 && ch.blocks[x][y][z] != 110)
    return;

  if (y > ch.maxy + 128)
    ch.maxy = byte(y - 128);
  else if (y - 128 < ch.miny && type != 110)
    ch.miny = byte(y - 128 - 1);

  ch.blocks[x][y][z] = type;
  updateBuffer.add(ch);

  //for saving purposes
  ch.modified = x * 16 + y * 256 + z;
  ch.modifiedId = ch.blocks[x][y][z];
  saveBuffer.add(ch);
}

void floodFill(Chunk ch, int x, int y, int z, int nr) {
  if (ch.blocks[x][y][z] != 0 || nr > 100)
    return;
  boolean bec = false;

  if (ch.blocks[x][y+1][z] == 110)
    bec = true;

  if (x == 0) {
    if (ch.neigh[2].blocks[15][y][z] == 110 || ch.blocks[x+1][y][z] == 110)
      bec = true;
  } else if (x == 15) {
    if (ch.neigh[1].blocks[0][y][z] == 110 || ch.blocks[x-1][y][z] == 110)
      bec = true;
  } else if (x > 0 && x < 15) {
    if (ch.blocks[x-1][y][z] == 110 || ch.blocks[x+1][y][z] == 110)
      bec = true;
  }

  if (z == 0) {
    if (ch.neigh[3].blocks[x][y][15] == 110 || ch.blocks[x][y][z+1] == 110)
      bec = true;
  } else if (z == 15) {
    if (ch.neigh[0].blocks[x][y][0] == 110 || ch.blocks[x][y][z-1] == 110)
      bec = true;
  } else if (z > 0 && z < 15) {
    if (ch.blocks[x][y][z-1] == 110 || ch.blocks[x][y][z+1] == 110)
      bec = true;
  }

  if (bec) {
    ch.blocks[x][y][z] = 110;
    updateBuffer.add(ch);
    ch.modified = -3;
    saveBuffer.add(ch);

    if (x == 0) {
      floodFill(ch.neigh[2], 15, y, z, nr+1);
      floodFill(ch, x+1, y, z, nr+1);
    } else if (x == 15) {
      floodFill(ch.neigh[1], 0, y, z, nr+1);
      floodFill(ch, x-1, y, z, nr+1);
    } else {
      floodFill(ch, x-1, y, z, nr+1);
      floodFill(ch, x+1, y, z, nr+1);
    }

    if (z == 0) {
      floodFill(ch.neigh[3], x, y, 15, nr+1);
      floodFill(ch, x, y, z+1, nr+1);
    } else if (z == 15) {
      floodFill(ch.neigh[0], x, y, 0, nr+1);
      floodFill(ch, x, y, z-1, nr+1);
    } else {
      floodFill(ch, x, y, z-1, nr+1);
      floodFill(ch, x, y, z+1, nr+1);
    }

    floodFill(ch, x, y-1, z, nr+1);
  }
}

byte id(String type) {
  switch(type) {
  case "stone":
    return 1;
  case "coblestone":
    return 2;
  case "grass":
    return 3;
  case "dirt":
    return 4;
  case "oak_plank":
    return 5;
  case "oak_log":
    return 6;
  case "sand":
    return 7;
  case "bedrock":
    return 8;
  case "gravel":
    return 9;
  case "snow":
    return 10;
  case "ice":
    return 11;
  case "glass":
    return 101;
  case "cactus":
    return 102;
  case "oak_leaves":
    return 109;
  case "water":
    return 110;
  default:
    return 0;
  }
}

String id(byte type) {
  switch(type) {
  case 1:
    return "stone";
  case 2:
    return "coblestone";
  case 3:
    return "grass";
  case 4:
    return "dirt";
  case 5:
    return "oak_plank";
  case 6:
    return "oak_log";
  case 7:
    return "sand";
  case 8:
    return "bedrock";
  case 9:
    return "gravel";
  case 10:
    return "snow";
  case 11:
    return "ice";
  case 101:
    return "glass";
  case 102:
    return "cactus";
  case 109:
    return "oak_leaves";
  case 110:
    return "water";
  default:
    return "grass";
  }
}

class uv {
  byte topx=0, topy=0, botx=0, boty=0, sidex=0, sidey=0;
  uv(int topx, int topy, int sidex, int sidey, int botx, int boty) {
    this.topx = (byte)topx;
    this.topy = (byte)topy;
    this.botx = (byte)botx;
    this.boty = (byte)boty;
    this.sidex = (byte)sidex;
    this.sidey = (byte)sidey;
  }
}

void init() {
  img = loadImage("data/atlas.png");

  PGraphics graphic = createGraphics(img.width, img.height);
  graphic.beginDraw();
  graphic.rect(0, 0, img.width, img.height);
  graphic.endDraw();

  img.loadPixels();
  graphic.loadPixels();
  for (int i=0; i<img.width*img.height; i++)
    if (red(img.pixels[i]) == 200 && green(img.pixels[i]) == 50 && blue(img.pixels[i]) == 200)
      graphic.pixels[i] = color(255, 0);
    else
      graphic.pixels[i] = img.pixels[i];
  graphic.updatePixels();
  img = graphic.get();

  int nr = 1;
  uvs[nr++] = new uv(1, 0, 1, 0, 1, 0);
  uvs[nr++] = new uv(0, 1, 0, 1, 0, 1);
  uvs[nr++] = new uv(0, 0, 3, 0, 2, 0);
  uvs[nr++] = new uv(2, 0, 2, 0, 2, 0);
  uvs[nr++] = new uv(4, 0, 4, 0, 4, 0);
  uvs[nr++] = new uv(5, 1, 4, 1, 5, 1);
  uvs[nr++] = new uv(2, 1, 2, 1, 2, 1);
  uvs[nr++] = new uv(5, 2, 5, 2, 5, 2);
  uvs[nr++] = new uv(3, 1, 3, 1, 3, 1);
  uvs[nr++] = new uv(2, 4, 2, 4, 2, 4);
  uvs[nr++] = new uv(3, 4, 3, 4, 3, 4);

  //semi transparents
  uvs[101] = new uv(1, 3, 1, 3, 1, 3); //glass
  uvs[102] = new uv(5, 4, 6, 4, 7, 4); //cactus
  uvs[109] = new uv(4, 3, 4, 3, 4, 3); //oak_leaves

  //fluids
  uvs[110] = new uv(13, 12, 13, 12, 13, 12); // water
}
