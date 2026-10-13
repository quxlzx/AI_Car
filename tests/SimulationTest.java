import processing.core.*;
import javax.imageio.ImageIO;
import java.io.File;
import java.util.Arrays;

public class SimulationTest {
  static int checks = 0;
  static void check(boolean condition, String message) {
    checks++;
    if (!condition) throw new AssertionError(message);
  }
  public static void main(String[] args) throws Exception {
    AICar s = new AICar();
    s.randomSeed(42);
    s.initialize(new PImage(ImageIO.read(new File(args[0]))));
    check(s.car != null && s.pop.dots.length == 120, "Player and population initialized");
    check(s.car.onRoad(), "Spawn footprint is on the road");
    check(!s.track.isRoad(-1, 40) && !s.track.isRoad(2000, 40), "Bounds are walls");
    check(!s.track.isRoad(Float.NaN, 40), "Invalid coordinates are walls");
    check(s.track.isRoad(110, 42), "Checkered finish line is road");
    float x = s.car.pos.x, y = s.car.pos.y;
    float[] rays = s.car.c.checkWall(s.car.pos, 0);
    check(s.car.pos.x == x && s.car.pos.y == y, "Sensors cannot move the car");
    for (float distance : rays) check(distance >= 0 && distance <= s.SENSOR_RANGE, "Sensor range is bounded");
    check(s.car.c.checkWall(new PVector(-10, -10), 0)[0] == 0, "Out-of-bounds rays terminate");
    for (int i = 0; i < 40; i++) s.car.move(1, 0, false);
    check(s.car.pos.x > x && !s.car.dead, "Manual car accelerates in the heading direction");
    float speed = s.car.velocity;
    s.car.move(0, 0, true);
    check(s.car.velocity < speed, "Manual brake slows the car");
    s.car.pos.set(0, 0); s.car.move(1, 0, false);
    check(s.car.dead, "Off-road collision stops player");
    AICar.Car immobile = s.new Car();
    for (int i = 0; i <= s.STALL_TICKS; i++) immobile.advance(0);
    check(immobile.dead, "Stalled AI terminates");
    AICar.Car finish = s.new Car();
    finish.score = s.checkpoint.size() - 1; finish.pos.set(140, 40); finish.advance(0);
    check(finish.reachGoal && finish.done(), "Last checkpoint completes a lap");
    finish.calcFit(); check(Float.isFinite(finish.fit), "Finish fitness is finite");
    for (AICar.Car c : s.pop.dots) { c.reachGoal = true; c.score = s.checkpoint.size(); c.ticks = 1000; }
    check(s.pop.allDead() && s.pop.alive() == 0, "Finishers count as terminal, not active");
    s.pop.dots[7].ticks = 10;
    s.pop.dots[7].calcFit();
    float[][] elite = new float[2][];
    for (int row = 0; row < 2; row++) elite[row] = s.pop.dots[7].brain.weights[row].clone();
    s.pop.update();
    check(s.pop.gen == 2 && s.pop.alive() == 120, "Generation restarts after all finish");
    check(Arrays.equals(elite[0], s.pop.dots[0].brain.weights[0]) && Arrays.equals(elite[1], s.pop.dots[0].brain.weights[1]), "Fittest genome preserved exactly");
    check(s.pop.dots[0].brain.weights[0] != elite[0], "Elite has independent weights");
    boolean different = false;
    for (int i = 1; i < s.pop.dots.length; i++) different |= !Arrays.equals(elite[0], s.pop.dots[i].brain.weights[0]);
    check(different, "Offspring have genetic diversity");
    s.resetSimulation();
    float initial = -1;
    while (s.pop.gen <= 30) {
      s.pop.update();
      if (s.pop.gen == 2 && initial < 0) initial = s.pop.bestEverFitness;
    }
    check(s.pop.bestEverFitness > initial, "Seeded training improves fitness");
    check(s.pop.completedLaps > 0, "Seeded training completes the full racetrack");
    System.out.println("Training: generation 1 fitness=" + initial + "; generation 30 fitness=" + s.pop.bestEverFitness + "; best checkpoints=" + s.pop.bestEverScore + "/" + s.checkpoint.size());
    s.upPressed = true; s.paused = true; s.resetSimulation();
    check(!s.upPressed && !s.paused && s.pop.gen == 1 && s.car.onRoad(), "Reset restores a clean state");
    System.out.println("PASS: " + checks + " simulation regression checks");
  }
}
