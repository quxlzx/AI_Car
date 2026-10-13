import processing.core.*;
import processing.awt.PGraphicsJava2D;
import javax.imageio.ImageIO;
import java.io.File;
public class RenderTest {
 public static void main(String[] args) throws Exception {
  AICar s = new AICar(); s.randomSeed(42);
  s.initialize(new PImage(ImageIO.read(new File(args[0] + "/RaceTrack5.png"))));
  s.cars = new PImage(ImageIO.read(new File(args[0] + "/CarPlayer.png")));
  s.bestG = new PImage(ImageIO.read(new File(args[0] + "/CarPlayer1.png")));
  s.ai = new PImage(ImageIO.read(new File(args[0] + "/CarPlayer2.png")));
  s.width=1200; s.height=780; s.paused=true; s.frameRate=60; s.focused=true;
  PGraphicsJava2D g=new PGraphicsJava2D(); g.setParent(s); g.setSize(1200,780); s.g=g;
  g.beginDraw(); s.draw(); g.endDraw(); g.save(args[1]);
  System.out.println("Rendered sketch frame");
 }
}
