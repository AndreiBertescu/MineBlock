//exit function
public class DisposeHandler {
  DisposeHandler(PApplet pa) {
    pa.registerMethod("dispose", this);
  }

  public void dispose() {
    output.flush();
    output.close();
    saveData();
  }
}

//function for saving config.txt - saves current file position and other
void saveData() {
  output = createWriter(dataPath("") + "/save/config.txt");

  output.print(no + " " + (nr+1) + "\n");
  output.print(seed + "\n");
  output.print(player.x + " " + player.y + " " + player.z + "\n");
  output.print(player.angleLeftRight + " " + player.angleUpDown);

  output.flush();
  output.close();
}

//save thread - for saving when generating or on block update
void saveCh() {
  try {
    FileWriter fw = new FileWriter(dataPath("") + "/save/reg-" + no + ".txt", true);
    BufferedWriter bw = new BufferedWriter(fw);
    output = new PrintWriter(bw);
  }
  catch(Exception e) {
    println(e);
  }
  File f = new File("");
  String[] lines;
  char[] blocks;
  Chunk current;

  while (true)
    if (!saveBuffer.isEmpty()) {
      current = saveBuffer.pop();
      if (current.modified == -1) {  //if chunk is a new one
        if (++nr % 256 == 0) {
          output.flush();
          output.close();
          output = createWriter("data/save/reg-" + ++no + ".txt");
          nr = 0;
        }

        current.row = nr;
        current.file = no;

        output.print("\n" + current.x + " " + current.z + " " + current.miny + " " + current.maxy + " ");
        for (int y=0; y<256; y++)
          for (int x=0; x<16; x++)
            for (int z=0; z<16; z++)
              output.print(char(current.blocks[x][y][z] + 14));
      } else {  //if chunk is modified
        if (!f.getName().equals("reg-" + current.file + ".txt"))
          f = new File(dataPath("") + "/save/reg-" + current.file + ".txt");
        lines = loadStrings(f);

        if (current.modified == -3) { //full chunk save
          lines[current.row] = (current.x + " " + current.z + " " + current.miny + " " + current.maxy + " ");
          for (int y=0; y<256; y++)
            for (int x=0; x<16; x++)
              for (int z=0; z<16; z++)
                lines[current.row] += char(current.blocks[x][y][z] + 14);
        } else if (current.modified == -2) //save min & max heights
          lines[current.row] = (current.x + " " + current.z + " " + current.miny + " " + current.maxy + " " + lines[current.row].split(" ")[4]);
        else { //save modified block
          blocks = lines[current.row].split(" ")[4].toCharArray();
          blocks[current.modified] = char(current.modifiedId + 14);
          lines[current.row] = (current.x + " " + current.z + " " + current.miny + " " + current.maxy + " " + String.valueOf(blocks));
        }

        saveStrings(f, lines);
      }
    }
}

//function for loading config.txt
void loadData(boolean makeNewWorld) {
  if (makeNewWorld) {
    File f = new File(dataPath("") + "/save/config.txt");
    if (f.exists())
      f.delete();

    int nr = 0;
    while (true) {
      f = new File(dataPath("") + "/save/reg-" + nr++ + ".txt");
      if (f.exists())
        f.delete();
      else
        return;
    }
  }

  File f = new File(dataPath("") + "/save/config.txt");
  if (!f.exists())
    return;

  String[] lines, coords;
  lines = loadStrings(f);

  //file position information
  try {
    coords = lines[0].split(" ");
    no = Integer.parseInt(coords[0]);
    nr = Integer.parseInt(coords[1]);
  }
  catch(Exception e) {
    println(e);
  }

  //world seed
  try {
    seed = Integer.parseInt(lines[1]);
  }
  catch(Exception e) {
    println(e);
  }

  //player position
  try {
    coords = lines[2].split(" ");
    playerPos.x = Float.parseFloat(coords[0]);
    playerPos.y = Float.parseFloat(coords[1]);
    playerPos.z = Float.parseFloat(coords[2]);
  }
  catch(Exception e) {
    println(e);
  }

  //orientation
  try {
    coords = lines[3].split(" ");
    playerOrt.x = Float.parseFloat(coords[0]);
    playerOrt.y = Float.parseFloat(coords[1]);
  }
  catch(Exception e) {
    println(e);
  }
}

//load function - for loading all existing chunks at runtime
void load(ArrayList<Chunk> chunks) {
  int no = 0, nr, x, y, z, i;
  String[] coords, lines;
  Chunk current;
  File f;

  while (true) {
    f = new File(dataPath("") + "/save/reg-" + no++ + ".txt");
    if (!f.exists())
      break;

    lines = loadStrings(f);

    for (i = 1; i < lines.length; i++) {
      coords = lines[i].split(" ");
      if (lines[i].matches(""))
        continue;
      chunks.add(new Chunk(Integer.parseInt(coords[0]), Integer.parseInt(coords[1]), true));

      current = chunks.get(chunks.size()-1);
      current.miny = Byte.parseByte(coords[2]);
      current.maxy = Byte.parseByte(coords[3]);
      current.row = i;
      current.file = no-1;
      nr = 0;

      for ( y=0; y<256; y++)
        for ( x=0; x<16; x++)
          for ( z=0; z<16; z++) {
            try {
              current.blocks[x][y][z] = (byte)(coords[4].charAt(nr++) - 14);
            }
            catch(Exception e) {
              println(no-1, i, nr);
            }
          }
    }
  }
}
