Dune dune;
int dune_px_h = 600;
int dune_px_w = 600;

SaveSketch save;
boolean SAVE = false;
int MAX_FRAMES = 400;
Lights lights;
int errodePerDraw = 1;

boolean is_3D = false;

int count;
Camera cam;

boolean DEBUG = false;

void setup() {
  
  background(255);
  //smooth(2);
  settings();
  if (is_3D) {
        cam = new Camera(this);
    lights = new Lights();
  }
  dune = new Dune(dune_px_w, dune_px_h);
  save = new SaveSketch(SAVE, MAX_FRAMES);
  //noLoop();
  frameRate(20);
  
}

public void settings() {
  if (is_3D) {
    size(600, 600, P3D);
  } else {
    size(dune_px_w, dune_px_h);
  }
}

void keyPressed() {
  if (key=='c') {
    cam.Reset();
  }
  if (key=='r') {
    dune = new Dune(dune_px_w, dune_px_h);
  }
}

void draw() {
  background(0);

  if (is_3D) {
    cam.SetCamera();
    lights.Render();
  }

  if (DEBUG) {
    dune.Debug();
  } else {
    dune.Render();
  }
  save.SaveAsAnimation();
}


void DrawAxisBox()
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


void mouseWheel(MouseEvent event) {
  if (is_3D) {
    cam.ScrollToZoom(event);
  }
}
