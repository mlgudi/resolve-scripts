# Resolve Scripts
A dump of DaVinci Resolve/Fusion helper scripts/fuses/macros. These are written for my own use, so they may not be useful to you and are not guaranteed to work.

**Scripts**

[Timeline/MakeMain.lua](Scripts/Timeline/MakeMain.lua) sets a timeline as the primary timeline for a project, and [Timeline/SetMain.lua](Scripts/Timeline/SetMain.lua) sets it as the current timeline. For quickly getting back to the main timeline.

[SFX/SFX.lua](Scripts/SFX/SFX.lua) is a script that inserts audio to the timeline at the current playhead position. It accepts two args: clip name and track index. It is intended for use with hotkeys, more details [here](https://github.com/mlgudi/hotkey-fuscript).

**Fuses**

[ItemName.fuse](Fuses/OSRS/ItemName.fuse) is a fuse that outputs the name of an OSRS item by item ID. It requires [ItemNames.lua](Modules/OSRS/ItemNames.lua) is added to your Fusion Lua modules folder within the "OSRS" folder.

[ItemSprite.fuse](Fuses/OSRS/ItemSprite.fuse) is a fuse that extracts individual sprites from the OSRS item sprite sheet by item ID. The sprite sheet can be found [here](Fuses/OSRS/sprite_sheet.png).

**Macros**

[Pulse.setting](Macros/Pulse.setting) is a macro that loops a scale up/down animation with configurable scale, duration, and easing.

[InOut.setting](Macros/InOut.setting) is a utility macro for animating in/out based on a progress value. You set the in/out durations in frames and it'll go from 0 to 1 at the start and 1 to 0 at the end according to the in/out and easing.