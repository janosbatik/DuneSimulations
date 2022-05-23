//based on this site https://www.youtube.com/watch?v=YiAtM4EpQ4U

Dune dune;
int count = 0;
SaveSketch save;

void setup() {
  //fullScreen(P3D);
  background(255);
  size(600, 600);
  save = new SaveSketch(false);
  //noLoop();
  frameRate(20);
  dune = new Dune();
  loadPixels();
}

void keyPressed() {
  if (key=='r') {
    dune = new Dune();
  }
}

void draw() {
  
  dune.Errode(2);
  dune.Render2D();
  save.SaveAsAnimation();
}
