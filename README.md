# Please note that this is an alpha plugin and has not been fleshed out or extensively tested.

# Chunx - the Open World chunking solution for Godot 4.2+

This plugin allows for easy partitioning of *authored* game worlds into streamable chunks.
**Please note that this is *not* for procedurally generated worlds, like Minecraft.**
This is inspired by the WorldStreamer addon for Unity.

## Why?

If you're creating an open world game, eventually there will be so many objects in a particularly large scene that not only the game, but the editor as well, will slow down.
This is where chunking comes in - Smaller objects are streamed in and out of the game as the player or editor moves around, keeping overhead to a minimum.
Chunx is a simple plugin that does exactly this.

## Features

- Edit chunks inside the editor without hassle
- Customize chunk sizes and loading radius, allowing for HLOD
- Stream chunks in-game

## How does it work?

1. When in the Godot editor, manipulate objects as you please. Chunks will be loaded in and out around the editor camera. Any Node3D placed within the heirarchy directly under a WorldStreamer node will be sorted into a partition.
2. When a Node3D is moved about the editor, it will get automatically sorted into the correct chunk as it moves around.
3. The chunk is saved to disk, and will be loaded and unloaded as the editor camera, or the game's main camera, moves about.

## Get started

1. Install the plugin by downloading the Chunx addon into the addons folder, or clone the [submodule](https://github.com/SlashScreen/chunx-submodule).
2. Enable the addon in project settings.
3. Place a `WorldStreamer` node into your world, and configure it however you please. Chunk dimensions are in meters, Godot's standard unit. The Chunk Dir is the directory that chunks will be saved in.
4. Place any Node3D into the tree directly beneath the `WorldStreamer`. It will be partitioned into a chunk.
5. Move about any Node3D beneath a `WorldChunk` node, and it will be placed into new chunks as needed. *Only* Node3Ds directly beneath the chunk node will be repartitioned; this is to prevent more complex heirarchoes (like an NPC) being torn apart when moving across chunk borders. 
6. It should Just Work as you play the scene in-game, provided there is an active Camera3D.

## Project Status

**Beta** - It is a bit janky, but it should still work.

## Known Issues

- [ ] Annoying "files are newer on disk" popup. Simply click "Reload".
- [ ] Selection weirdness around chunk borders. This can be ignored.
- [ ] Error when new chunks are created. This can be ignored.
