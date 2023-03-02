# Twenkidnes

## Developing game engines and games on NES - Nintento Entertainment System

## NES_2

Original project examples and tutorials by NesHacker:  https://github.com/NesHacker/DevEnvironmentDemo

Thank you very much!

Studied, extended, animated, merged by Twenkid/Todor Arnaudov, 2/2023+

This version: 2.3.2023
http://twenkid.com
https://github.com/Twenkid
http://artificial-mind.blogspot.com


* demo.s is originally a static caption "HELLO", added another one "TOSHKO" in cyrillic
* Taking ideas from Halloween2021.s etc. https://github.com/NesHacker/Specials, but initially not directly, experimenting ... (Initially I forgot that RAM is in the low pages and tried to store the state of the moved coordinates of the sprites in the .code segment, which is read-only)
* See also apu2.s (fixed errors in the byte-layout of some segments, which caused compilation errors or blank screen)

**Next steps:**

* including music, animating more sprites (maybe modifying Halloween2021.s as well); sound must be synchronized to some global, common frame counters/timing sequence, built in the overall logic of the "engine".
* including noise and pulse channels, eventually DCM (that could be postponed)
* adding the tiles layer
* coordinates of the agent of the player
* control with the joypad, move left, right and jump (no obstacles)
* add obstacles and levels, a map to jump (no scroll)
* add scroll - horizontal: moving window of the map
* add NPCs
* add projectiles, shooting? and collision detection of the projectiles
* music: several sequences, switching the current one, depending on the location in the map
* add multiplayer, two playable characters
* etc.







