import java.text.*;
import java.io.*;
import java.util.Iterator;

Stack<Chunk> loadBuffer, updateBuffer, saveBuffer;
PFont regular;
Player player;
Chunks chunks;
PImage img;
Gui debug;
Hud hud;
int time = 0, waterFrame = 0;

//save-load stuff
PVector playerPos, playerOrt;
PrintWriter output;
DisposeHandler dh;
int no, nr, seed;

//textures coords
uv[] uvs;

//settings
//press wasd to move
//press '/' to toggle game modes
//press ctrl/space to descend/ascend
//press shift to sprint
//press f4 to reload chuncks
//press f3 to enable/disable debug overlay
//press f2 to enable/disable hud
int renderDist = 4;
float maxVel = 0.2;
float jumpStrength = 0.32;
float fov = 60;
float sensx = 0.2, sensy = 2;
int framerate = 60;
int tickrate = 20;
boolean createNewWorld = true;

void setup() {
  fullScreen(P3D);
  noSmooth();
  frameRate(framerate);
  blendMode(BLEND);
  hint(ENABLE_DEPTH_SORT);

  dh = new DisposeHandler(this);
  ((PGraphicsOpenGL)g).textureSampling(3);
  regular = createFont("data/MinecraftRegular.otf", 10);

  //texture stuff
  uvs = new uv[128];
  init();

  loadBuffer = new Stack<>();
  updateBuffer = new Stack<>();
  saveBuffer = new Stack<>();
  thread("updateCh");

  //initializing config public parameters
  no = 0;
  nr = 0;
  seed = floor(random(5000000));
  playerPos = new PVector(-1, -1, -1);
  playerOrt = new PVector(-1, -1);
  loadData(createNewWorld); //true if you want to create new world
  thread("generateCh");
  thread("saveCh");

  chunks = new Chunks();
  player = new Player();
  debug = new Gui();
  hud = new Hud();
}

void draw() {
  //for water animation
  if (millis() - time > 900) {

    img.loadPixels();
    for (int i=0; i<15; i++)
      for (int j=0; j<15; j++)
        switch(waterFrame) {
          case(0):
          img.pixels[i*256 + (256 * 16 * 12) + j + 16 * 13] = img.pixels[i*256 + (256 * 16 * 12 + 256*8) + j + (16 * 14 + 8)];
          break;
          case(1):
          img.pixels[i*256 + (256 * 16 * 12) + j + 16 * 13] = img.pixels[i*256 + (256 * 16 * 12 + 256*9) + j + 16 * 14 + 8];
          break;
          case(2):
          img.pixels[i*256 + (256 * 16 * 12) + j + 16 * 13] = img.pixels[i*256 + (256 * 16 * 12 + 256*8) + j + 16 * 14 + 7];
          break;
          case(3):
          img.pixels[i*256 + (256 * 16 * 12) + j + 16 * 13] = img.pixels[i*256 + (256 * 16 * 12 + 256*7) + j + 16 * 14 + 9];
          break;
          case(4):
          img.pixels[i*256 + (256 * 16 * 12) + j + 16 * 13] = img.pixels[i*256 + (256 * 16 * 12 + 256*9) + j + 16 * 14 + 8];
          break;
        }
    img.updatePixels();

    time = millis();
    if (waterFrame++ >= 4)
      waterFrame = 0;
  }
  //every frame
  background(135, 206, 235);

  player.checkLookAt();
  updateControls();
  player.update();
  chunks.update();
  chunks.show();

  if (debug.show && hud.show)
    debug.show();
  if (hud.show)
    hud.show();
  perspective(radians(fov+fovSprint), (float)width/height, 0.1, 1000000);

  //every tick
  if (int(frameCount % (frameRate/tickrate)) == 0) {
    if (debug.show)
      debug.update();
  }
}
