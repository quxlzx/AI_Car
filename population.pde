class population {
  Car[] dots;
  int gen = 1, bestEverScore = 0, completedLaps = 0;
  float bestEverFitness = -1;
  Brain champion;
  population(int size) {
    if (size < 2) throw new IllegalArgumentException("Evolution requires at least two cars");
    dots = new Car[size];
    for (int i = 0; i < size; i++) dots[i] = new Car();
  }
  void update() {
    if (allDead()) { nextGeneration(); return; }
    for (Car driver : dots) {
      boolean finished = driver.reachGoal;
      driver.move();
      if (!finished && driver.reachGoal) completedLaps++;
      bestEverScore = max(bestEverScore, driver.score);
    }
  }
  boolean allDead() { for (Car driver : dots) if (!driver.done()) return false; return true; }
  int alive() { int count = 0; for (Car driver : dots) if (!driver.done()) count++; return count; }
  Car isBest() {
    Car leader = dots[0]; leader.calcFit();
    for (Car driver : dots) { driver.calcFit(); if (driver.fit > leader.fit) leader = driver; }
    return leader;
  }
  Car parent() {
    // Tournament selection avoids tiny-fitness roulette failures.
    Car winner = dots[(int)random(dots.length)];
    for (int i = 0; i < 4; i++) {
      Car candidate = dots[(int)random(dots.length)];
      if (candidate.fit > winner.fit) winner = candidate;
    }
    return winner;
  }
  void nextGeneration() {
    Car winner = isBest();
    if (winner.fit > bestEverFitness) { bestEverFitness = winner.fit; champion = winner.brain.copy(); }
    Car[] children = new Car[dots.length];
    children[0] = new Car(); children[0].brain = champion.copy(); children[0].best = true;
    for (int i = 1; i < children.length; i++) {
      // Fresh random drivers preserve diversity when a local optimum stalls.
      if (i >= children.length * 9 / 10) children[i] = new Car();
      else { children[i] = parent().baby(); children[i].brain.mutate(); }
    }
    dots = children; gen++;
  }
  void show() { for (Car driver : dots) if (!driver.best) driver.show(); dots[0].show(); }
}
