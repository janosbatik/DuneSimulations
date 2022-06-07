Dune dune;
int dune_px_h = 600;
int dune_px_w = 600;
RenderType RENDER_TYPE = RenderType.CONCAVITY;

SaveSketch save;
boolean SAVE = false;
int MAX_FRAMES = 400;

Lights lights;
Camera cam;
TextRenderer tx;

boolean is_3D;

boolean DEBUG = false;

void setup() {
  is_3D = Is3D();
  background(255);
  //smooth(2);
  settings();
  if (is_3D) {
    cam = new Camera(this);
    lights = new Lights();
  }
  dune = new Dune(RENDER_TYPE, dune_px_w, dune_px_h);
  save = new SaveSketch(SAVE, MAX_FRAMES);
  //noLoop();
  tx = new TextRenderer("this is a test\na multi line test");
  frameRate(20);
}

public void settings() {
  if (Is3D()) {
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
    dune = new Dune(RENDER_TYPE, dune_px_w, dune_px_h);
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
  tx.Render();
  save.SaveAsAnimation();
}

void mouseWheel(MouseEvent event) {
  if (is_3D) {
    cam.ScrollToZoom(event);
  }
}

boolean Is3D()
{
  switch(RENDER_TYPE) {
  case TRIANGLE_STRIPS: 
  case TEXTURED: 
  case TEXTURED_WITH_LINES:

  case X_LINES : 
  case  Y_LINES:
  case GRID:
    return true;
  case CONCAVITY:
    return false;
  default:
    throw new IllegalArgumentException ("unaccounted render type");
  }
}
