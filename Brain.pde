class Brain {
  // Five normalized distances, speed, and a bias; continuous throttle/steer.
  float[][] weights = new float[2][7];
  Brain() {
    for (int row = 0; row < weights.length; row++)
      for (int i = 0; i < weights[row].length; i++) weights[row][i] = random(-2, 2);
  }
  float[] decide(float[] walls, float velocity) {
    float[] output = new float[2];
    for (int row = 0; row < weights.length; row++) {
      float sum = weights[row][6] + weights[row][5] * velocity / 3.5f;
      for (int i = 0; i < walls.length; i++) sum += weights[row][i] * walls[i] / SENSOR_RANGE;
      output[row] = (float)Math.tanh(sum);
    }
    return output;
  }
  Brain copy() {
    Brain result = new Brain();
    for (int row = 0; row < weights.length; row++) arrayCopy(weights[row], result.weights[row]);
    return result;
  }
  void mutate() {
    for (int row = 0; row < weights.length; row++) {
      for (int i = 0; i < weights[row].length; i++) {
        if (random(1) < 0.2f) weights[row][i] = constrain(weights[row][i] + randomGaussian() * 0.35f, -8, 8);
        if (random(1) < 0.01f) weights[row][i] = random(-2, 2);
      }
    }
  }
}
