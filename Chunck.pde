import java.util.Stack;

class Chunk {
  byte modifiedId, maxy = 127, miny = -128;
  int x, z, row, file, modified = -1;
  PShape mesh, fluidMesh = null;
  boolean generated;
  byte[][][] blocks;
  Chunk[] neigh;

  Chunk(int x, int z, boolean generated) {
    this.generated = generated;
    this.x = x;
    this.z = z;

    blocks = new byte[16][256][16];
    neigh = new Chunk[4];

    if (!generated)
      loadBuffer.add(this);
  }

  void show() {
    if (mesh == null) {
      mesh = createShape(GROUP);
      updateBuffer.add(0, this);
      return;
    }

    shape(mesh);
    if (fluidMesh != null)
      shape(fluidMesh);
  }
}

void updateCh() {
  PShape shape, mesh, fluidMesh;
  ArrayList<blockInfo> semiTransparents;
  Chunk current;
  byte x, z;
  int y;

  while (true)
    if (!updateBuffer.isEmpty()) {
      current = updateBuffer.pop();
      semiTransparents = new ArrayList<>();
      fluidMesh = createShape(GROUP);
      mesh = createShape(GROUP);

      current.neigh[3] = find(current.x, current.z-1);
      current.neigh[0] = find(current.x, current.z+1);
      current.neigh[2] = find(current.x-1, current.z);
      current.neigh[1] = find(current.x+1, current.z);

      for (y = current.miny + 128; y<=current.maxy + 128; y++)
        for (z = 0; z<16; z++)
          for (x = 0; x<16; x++)
            if (current.blocks[x][y][z] == 0)
              continue;
            else if (current.blocks[x][y][z] == 110) { //water block
              shape = generateFluidBlock (current, x, y, z, current.blocks[x][y][z]);
              if (shape != null)
                fluidMesh.addChild(shape);
            } else if (current.blocks[x][y][z] >= 100 && current.blocks[x][y][z] < 110) { //send semi-transparent blocks to semiTransparents buffer
              semiTransparents.add(new blockInfo(x, (byte)(y-128), z, current.blocks[x][y][z]));
            } else { //solid block
              shape = generateSolidBlock(current, x, y, z, current.blocks[x][y][z]);
              if (shape != null)
                mesh.addChild(shape);
            }

      for (blockInfo bl : semiTransparents) { // draw semi-transparent blocks
        if (bl.id == 102)
          shape = generateCactusBlock(current, bl.x, bl.y+128, bl.z, bl.id);
        else if (bl.id == 101)
          shape = generateGlassBlock (current, bl.x, bl.y+128, bl.z, bl.id);
        else
          shape = generateSolidBlock (current, bl.x, bl.y+128, bl.z, bl.id);

        if (shape != null)
          mesh.addChild(shape);
      }

      if (mesh.getChildCount() > 0) {
        mesh.translate(current.x*16, 0, current.z*16);
        current.mesh = mesh;
      }
      if (fluidMesh.getChildCount() > 0) {
        fluidMesh.translate(current.x*16, 0, current.z*16);
        current.fluidMesh = fluidMesh;
      }
    }
}

