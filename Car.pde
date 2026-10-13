class Car {
  PVector pos = new PVector(140, 40);
  float dir = 0, velocity = 0, fit = 0;
  Brain brain = new Brain();
  checkForWall c = new checkForWall();
  boolean best = false, player = false, dead = false, reachGoal = false;
  int score = 0, ticks = 0, lastProgressTick = 0;
  boolean done() { return dead || reachGoal; }
  void move() {
    if (done()) return;
    float[] action = brain.decide(c.checkWall(pos, dir), velocity);
    float targetSpeed = 0.8f + (action[0] + 1) * 1.35f;
    velocity += constrain(targetSpeed - velocity, -0.12f, 0.12f);
    advance(action[1]);
  }
  void move(int throttle, int turn, boolean brake) {
    if (done()) return;
    if (brake) velocity *= 0.8f;
    else if (throttle != 0) velocity = constrain(velocity + throttle * 0.12f, -1.8f, 3.5f);
    else velocity *= 0.97f;
    advance(turn);
  }
  void advance(float steering) {
    ticks++;
    // Steering needs motion; reverse steering follows real reverse motion.
    dir += steering * 0.09f * constrain(velocity / 1.5f, -1, 1);
    int steps = max(1, (int)Math.ceil(abs(velocity)));
    for (int i = 0; i < steps; i++) {
      pos.x += cos(dir) * velocity / steps;
      pos.y += sin(dir) * velocity / steps;
      if (!onRoad()) { dead = true; velocity = 0; return; }
      PVector goal = checkpoint.get(score);
      if (PVector.dist(pos, goal) <= CHECKPOINT_RADIUS) {
        score++; lastProgressTick = ticks;
        if (score == checkpoint.size()) { reachGoal = true; velocity = 0; return; }
      }
    }
    if (!player && (ticks >= MAX_TICKS || ticks - lastProgressTick >= STALL_TICKS)) { dead = true; velocity = 0; }
  }
  boolean onRoad() {
    if (!track.isRoad(pos.x, pos.y)) return false;
    float dx = cos(dir), dy = sin(dir);
    for (int front = -1; front <= 1; front += 2)
      for (int side = -1; side <= 1; side += 2)
        if (!track.isRoad(pos.x + front * 7 * dx - side * 4 * dy, pos.y + front * 7 * dy + side * 4 * dx)) return false;
    return true;
  }
  void calcFit() {
    if (reachGoal) fit = checkpoint.size() + 2 + 1.0f / (1 + ticks / 60.0f);
    else {
      PVector from = score == 0 ? new PVector(140, 40) : checkpoint.get(score - 1);
      PVector to = checkpoint.get(score);
      float sx = to.x - from.x, sy = to.y - from.y;
      float projection = ((pos.x - from.x) * sx + (pos.y - from.y) * sy) / max(1, sx * sx + sy * sy);
      fit = 0.01f + score + constrain(projection, 0, 0.99f);
    }
  }
  Car baby() { Car result = new Car(); result.brain = brain.copy(); return result; }
  void show() {
    if (dead) return;
    pushMatrix(); translate(pos.x, pos.y); rotate(dir);
    PImage sprite = player ? cars : best ? bestG : ai;
    if (sprite != null) { imageMode(CENTER); image(sprite, 0, 0, 14, 9); }
    else { noStroke(); fill(player ? color(255) : best ? color(255, 220, 70) : color(90, 180, 255)); rect(-7, -4, 14, 8); }
    popMatrix();
  }
}
