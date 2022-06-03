Dune dune;
int dune_px_h = 400;
int dune_px_w = 400;
boolean is_3D = true;

SaveSketch save;
boolean SAVE = false; 
Lights lights;
int errodePerDraw = 1;

int count;
Camera cam;



void setup() {
  background(255);
  //smooth(2);
  size(600, 600, P3D);
  cam = new Camera(this);
  lights = new Lights();
  save = new SaveSketch(SAVE);
  //noLoop();
  frameRate(20);
  dune = new Dune(dune_px_w, dune_px_h);
  dune.Errode(1);
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
 // dune.Debug();
    
  cam.SetCamera();
  lights.Render();
  //DrawAxisBox();
  //dune.Debug();
   
  dune.Errode(errodePerDraw);
  dune.Render3D();
  
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
  cam.ScrollToZoom(event);
}
