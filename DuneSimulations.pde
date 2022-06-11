Dune dune;
int dune_px_h = 600;
int dune_px_w = 600;
RenderType RENDER_TYPE = RenderType.TEXTURED;

SaveSketch save;
boolean SAVE = false;
int MAX_FRAMES = 500;

int FRAME_RATE = 20;

Lights lights;
Camera cam;
TextRenderer tx;

boolean is_3D;

boolean DEBUG = false;

void setup() {
  is_3D = RENDER_TYPE.Is3D();
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
  loadPixels();
  tx = new TextRenderer(poem);
  frameRate(FRAME_RATE);
}

public void settings() {
  if (true) {
    size(600, 600, P3D);
  } else {
    size(dune_px_w, dune_px_h);
  }
}

void keyPressed() {
  switch (key)
  {
  case 'c':
    cam.Reset();
    break;
  case 'r':
    dune = new Dune(RENDER_TYPE, dune_px_w, dune_px_h);
    break;

  case 'q':
    RENDER_TYPE = RENDER_TYPE.Prev();
    dune.render_type =RENDER_TYPE; 
    break;
  case 'w':
    RENDER_TYPE = RENDER_TYPE.Next();
    dune.render_type =RENDER_TYPE;
    break;
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
  //tx.Render3D();
  save.SaveAsAnimation();
}

void mouseWheel(MouseEvent event) {
  if (is_3D) {
    cam.ScrollToZoom(event);
  }
}
