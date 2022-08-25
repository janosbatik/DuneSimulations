Dune dune;
int dune_px_h = 600;
int dune_px_w = 600;

int seed;


boolean print_preview_active = false;

SaveSketch save;
boolean SAVE = false;
int MAX_FRAMES = 300;

int FRAME_RATE = 20;
int RESOLUTION = 3;

boolean is_3D = true;
RenderType RENDER_TYPE;
RenderType DEFAULT_3D_RENDER_TYPE = RenderType.TEXTURED;
RenderType DEFAULT_2D_RENDER_TYPE = RenderType.CONCAVITY_LINEWORK_STRING;

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
  Renderer renderer = GetDefaultRenderer();
  dune = new Dune(renderer, dune_px_w, dune_px_h, RESOLUTION);
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
    dune = new Dune( GetRenderer(RENDER_TYPE), dune_px_w, dune_px_h, RESOLUTION);
    dune.Errode(40);
    break;

  case 'q':
    PrevRenderType(); 
    break;
  case 'w':
    NextRenderType();
    break;
  case 's':
    if (!is_3D)
      save.SaveSVG();
    break;
  case 'g': // save g-code
    if (RENDER_TYPE.OutputsGCode())
      savePrintSet();
    break;
  case 'n':
    if (ERRODE_ON_BUTTON_PRESS_ONLY)
    {
      dune.Errode();
    }
    break;
  case 't':
    if ( !print_preview_active)
    {
      saveGcode("test");
      background(255); 
      print_preview_active = true;
      break;
    } else {
      print_preview_active = false;
    }
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

void PrevRenderType()
{
  RENDER_TYPE = RENDER_TYPE.Prev();
  println("prev renderer: ", RENDER_TYPE);
  SetRenderer();
}

void NextRenderType()
{
  RENDER_TYPE = RENDER_TYPE.Next();
  println("next renderer: ", RENDER_TYPE);
  SetRenderer();
}

Renderer GetDefaultRenderer()
{
  if (is_3D) {
    RENDER_TYPE = DEFAULT_3D_RENDER_TYPE;
  } else {
    RENDER_TYPE = DEFAULT_2D_RENDER_TYPE;
  }
  return GetRenderer(RENDER_TYPE);
}

void SetRenderer() {
  dune.renderer = GetRenderer(RENDER_TYPE);
  dune.renderer.Init(dune);
}

Renderer GetRenderer(RenderType render_type)
{
  Renderer renderer;
  switch(render_type) {
  case TRIANGLE_MESH:
    renderer = new RendererTriangleMesh();
    break;
  case TEXTURED:
    renderer = new RendererTextured();
    break;
  case TEXTURED_WITH_TRIANGLE_MESH:
    renderer = new RendererTexturedWithMeshLines();
    break;
  case X_LINES :
    renderer = new RendererXLines();
    break;
  case  Y_LINES:
    renderer = new RendererYLines();
    break;
  case GRID:
    renderer = new RendererGrid();
    break;
  case CONCAVITY_DISCRETE:
    renderer = new RendererDiscreteConcavityMap();
    break;
  case CONCAVITY_GRADIENT:
    renderer = new RendererGradientConcavityMap();
    break;
  case CONCAVITY_LINEWORK_STRAIGHT:
    renderer = new RendererConcavityLineworkStraight();
    break;
  case CONCAVITY_LINEWORK_STRING:
    renderer = new RendererConcavityLineworkString();
    break;
  case HEIGHT_GRADIENT:
    renderer = new RendererGradientHeightMap();
    break;
  case HEIGHT_DISCRETE:
    renderer = new RendererDiscreteHeightMap();
    break;
  default:
    throw new IllegalArgumentException ("unaccounted render type");
  }
  return renderer;
}
