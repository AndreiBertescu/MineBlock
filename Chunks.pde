class Chunks {
  ArrayList<Chunk> chunks;
  Chunk[][] renderedChunks;
  int chx = 0, chz = 0;

  Chunks() {
    renderedChunks = new Chunk[2*renderDist+1][2*renderDist+1];
    chunks = new ArrayList<>();

    if (!(nr == 0 && no == 0))
      load(chunks);

    for (int x=-renderDist-1; x<=renderDist+1; x++)
      for (int z=-renderDist-1; z<=renderDist+1; z++) {
        if (chfind(x, z) == null)
          chunks.add(new Chunk(x, z, false));

        if (x >= -renderDist && x <= renderDist && z >= -renderDist && z<= renderDist)
          renderedChunks[x + renderDist][z + renderDist] = chfind(x, z);
      }
  }

  void update() {
    int currentx = floor((player.x+0.5)/16);
    int currentz = floor((player.z+0.5)/16);

    if (chx != currentx || chz != currentz) {
      chx = currentx;
      chz = currentz;

      changeCh();
    }
  }

  void show() {
    //render from the ouside in
    for (int x=0; x<renderDist; x++) // -1 -1
      for (int z=2*renderDist; z>renderDist; z--)
        if (renderedChunks[x][z] != null && renderedChunks[x][z].generated)
          renderedChunks[x][z].show();

    for (int x=0; x<renderDist; x++) // -1 1
      for (int z=0; z<renderDist; z++)
        if (renderedChunks[x][z] != null && renderedChunks[x][z].generated)
          renderedChunks[x][z].show();

    for (int x=renderDist*2; x>renderDist; x--) // 1 -1
      for (int z=renderDist*2; z>renderDist; z--)
        if (renderedChunks[x][z] != null && renderedChunks[x][z].generated)
          renderedChunks[x][z].show();

    for (int x=2*renderDist; x>renderDist; x--) // 1 1
      for (int z=0; z<renderDist; z++)
        if (renderedChunks[x][z] != null && renderedChunks[x][z].generated)
          renderedChunks[x][z].show();

    for (int i=0; i<renderDist; i++) {
      if (renderedChunks[i][renderDist] != null && renderedChunks[i][renderDist].generated)
        renderedChunks[i][renderDist].show();
      if (renderedChunks[renderDist][i] != null && renderedChunks[renderDist][i].generated)
        renderedChunks[renderDist][i].show();
    }
    for (int i=renderDist*2; i>renderDist; i--) {
      if (renderedChunks[i][renderDist] != null && renderedChunks[i][renderDist].generated)
        renderedChunks[i][renderDist].show();
      if (renderedChunks[renderDist][i] != null && renderedChunks[renderDist][i].generated)
        renderedChunks[renderDist][i].show();
    }

    if (renderedChunks[renderDist][renderDist] != null && renderedChunks[renderDist][renderDist].generated)
      renderedChunks[renderDist][renderDist].show();
  }

  void changeCh() {
    for (int x=-renderDist-1; x<=renderDist+1; x++)
      for (int z=-renderDist-1; z<=renderDist+1; z++) {
        if (find(x + chx, z + chz) == null)
          chunks.add(new Chunk(x + chx, z + chz, false));

        if (x >= -renderDist && x <= renderDist && z >= -renderDist && z<= renderDist)
          renderedChunks[x + renderDist][z + renderDist] = find(x + chx, z + chz);
      }

    for (Chunk ch : chunks)
      if (!(ch.x >= -renderDist-1 + chx && ch.x <= renderDist+1 + chx && ch.z >= -renderDist-1 + chz && ch.z <= renderDist+1 + chz))
        ch.mesh = null;
  }

  void redrawChunks() {
    for (int x=-renderDist; x<=renderDist; x++)
      for (int z=-renderDist; z<=renderDist; z++)
        renderedChunks[x + renderDist][z + renderDist] = find(chx + x, chz + z);

    for (int x=0; x<=2*renderDist; x++)
      for (int z=0; z <=2*renderDist; z++) {
        renderedChunks[x][z].mesh = null;
        updateBuffer.removeElement(renderedChunks[x][z]);
      }
  }

  Chunk chfind(int x, int z) {
    if (chunks == null)
      return null;

    for (Chunk ch : chunks)
      if (ch.x == x && ch.z == z)
        return  ch;

    return null;
  }
}

//find chunck in chunk list
Chunk find(int x, int z) {
  if (chunks == null || chunks.chunks == null)
    return null;

  for (Chunk ch : chunks.chunks)
    if (ch.x == x && ch.z == z)
      return  ch;

  return null;
}
