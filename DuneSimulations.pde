import peasy.*;

Dune dune;
int dune_px_h = 400;
int dune_px_w = 400;
boolean is_3D = true;
SaveSketch save;
boolean PEASY = false;
boolean SAVE = true; 
PeasyCam cam;

int count;
float camZ = 280;
float camX = dune_px_w/2.0;
float camY = dune_px_h/2.0;


void setup() {
  background(255);
  size(600, 600, P3D);
  if (PEASY) {
    cam = new PeasyCam(this, 100);
    cam.setMinimumDistance(50);
    cam.setMaximumDistance(500);
  }
  save = new SaveSketch(SAVE);
  //noLoop();
  frameRate(20);
  dune = new Dune(dune_px_w, dune_px_h);
  loadPixels();
  dune.Errode(2);
}

void keyPressed() {
  if (key=='r') {
    camX = dune_px_w/2.0;
    camY = dune_px_h/2.0;
  }
}

void draw() {

  background(0);

  float xPos;
  if (false) {
    camZ =  mouseY+1;
    xPos = mouseX;
  } else {
    camZ = 280;
    xPos = 294;
  }
  
  camera(camX, camY, camZ, // eyeX, eyeY, eyeZ
    30, 30, 0.0, // centerX, centerY, centerZ
    1.0, 1.0, 0.0); // upX, upY, upZ
  float rot = map(xPos, 0, width, 0, 2*PI);
  rotateZ(rot);
  Sun();
  directionalLight(255, 255, 140, 0, -1, 0);
  ambientLight(100, 100, 100);
  directionalLight(255, 0, 0, 0, -1, 0);

  //DrawAxis();
  dune.Errode(1);
  dune.Render3D();
  save.SaveAsAnimation();
}

void DrawAxis()
{
  color red = color(255, 0, 0);
  color blue = color(0, 0, 255);
  color green =  color(0, 255, 0);

  // x-axis
  stroke(red);
  line(-100, 0, 0, 100, 0, 0);
  line(0, 1, 0, 100, 1, 0);
  // y-axis
  stroke(blue);
  line(0, -100, 0, 0, 100, 0);
  line(1, 0, 0, 1, 100, 0);
  // z-axis
  stroke(green);
  line(0, 0, -100, 0, 0, 100);
  line(1, 0, 0, 1, 0, 100);

  stroke(255);
  box(50);
}

void Sun()
{
  pushMatrix();
  noStroke();
  int dist = 50;
  rotateX(radians(60));
  rotateY(-radians(count++));
  translate(dune_px_h/2 + dist, 0, 0);
  pointLight(255, 255, 120, 0, 0, 0);
  //directionalLight(255, 255, 120, -1, 0, 0);
  //box(50);
  sphere(50);
  popMatrix();
}

void mouseWheel(MouseEvent event) {
  int move = event.getCount()*4;
  camX += move;
  camY += move;
}
