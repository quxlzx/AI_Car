# Contributing

This is a personal learning project preserved from over five years ago. Small fixes, clearer explanations, and experiments that keep the Processing sketch approachable are welcome.

Open `AI_Car.pde` in Processing 4 (Java mode). Keep the folder named `AI_Car` so Processing recognizes the sketch, and keep the images in `data/`.

Before proposing a change:

1. Describe the behavior you are changing and why.
2. Run the headless regression suite using the command in [README.md](README.md#testing).
3. For input or display changes, also run the sketch in the Processing IDE and check the relevant controls. Headless rendering cannot exercise physical keyboard input.

Simulation changes should preserve bounded sensors, immutable road collision data, independent copied controller weights, and terminal states for crashed, stalled, and finished cars. Add regression coverage when changing these behaviors. The existing suite expects the default population size of 120 and uses a fixed random seed.

To try a new track, provide a valid spawn and ordered checkpoints for that image; changing the image filename alone is not enough. Avoid committing compiler JARs, exported applications, editor settings, or credentials.
