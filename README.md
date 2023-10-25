# MineBlock
![image](https://github.com/AndreiBertescu/MineBlock/assets/126001291/7192a83a-d6e2-4672-b506-edfb29a66f63)

----------------------------
Disclaimer: This project is still a work in progress.

MineBlock is an attempt to recreate the famous game Minecraft using OpenGL and the Processing IDE.

**Features**:
- Infinite, seed-based, random terrain generation using multiple layers of 2D Perlin noise functions.
- Similar to Minecraft, it utilizes a chunk-based system, with each chunk consisting of 16x16x256 blocks.
- Efficient terrain rendering that displays only the block faces facing the air.
- Water mechanics, including water expansion when blocks are destroyed.
- A (basic) custom-made player camera.
- A hotbar system with preset blocks.
- An extensive palette of 8 different blocks.
- Full creative mode movement options and a somewhat buggy survival movement.
- The ability to place and break blocks.
- An inefficient save/load system that saves all blocks in each chunk.
- Toggleable HUD and debug screen.
- Four distinct biomes: plains, snow peaks, ocean, and desert.

**What it doesn't feature**:
- Proper transparent and semi-transparent block rendering, such as flowers and glass.
- A fully functional movement system for survival mode.
- An efficient save/load system in terms of storage space.
- A real lighting system.
