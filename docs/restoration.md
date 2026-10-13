# Restoration notes

The supplied working copy already contained these repairs. They are documented here to distinguish the restored behavior from the original learning project. The original source history was not included in this folder.


- Initialized the player car and expanded the single-car population to 120. The original one-car population never mutated because mutation skipped its only car.
- Replaced mismatched fullscreen/image scaling with one native track coordinate system and a scaled view. Checkpoints now follow this map around a full lap.
- Moved image assets to the standard Processing `data` folder. Removed the stale nested ZIP containing the broken source; retained all original images.
- Bounded sensor rays, stopped them at image edges, and prevented them from modifying the car position. The original rays could run forever outside the screen.
- Built an immutable collision mask from PNG opacity. Car sprites, sensor lines, and UI text cannot change collision results; the black/white finish line remains drivable.
- Added footprint collision detection and substeps to prevent fast cars skipping through walls.
- Replaced raw, saturating sensor inputs with normalized inputs, a separate bias, and continuous controller outputs. Copies have independent weights.
- Fixed evolutionary selection: tournament-selected parents, an unchanged champion, mutated offspring, and 10% fresh random drivers.
- Counted lap completion as a terminal state. Added generation and no-progress limits so training always advances even when cars stall.
- Moved scoring out of rendering, removed per-frame genome console spam, and separated simulation timing from wall-clock time.
- Added pause, reset, speed, checkpoint, sensor, and manual driving controls, including clearing held keys on focus loss.

The default track is `data/RaceTrack5.png`; the other original maps are retained as assets. Switching to another map requires supplying matching checkpoints and a valid starting position. Best genomes are kept in memory for this run; closing or resetting the sketch restarts training.
