class checkForWall {
  final float[] angles = {0, -PI / 4, PI / 4, -PI / 2, PI / 2};
  float[] checkWall(PVector position, float direction) {
    float[] distances = new float[angles.length];
    for (int i = 0; i < angles.length; i++) {
      float dx = cos(direction + angles[i]), dy = sin(direction + angles[i]);
      // Bounded rays sample the immutable map and never mutate the car.
      float distance = 0;
      while (distance < SENSOR_RANGE && track.isRoad(position.x + dx * distance, position.y + dy * distance)) distance += 2;
      distances[i] = min(distance, SENSOR_RANGE);
    }
    return distances;
  }
  void show(PVector position, float direction) {
    float[] distances = checkWall(position, direction);
    stroke(0, 225, 255, 180); strokeWeight(1);
    for (int i = 0; i < angles.length; i++) line(position.x, position.y,
      position.x + cos(direction + angles[i]) * distances[i],
      position.y + sin(direction + angles[i]) * distances[i]);
  }
}
