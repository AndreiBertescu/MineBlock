void generateCh() {
  ArrayList <semiChunk> preChunks = new ArrayList<>();
  float yy, noise;
  int x, y, z;
  noiseSeed(seed);

  while (true)
    if (!loadBuffer.empty()) {
      Chunk current = loadBuffer.pop();
      int maxy = 0, miny = 255;

      //gen
      for (z = 0; z<16; z++)
        for (x = 0; x<16; x++) {
          yy = 0;

          //continental
          noise = Noise(x + 16*current.x, z + 16*current.z, 0.002);
          if (noise < 0.4)
            yy += map(noise, 0, 0.4, 70, 100);
          else if (noise >= 0.4 && noise <= 0.5)
            yy += map(noise, 0.4, 0.5, 100, 150);
          else if (noise > 0.5 && noise <= 0.6)
            yy += map(noise, 0.5, 0.6, 150, 170);
          else if (noise > 0.6 && noise <= 0.7)
            yy += map(noise, 0.6, 0.7, 170, 190);
          else if (noise > 0.7)
            yy += map(noise, 0.7, 1, 190, 200);

          //erosion
          noise = Noise(x + 16*current.x, z + 16*current.z, 0.01);
          if (noise < 0.4)
            yy += map(noise, 0, 0.4, 50, 0);
          else if (noise >= 0.4 && noise <= 0.5)
            yy += map(noise, 0.4, 0.5, 0, -30);
          else if (noise > 0.5 && noise <= 0.6)
            yy += map(noise, 0.5, 0.6, -30, -35);
          else if (noise > 0.6 && noise <= 0.8)
            yy += map(noise, 0.6, 0.8, -35, -40);
          else if (noise > 0.8 && noise <= 0.85)
            yy += map(noise, 0.8, 0.85, -40, -5);
          else if (noise > 0.85 && noise <= 0.9)
            yy += map(noise, 0.85, 0.9, -5, 0);
          else if (noise > 0.9)
            yy += map(noise, 0.9, 1, 0, 15);

          //valleys & hills
          noise = Noise(x + 16*current.x, z + 16*current.z, 0.02);
          if (noise < 0.2)
            yy += map(noise, 0, 0.2, -20, -15);
          else if (noise >= 0.2 && noise <= 0.5)
            yy += map(noise, 0.2, 0.5, -15, -10);
          else if (noise >= 0.5 && noise <= 0.8)
            yy += map(noise, 0.5, 0.8, -10, 15);
          else if (noise > 0.8)
            yy += map(noise, 0.8, 1, 15, 22);

          //set min and max height of chunk
          if (yy < miny)
            miny = floor(yy);
          if (yy > maxy)
            maxy = ceil(yy);
          yy = floor(yy);

          //generate
          if (Noise(x + 16*current.x, z + 16*current.z, 0.002) <= 0.5 && yy > 70 && yy < 170) {//desert
            for (y = (int)yy; y>0; y--)
              if (y <= yy && y >= yy - 7)
                current.blocks[x][y][z] = id("sand");
              else if (y < yy - 5)
                current.blocks[x][y][z] = id("stone");

            if (random(100) <= 1)
              current.blocks[x][(int)yy+1][z] = id("grass");
            if (random(100) <= 0.5) {
              int cHeight = floor(random(18));
              if (cHeight < 11) {
                current.blocks[x][(int)yy+1][z] = id("cactus");
                current.blocks[x][(int)yy+2][z] = id("cactus");
                current.blocks[x][(int)yy+3][z] = id("cactus");
              } else if (cHeight < 16) {
                current.blocks[x][(int)yy+1][z] = id("cactus");
                current.blocks[x][(int)yy+2][z] = id("cactus");
              } else if (cHeight < 18) {
                current.blocks[x][(int)yy+1][z] = id("cactus");
              }
            }
          } else if (yy < 70) { ///////////////////////////////////////////ocean
            maxy =max(maxy, 70);
            for (y = 70; y>0; y--)
              if (y > yy)
                current.blocks[x][y][z] = id("water");
              else if (y <= yy && y >= yy - 5)
                current.blocks[x][y][z] = id("gravel");
              else if (y < yy - 5)
                current.blocks[x][y][z] = id("stone");
          } else if (yy >= 70 && yy <74) { /////////////////////////shore
            for (y = (int)yy; y>0; y--)
              if (y <= yy && y >= yy - 7)
                current.blocks[x][y][z] = id("sand");
              else if (y < yy - 5)
                current.blocks[x][y][z] = id("stone");
          } else if (yy >= 190) { //////////////////////////////////mountain peak
            for (y = (int)yy; y>0; y--)
              if (y == yy)
                current.blocks[x][y][z] = id("snow");
              else if ((y < yy && y >= 180) || (y < 180 && y >= 175 && random(3) <= 2) || (y < 175 && y >= 173 && random(3) <= 1))
                current.blocks[x][y][z] = id("ice");
              else
                current.blocks[x][y][z] = id("stone");
          } else if (yy >= 173 || (yy >= 170 && yy <= 173 && random(3) <= 2) || (yy >= 168 && yy <= 170 && random(3) <= 1)) { //mountain
            for (y = (int)yy; y>0; y--)
              if (y == yy)
                current.blocks[x][y][z] = id("snow");
              else if (y < yy && y >= yy - 3)
                current.blocks[x][y][z] = id("dirt");
              else if (y < yy - 3)
                current.blocks[x][y][z] = id("stone");
          } else { /////////////////////////////////////////////////everything else
            for (y = (int)yy; y>0; y--)
              if (y == yy)
                current.blocks[x][y][z] = id("grass");
              else if (y >= yy-2 && y < yy)
                current.blocks[x][y][z] = id("dirt");
              else if (y < yy - 2)
                current.blocks[x][y][z] = id("stone");

            //details
            if ((Noise(x + 16*current.x, z + 16*current.z, 0.01) > 0.5 && random(100) <= 0.5) || (Noise(x + 16*current.x, z + 16*current.z, 0.01) < 0.5 && random(100) <= 0.3))
              generateTree(preChunks, current, (byte)x, (int)yy, (byte)z);
            if (Noise(x + 16*current.x, z + 16*current.z, 0.01) > 0.5 && random(100) <= 1)
              current.blocks[x][(int)yy+1][z] = id("sand");
          }

          current.blocks[x][0][z] = id("bedrock");
        }

      //generate the preloaded blocks if space is empty
      semiChunk semich = findTemp(preChunks, current.x, current.z);
      if (semich != null) {
        preChunks.remove(semich);
        for (blockInfo bl : semich.blocks)
          if (current.blocks[bl.x][bl.y + 128][bl.z] == 0) {
            current.blocks[bl.x][bl.y + 128][bl.z] = bl.id;

            if (maxy < bl.y + 128)
              maxy = bl.y + 128 + 1;
          }
      }
      //stop gen

      current.generated = true;
      if (current.maxy < maxy)
        current.maxy = byte((maxy+5) - 128);
      current.miny = byte((miny-5) - 128);

      saveBuffer.add(0, current);
    }
}

