class map {
  PImage road;
  boolean[] drivable;
  map(PImage source) {
    road = source;
    road.loadPixels();
    drivable = new boolean[road.width * road.height];
    for (int i = 0; i < drivable.length; i++) {
      // The supplied PNG uses transparent grass. Its finish line is opaque
      // black/white, so alpha (not RGB) defines the drivable surface.
      drivable[i] = ((road.pixels[i] >>> 24) & 255) >= 128;
    }
  }
  boolean isRoad(float x, float y) {
    if (Float.isNaN(x) || Float.isNaN(y) || x < 0 || y < 0 || x >= road.width || y >= road.height) return false;
    return drivable[(int)y * road.width + (int)x];
  }
  void show() {
    noStroke(); fill(174, 204, 72); rect(0, 0, road.width, road.height);
    imageMode(CORNER); image(road, 0, 0);
  }
}
