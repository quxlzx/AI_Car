// AI Car: evolving five-sensor drivers. Processing 4 / Java mode.
final int POPULATION_SIZE = 120;
final int MAX_TICKS = 3000;
final int STALL_TICKS = 240;
final float SENSOR_RANGE = 100.0f;
final float CHECKPOINT_RADIUS = 23.0f;
population pop;
Car car;
map track;
PImage cars, bestG, ai;
ArrayList<PVector> checkpoint = new ArrayList<PVector>();
boolean upPressed, downPressed, leftPressed, rightPressed, spacePressed;
boolean paused = false, manual = false, showSensors = false, showCheckpoints = false;
int simulationSpeed = 1;
float viewScale, viewX, viewY;

public void settings() { size(1200, 780); }
public void setup() {
  surface.setTitle("AI Car — Evolutionary Driving");
  frameRate(60);
  cars = loadImage("CarPlayer.png");
  bestG = loadImage("CarPlayer1.png");
  ai = loadImage("CarPlayer2.png");
  PImage road = loadImage("RaceTrack5.png");
  if (road == null) throw new IllegalStateException("Missing data/RaceTrack5.png. Extract the entire sketch folder first.");
  initialize(road);
}

// Kept separate from the display so the real simulation can be tested headlessly.
void initialize(PImage road) {
  track = new map(road);
  checkpoint.clear();
  float[][] route = {
    {220,38},{350,34},{480,28},{620,25},{770,27},{866,55},
    {906,153},{897,266},{891,383},{890,497},{867,579},{803,631},
    {666,637},{526,638},{385,637},{245,629},{120,617},{67,569},
    {56,521},{96,494},{178,475},{245,473},{288,434},{312,396},
    {281,359},{211,335},{148,314},{126,283},{136,253},{193,224},
    {266,226},{344,254},{401,316},{416,383},{397,458},{375,523},
    {478,527},{583,547},{667,551},{748,526},{794,480},{820,412},
    {823,310},{823,211},{827,139},{775,112},{731,111},{723,156},
    {741,236},{740,330},{732,404},{691,453},{597,448},{533,438},
    {501,409},{503,373},{552,344},{609,322},{639,279},{648,211},
    {636,153},{610,125},{566,121},{533,136},{525,182},{525,226},
    {487,214},{422,176},{349,149},{257,128},{170,121},{92,121},
    {39,106},{24,77},{57,51},{110,42},{140,40}
  };
  for (float[] point : route) {
    if (!track.isRoad(point[0], point[1])) throw new IllegalStateException("Checkpoint is off track");
    checkpoint.add(new PVector(point[0], point[1]));
  }
  resetSimulation();
}
void resetSimulation() {
  pop = new population(POPULATION_SIZE);
  car = new Car();
  car.player = true;
  paused = false;
  clearKeys();
}
void clearKeys() { upPressed = downPressed = leftPressed = rightPressed = spacePressed = false; }
public void draw() {
  // Clear held input when focus is lost; otherwise a released key could stick.
  if (!focused) clearKeys();
  if (!paused) {
    if (manual) car.move((upPressed ? 1 : 0) - (downPressed ? 1 : 0),
      (rightPressed ? 1 : 0) - (leftPressed ? 1 : 0), spacePressed);
    else for (int i = 0; i < simulationSpeed; i++) pop.update();
  }
  background(19, 25, 34);
  viewScale = min((width - 280.0f) / track.road.width, (height - 100.0f) / track.road.height);
  viewX = 16; viewY = 66;
  pushMatrix();
  translate(viewX, viewY); scale(viewScale);
  track.show();
  if (showCheckpoints) {
    noFill(); stroke(255, 216, 86, 140); strokeWeight(1);
    for (int i = 0; i < checkpoint.size(); i++) {
      PVector point = checkpoint.get(i);
      ellipse(point.x, point.y, CHECKPOINT_RADIUS * 2, CHECKPOINT_RADIUS * 2);
      fill(255); textSize(9); text(i + 1, point.x, point.y); noFill();
    }
  }
  Car leader = manual ? car : pop.isBest();
  if (manual) car.show(); else { pop.show(); leader.show(); }
  if (showSensors && !leader.done()) leader.c.show(leader.pos, leader.dir);
  popMatrix();
  fill(240); textSize(24); text("AI CAR", 20, 36);
  textSize(14); fill(160, 190, 208); text("Five sensors. Evolving drivers.", 150, 34);
  float panel = width - 245;
  fill(240); textSize(20); text(manual ? "MANUAL DRIVE" : "TRAINING", panel, 90);
  textSize(15);
  text("Generation: " + pop.gen, panel, 132);
  text("Active: " + pop.alive() + " / " + POPULATION_SIZE, panel, 163);
  text("Best ever: " + pop.bestEverScore + " / " + checkpoint.size(), panel, 194);
  text("Current: " + leader.score + " / " + checkpoint.size(), panel, 225);
  text("Completed laps: " + pop.completedLaps, panel, 256);
  text("Simulation: " + simulationSpeed + "x", panel, 287);
  text("Driver time: " + nf(leader.ticks / 60.0f, 1, 1) + " s", panel, 318);
  text("FPS: " + round(frameRate), panel, 349);
  fill(123, 218, 185);
  String status = paused ? "PAUSED" : leader.reachGoal ? "LAP COMPLETE" : leader.dead ? "CRASHED / TIMED OUT" : "RUNNING";
  text(status, panel, 392);
  fill(190); textSize(14);
  text("M   Training / manual\nP   Pause / resume\nR   Reset training + player\nV   Sensor rays\nC   Checkpoints\n+ / -   Training speed\n\nW / S   Accelerate / reverse\nA / D   Steer\nSpace   Brake\nEnter   Restart player", panel, 440);
}
public void keyPressed() {
  char k = Character.toLowerCase(key);
  if (k == 'w') upPressed = true;
  if (k == 's') downPressed = true;
  if (k == 'a') leftPressed = true;
  if (k == 'd') rightPressed = true;
  if (k == ' ') spacePressed = true;
  if (k == 'm') { manual = !manual; clearKeys(); }
  if (k == 'p') paused = !paused;
  if (k == 'r') resetSimulation();
  if (k == 'v') showSensors = !showSensors;
  if (k == 'c') showCheckpoints = !showCheckpoints;
  if (k == '+' || k == '=') simulationSpeed = min(10, simulationSpeed + 1);
  if (k == '-') simulationSpeed = max(1, simulationSpeed - 1);
  if (key == ENTER || key == RETURN) { car = new Car(); car.player = true; clearKeys(); }
}
public void keyReleased() {
  char k = Character.toLowerCase(key);
  if (k == 'w') upPressed = false;
  if (k == 's') downPressed = false;
  if (k == 'a') leftPressed = false;
  if (k == 'd') rightPressed = false;
  if (k == ' ') spacePressed = false;
}