float Noise(float x, float z, float freq) {
  return noise((x+1000000) * freq, (z+1000000) * freq);
}

//for preloading chunk blocks
class semiChunk {
  int x, z;
  ArrayList<blockInfo> blocks;

  semiChunk(int x, int z) {
    this.x = x;
    this.z = z;
    blocks = new ArrayList<>();
  }
}

semiChunk findTemp(ArrayList<semiChunk> preChunks, int x, int z) {
  if (preChunks == null)
    return null;

  for (semiChunk ch : preChunks)
    if (ch.x == x && ch.z == z)
      return  ch;

  //if it doesnt exist it adds a new one
  preChunks.add(new semiChunk(x, z));
  return preChunks.get(preChunks.size()-1);
}

void generateTree(ArrayList<semiChunk> preChunks, Chunk current, byte x, int yy, byte z) {
  int trunkHeight = 4 + floor(random(3));
  if (current.maxy < trunkHeight+1)
    current.maxy = byte(trunkHeight+2-128);

  for (int i=1; i<=trunkHeight; i++)
    current.blocks[x][yy+i][z] = id("oak_log");
  current.blocks[x][yy+trunkHeight+1][z] = id("oak_leaves");

  for (int j = 1; j>=0; j--)
    for (int i = -1; i<=1; i++)
      for (int k = -1; k<=1; k++) {
        if ((i == 0 && k != 0) || (i != 0 && k == 0))
          placeBlock(preChunks, current, x+i, yy+trunkHeight+j, z+k, id("oak_leaves"));
        if (j == 0 && i != 0 && k != 0 && random(4) < 3)
          placeBlock(preChunks, current, x+i, yy+trunkHeight+j, z+k, id("oak_leaves"));
      }

  for (int j = -1; j>=-2; j--)
    for (int i = -2; i<=2; i++)
      for (int k = -2; k<=2; k++) {
        if ((i/2 == 0 && k != 0) || (i != 0 && k/2 == 0))
          placeBlock(preChunks, current, x+i, yy+trunkHeight+j, z+k, id("oak_leaves"));
        if (i/2 != 0 && k/2 != 0 && random(4) < 3)
          placeBlock(preChunks, current, x+i, yy+trunkHeight+j, z+k, id("oak_leaves"));
      }
}

void placeBlock(ArrayList<semiChunk> preChunks, Chunk current, int x, int y, int z, byte id) {
  if (x <= 15 && x >= 0 && z <= 15 && z >= 0) {
    current.blocks[x][y][z] = id;
    return;
  }

  int chx, chz;
  if (x > 15)
    chx = 1;
  else if (x < 0)
    chx = -1;
  else
    chx = 0;
  if (z > 15)
    chz = 1;
  else if (z < 0)
    chz = -1;
  else chz = 0;

  if (x >= 16)
    x -= 16;
  else if (x <= -1)
    x = 16 + x;
  if (z >= 16)
    z -= 16;
  else if (z <= -1)
    z = 16 + z;

  Chunk neigh = find(current.x + chx, current.z + chz);
  if (neigh != null && neigh.blocks[x][y][z] == 0) {
    neigh.blocks[x][y][z] = id;

    if (neigh.maxy+128 < y)
      neigh.maxy = byte(y+1-128);
    return;
  }

  semiChunk neigh2 = findTemp(preChunks, current.x + chx, current.z + chz);
  neigh2.blocks.add(new blockInfo(byte(x), byte(y-128), byte(z), id));
}
