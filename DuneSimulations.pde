Dune dune;
int dune_px_h = 600;
int dune_px_w = 600;

int seed;

boolean is_3D = false;
boolean print_preview_active = false;

SaveSketch save;
boolean SAVE = false;
int MAX_FRAMES = 300;

int FRAME_RATE = 20;
int RESOLUTION = 20;

boolean ERRODE_ON_BUTTON_PRESS_ONLY = true;

Lights lights;
Camera cam;
TextRenderer tx;

void setup() {
  background(255);  
  settings();
  if (is_3D) {
    cam = new Camera(this);
    lights = new Lights();
  }
  //dune = new Dune(RENDER_TYPE, dune_px_w, dune_px_h);


  seed = ceil(random(2147483647)); 
  randomSeed(seed);
  noiseSeed(seed);

  dune = new Dune(is_3D, dune_px_w, dune_px_h, RESOLUTION);
  save = new SaveSketch(SAVE, MAX_FRAMES, seed);
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
    //size(dune_px_h, dune_px_w, P2D);
  }
}

void keyPressed() {
  switch (key)
  {
  case 'c':
    cam.Reset();
    break;
  case 'r':
    dune = new Dune(is_3D, dune_px_w, dune_px_h, RESOLUTION);
    dune.Errode(40);
    break;

  case 'q':
    // RENDER_TYPE = RENDER_TYPE.Prev();
    dune.PrevRenderType(); 
    break;
  case 'w':
    // RENDER_TYPE = RENDER_TYPE.Next();
    dune.NextRenderType();
    break;
  case 's':
    if (!is_3D)
      save.SaveSVG();
    break;
  case 'g': // save g-code
    if (dune.render_type.OutputsGCode())
      savePrintSet();
    break;
  case 'n':
    if (ERRODE_ON_BUTTON_PRESS_ONLY)
    {
      dune.Errode();
    }
    break;
  case 't':
    saveGcode("test");
    background(255); 
    print_preview_active = true;
    break;
  }
}



void Render() {
  background(255, 255);

  if (is_3D) {
    cam.SetCamera();
    lights.Render();
  }
  save.SaveSVGStart();
  if (!ERRODE_ON_BUTTON_PRESS_ONLY)
    dune.Errode();
  dune.Render();
  save.SaveSVGEnd();

  save.SaveAsAnimation();
}

void draw() {
  if (print_preview_active) {
    boolean done = PrintPreview();
    if (done)
      print_preview_active = false;
  } else {
    Render();
  }
}

void mouseWheel(MouseEvent event) {
  if (is_3D) {
    cam.ScrollToZoom(event);
  }
}