PShape generateSolidBlock(Chunk current, byte x, int y, byte z, byte id) {
  PShape shape = createShape(GROUP), face;

  //right
  if ((x!=0 && (current.blocks[x-1][y][z] == 0 || current.blocks[x-1][y][z] >= 100)) || (x == 0 && current.neigh[2] != null && (current.neigh[2].blocks[15][y][z] == 0 || current.neigh[2].blocks[15][y][z] >= 100))) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(200);
    face.textureMode(NORMAL);
    face.vertex(-0.5, 0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //left
  if (x!=15 && (current.blocks[x+1][y][z] == 0 || current.blocks[x+1][y][z] >= 100) || (x == 15 && current.neigh[1] != null && (current.neigh[1].blocks[0][y][z] == 0 || current.neigh[1].blocks[0][y][z] >= 100))) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(200);
    face.textureMode(NORMAL);
    face.vertex(0.5, 0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(0.5, -0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(0.5, -0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //front
  if ((z!=0 && (current.blocks[x][y][z-1] == 0 || current.blocks[x][y][z-1] >= 100)) || (z == 0 && current.neigh[3] != null && (current.neigh[3].blocks[x][y][15] == 0 || current.neigh[3].blocks[x][y][15] >= 100))) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(180);
    face.textureMode(NORMAL);
    face.vertex(0.5, -0.5, -0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, -0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //back
  if ((z!=15 && (current.blocks[x][y][z+1] == 0 || current.blocks[x][y][z+1] >= 100)) || (z == 15 && current.neigh[0] != null && (current.neigh[0].blocks[x][y][0] == 0 || current.neigh[0].blocks[x][y][0] >= 100))) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(180);
    face.textureMode(NORMAL);
    face.vertex(0.5, -0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, 0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, 0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //down
  if (y==0 || current.blocks[x][y-1][z] == 0 || current.blocks[x][y-1][z] >= 100) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.textureMode(NORMAL);
    face.vertex(0.5, 0.5, -0.5, map((uvs[id].botx+1)*16, 0, 256, 0, 1), map(uvs[id].boty*16, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, 0.5, map(uvs[id].botx*16, 0, 256, 0, 1), map(uvs[id].boty*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, 0.5, map(uvs[id].botx*16, 0, 256, 0, 1), map((uvs[id].boty+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, -0.5, map((uvs[id].botx+1)*16, 0, 256, 0, 1), map((uvs[id].boty+1)*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //up
  if (y==255 || current.blocks[x][y+1][z] == 0 || current.blocks[x][y+1][z] >= 100) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.textureMode(NORMAL);
    face.vertex(0.5, -0.5, -0.5, map((uvs[id].topx+1)*16, 0, 256, 0, 1), map(uvs[id].topy*16, 0, 256, 0, 1));
    face.vertex(0.5, -0.5, 0.5, map(uvs[id].topx*16, 0, 256, 0, 1), map(uvs[id].topy*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, 0.5, map(uvs[id].topx*16, 0, 256, 0, 1), map((uvs[id].topy+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, -0.5, map((uvs[id].topx+1)*16, 0, 256, 0, 1), map((uvs[id].topy+1)*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  if (shape.getChildCount() > 0) {
    shape.translate(x, -y, z);
    return shape;
  }
  return null;
}

PShape generateFluidBlock(Chunk current, byte x, int y, byte z, byte id) {
  PShape shape = createShape(GROUP), face;

  //right
  if ((x!=0 && current.blocks[x-1][y][z] == 0) || (x == 0 && current.neigh[2] != null && current.neigh[2].blocks[15][y][z] == 0)) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(255, 200);
    face.textureMode(NORMAL);
    face.vertex(-0.5, 0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16-1, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, 0.5, map((uvs[id].sidex+1)*16-1, 0, 256, 0, 1), map((uvs[id].sidey+1)*16-1, 0, 256, 0, 1));
    face.vertex(-0.5, -0.4375, 0.5, map((uvs[id].sidex+1)*16-1, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.4375, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //left
  if (x!=15 && current.blocks[x+1][y][z] == 0 || (x == 15 && current.neigh[1] != null && current.neigh[1].blocks[0][y][z] == 0)) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(255, 200);
    face.textureMode(NORMAL);
    face.vertex(0.5, 0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16-1, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, 0.5, map((uvs[id].sidex+1)*16-1, 0, 256, 0, 1), map((uvs[id].sidey+1)*16-1, 0, 256, 0, 1));
    face.vertex(0.5, -0.4375, 0.5, map((uvs[id].sidex+1)*16-1, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(0.5, -0.4375, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //front
  if ((z!=0 && current.blocks[x][y][z-1] == 0) || (z == 0 && current.neigh[3] != null && current.neigh[3].blocks[x][y][15] == 0)) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(255, 200);
    face.textureMode(NORMAL);
    face.vertex(0.5, -0.4375, -0.5, map((uvs[id].sidex+1)*16-1, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, -0.5, map((uvs[id].sidex+1)*16-1, 0, 256, 0, 1), map((uvs[id].sidey+1)*16-1, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16-1, 0, 256, 0, 1));
    face.vertex(-0.5, -0.4375, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //back
  if ((z!=15 && current.blocks[x][y][z+1] == 0) || (z == 15 && current.neigh[0] != null && current.neigh[0].blocks[x][y][0] == 0)) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(255, 200);
    face.textureMode(NORMAL);
    face.vertex(0.5, -0.4375, 0.5, map((uvs[id].sidex+1)*16-1, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, 0.5, map((uvs[id].sidex+1)*16-1, 0, 256, 0, 1), map((uvs[id].sidey+1)*16-1, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, 0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16-1, 0, 256, 0, 1));
    face.vertex(-0.5, -0.4375, 0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //down
  if (y==0 || current.blocks[x][y-1][z] == 0) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(255, 200);
    face.textureMode(NORMAL);
    face.vertex(0.5, 0.5, -0.5, map((uvs[id].botx+1)*16, 0, 256, 0, 1), map(uvs[id].boty*16, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, 0.5, map(uvs[id].botx*16, 0, 256, 0, 1), map(uvs[id].boty*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, 0.5, map(uvs[id].botx*16, 0, 256, 0, 1), map((uvs[id].boty+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, -0.5, map((uvs[id].botx+1)*16, 0, 256, 0, 1), map((uvs[id].boty+1)*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //up
  if (y==255 || current.blocks[x][y+1][z] != 110) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(255, 200);
    face.textureMode(NORMAL);
    face.vertex(0.5, -0.4375, -0.5, map((uvs[id].topx+1)*16, 0, 256, 0, 1), map(uvs[id].topy*16, 0, 256, 0, 1));
    face.vertex(0.5, -0.4375, 0.5, map(uvs[id].topx*16, 0, 256, 0, 1), map(uvs[id].topy*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.4375, 0.5, map(uvs[id].topx*16, 0, 256, 0, 1), map((uvs[id].topy+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.4375, -0.5, map((uvs[id].topx+1)*16, 0, 256, 0, 1), map((uvs[id].topy+1)*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  if (shape.getChildCount() > 0) {
    shape.translate(x, -y, z);
    return shape;
  }

  return null;
}

PShape generateGlassBlock(Chunk current, byte x, int y, byte z, byte id) {
  PShape shape = createShape(GROUP), face;

  //right
  if ((x!=0 && (current.blocks[x-1][y][z] == 0 || current.blocks[x-1][y][z] > 101)) || (x == 0 && current.neigh[2] != null && (current.neigh[2].blocks[15][y][z] == 0 || current.neigh[2].blocks[15][y][z] > 101))) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(200);
    face.textureMode(NORMAL);
    face.vertex(-0.5, 0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //left
  if (x!=15 && (current.blocks[x+1][y][z] == 0 || current.blocks[x+1][y][z] > 101) || (x == 15 && current.neigh[1] != null && (current.neigh[1].blocks[0][y][z] == 0 || current.neigh[1].blocks[0][y][z] > 101))) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(200);
    face.textureMode(NORMAL);
    face.vertex(0.5, 0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(0.5, -0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(0.5, -0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //front
  if ((z!=0 && (current.blocks[x][y][z-1] == 0 || current.blocks[x][y][z-1] > 101)) || (z == 0 && current.neigh[3] != null && (current.neigh[3].blocks[x][y][15] == 0 || current.neigh[3].blocks[x][y][15] > 101))) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(180);
    face.textureMode(NORMAL);
    face.vertex(0.5, -0.5, -0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, -0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //back
  if ((z!=15 && (current.blocks[x][y][z+1] == 0 || current.blocks[x][y][z+1] > 101)) || (z == 15 && current.neigh[0] != null && (current.neigh[0].blocks[x][y][0] == 0 || current.neigh[0].blocks[x][y][0] > 101))) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(180);
    face.textureMode(NORMAL);
    face.vertex(0.5, -0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, 0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, 0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //down
  if (y==0 || current.blocks[x][y-1][z] == 0 || current.blocks[x][y-1][z] > 101) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.textureMode(NORMAL);
    face.vertex(0.5, 0.5, -0.5, map((uvs[id].botx+1)*16, 0, 256, 0, 1), map(uvs[id].boty*16, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, 0.5, map(uvs[id].botx*16, 0, 256, 0, 1), map(uvs[id].boty*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, 0.5, map(uvs[id].botx*16, 0, 256, 0, 1), map((uvs[id].boty+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, -0.5, map((uvs[id].botx+1)*16, 0, 256, 0, 1), map((uvs[id].boty+1)*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //up
  if (y==255 || current.blocks[x][y+1][z] == 0 || current.blocks[x][y+1][z] > 101) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.textureMode(NORMAL);
    face.vertex(0.5, -0.5, -0.5, map((uvs[id].topx+1)*16, 0, 256, 0, 1), map(uvs[id].topy*16, 0, 256, 0, 1));
    face.vertex(0.5, -0.5, 0.5, map(uvs[id].topx*16, 0, 256, 0, 1), map(uvs[id].topy*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, 0.5, map(uvs[id].topx*16, 0, 256, 0, 1), map((uvs[id].topy+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, -0.5, map((uvs[id].topx+1)*16, 0, 256, 0, 1), map((uvs[id].topy+1)*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  if (shape.getChildCount() > 0) {
    shape.translate(x, -y, z);
    return shape;
  }
  return null;
}

PShape generateCactusBlock(Chunk current, byte x, int y, byte z, byte id) {
  PShape shape = createShape(GROUP), face;

  //right
  if ((x!=0 && (current.blocks[x-1][y][z] == 0 || current.blocks[x-1][y][z] >= 100)) || (x == 0 && current.neigh[2] != null && (current.neigh[2].blocks[15][y][z] == 0 || current.neigh[2].blocks[15][y][z] >= 100))) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(200);
    face.textureMode(NORMAL);
    face.vertex(-0.4375, 0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.4375, 0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.4375, -0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(-0.4375, -0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //left
  if (x!=15 && (current.blocks[x+1][y][z] == 0 || current.blocks[x+1][y][z] >= 100) || (x == 15 && current.neigh[1] != null && (current.neigh[1].blocks[0][y][z] == 0 || current.neigh[1].blocks[0][y][z] >= 100))) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(200);
    face.textureMode(NORMAL);
    face.vertex(0.4375, 0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(0.4375, 0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(0.4375, -0.5, 0.5, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(0.4375, -0.5, -0.5, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //front
  if ((z!=0 && (current.blocks[x][y][z-1] == 0 || current.blocks[x][y][z-1] >= 100)) || (z == 0 && current.neigh[3] != null && (current.neigh[3].blocks[x][y][15] == 0 || current.neigh[3].blocks[x][y][15] >= 100))) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(180);
    face.textureMode(NORMAL);
    face.vertex(0.5, -0.5, -0.4375, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, -0.4375, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, -0.4375, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, -0.4375, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //back
  if ((z!=15 && (current.blocks[x][y][z+1] == 0 || current.blocks[x][y][z+1] >= 100)) || (z == 15 && current.neigh[0] != null && (current.neigh[0].blocks[x][y][0] == 0 || current.neigh[0].blocks[x][y][0] >= 100))) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.tint(180);
    face.textureMode(NORMAL);
    face.vertex(0.5, -0.5, 0.4375, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, 0.4375, map((uvs[id].sidex+1)*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, 0.4375, map(uvs[id].sidex*16, 0, 256, 0, 1), map((uvs[id].sidey+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, 0.4375, map(uvs[id].sidex*16, 0, 256, 0, 1), map(uvs[id].sidey*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //down
  if (y==0 || current.blocks[x][y-1][z] == 0 || current.blocks[x][y-1][z] >= 100) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.textureMode(NORMAL);
    face.vertex(0.5, 0.5, -0.5, map((uvs[id].botx+1)*16, 0, 256, 0, 1), map(uvs[id].boty*16, 0, 256, 0, 1));
    face.vertex(0.5, 0.5, 0.5, map(uvs[id].botx*16, 0, 256, 0, 1), map(uvs[id].boty*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, 0.5, map(uvs[id].botx*16, 0, 256, 0, 1), map((uvs[id].boty+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, 0.5, -0.5, map((uvs[id].botx+1)*16, 0, 256, 0, 1), map((uvs[id].boty+1)*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  //up
  if (y==255 || current.blocks[x][y+1][z] == 0 || current.blocks[x][y+1][z] >= 100) {
    face = createShape();
    face.beginShape();
    face.noStroke();
    face.texture(img);
    face.textureMode(NORMAL);
    face.vertex(0.5, -0.5, -0.5, map((uvs[id].topx+1)*16, 0, 256, 0, 1), map(uvs[id].topy*16, 0, 256, 0, 1));
    face.vertex(0.5, -0.5, 0.5, map(uvs[id].topx*16, 0, 256, 0, 1), map(uvs[id].topy*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, 0.5, map(uvs[id].topx*16, 0, 256, 0, 1), map((uvs[id].topy+1)*16, 0, 256, 0, 1));
    face.vertex(-0.5, -0.5, -0.5, map((uvs[id].topx+1)*16, 0, 256, 0, 1), map((uvs[id].topy+1)*16, 0, 256, 0, 1));
    face.endShape();
    shape.addChild(face);
  }

  if (shape.getChildCount() > 0) {
    shape.translate(x, -y, z);
    return shape;
  }
  
  return null;
}

//strores a block
class blockInfo {
  byte x, y, z, id;
  blockInfo(byte x, byte y, byte z, byte id) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.id = id;
  }
}
