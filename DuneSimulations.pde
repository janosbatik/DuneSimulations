Dune dune;
int dune_px_h = 400;
int dune_px_w = 400;
//RenderType RENDER_TYPE;// = RenderType.TEXTURED;
boolean is_3D = false;

SaveSketch save;
boolean SAVE = false;
int MAX_FRAMES = 2000;

int FRAME_RATE = 20;
int RESOLUTION = 2;

Lights lights;
Camera cam;
TextRenderer tx;




void setup() {
  // is_3D = true;RENDER_TYPE.Is3D();
  background(255);


  settings();
  if (is_3D) {
    cam = new Camera(this);
    lights = new Lights();
  }
  //dune = new Dune(RENDER_TYPE, dune_px_w, dune_px_h);
  dune = new Dune(is_3D, dune_px_w, dune_px_h);
  save = new SaveSketch(SAVE, MAX_FRAMES);
  loadPixels();
  frameRate(FRAME_RATE);
  dune.Errode(40);
}

public void settings() {
  if (is_3D) {
    size(600, 600, P3D);
  } else 
  {
    size(dune_px_h, dune_px_w, P2D);
  }
}

void keyPressed() {
  switch (key)
  {
  case 'c':
    cam.Reset();
    break;
  case 'r':
    dune = new Dune(is_3D, dune_px_w, dune_px_h);
    break;

  case 'q':
   // RENDER_TYPE = RENDER_TYPE.Prev();
    dune.PrevRenderType(); 
    break;
  case 'w':
   // RENDER_TYPE = RENDER_TYPE.Next();
    dune.NextRenderType();
    break;
  }
}

void draw() {
  background(0);

  if (is_3D) {
    cam.SetCamera();
    lights.Render();
  }
  dune.Render();
  save.SaveAsAnimation();
}

void mouseWheel(MouseEvent event) {
  if (is_3D) {
    cam.ScrollToZoom(event);
  }
}
