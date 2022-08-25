class Renderer3DLines extends Renderer
{
  final color LINE_COLOR = color(255);
  final boolean draw_every_line = false;
  final int draw_every_n_lines = 5;

  Renderer3DLines(RenderType render_type) {
    super(render_type);
  }

  boolean ShouldDrawLine(int p)
  {
    if ( !draw_every_line) {
      if (p%draw_every_n_lines != 0) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }
}

class RendererXLines extends  Renderer3DLines
{
  RendererXLines() {
    super(RenderType.X_LINES);
  }

  void Render() {
    noFill();
    stroke(LINE_COLOR);
    for (int x = 0; x < w; x++) {
      if ( !ShouldDrawLine(x))
        continue;
      beginShape();
      for (int y = 0; y < h; y++) {  
        curveVertex(x*res, y*res, dune.hf(x, y)*height_multiplier);
      }
      endShape();
    }
  }
}

class RendererYLines extends  Renderer3DLines
{
  RendererYLines() {
    super(RenderType.Y_LINES);
  }

  void Render() {
    noFill();
    stroke(LINE_COLOR);
    for (int y = 0; y < h; y++) {
      if ( !ShouldDrawLine(y))
        continue;
      beginShape();
      for (int x = 0; x < w; x++) {
        curveVertex(x*res, y*res, dune.hf(x, y)*height_multiplier);
      }
      endShape();
    }
  }
}

class RendererGrid extends  Renderer3DLines
{
  Renderer xlines;
  Renderer ylines;

  RendererGrid() {
    super(RenderType.GRID);
    this.xlines = new RendererXLines();
    this.ylines = new RendererYLines();
  }
  
  void AdditionalSetup()
{
    this.xlines.Init(this.dune);
    this.ylines.Init(this.dune);
}
  
  void Render() {
    xlines.Render();
    ylines.Render();
  }
}

class RendererTextured extends RendererTriangleStrip {

  RendererTextured() {
    super(RenderType.TEXTURED);
  }

  void SetStrokeAndFill()
  {
    noStroke();
  }
}
class RendererTriangleMesh extends RendererTriangleStrip {

  RendererTriangleMesh() {
    super(RenderType.TRIANGLE_MESH);
  }

  void SetStrokeAndFill()
  {
    stroke(LINE_COLOR);
    noFill();
  }
}
class RendererTexturedWithMeshLines extends RendererTriangleStrip {

  RendererTexturedWithMeshLines() {
    super(RenderType.TEXTURED_WITH_TRIANGLE_MESH);
  }

  void SetStrokeAndFill()
  {
    stroke(0, 0, 0, 100);
  }
}

class RendererTriangleStrip extends  Renderer
{
  final color LINE_COLOR = color(255);

  RendererTriangleStrip(RenderType render_type) {
    super(render_type);
  }

  void SetStrokeAndFill() {
  }

  void Render() {
    SetStrokeAndFill();
    for (int j = 0; j < h; j++) {
      beginShape(TRIANGLE_STRIP);
      for (int i = 0; i < w; i++) {
        if (CIRCLE) {
          int radius = min(h, w)/2;
          if ( pow(i-w/2.0, 2) + pow(j-h/2, 2) > pow(radius, 2)) {
            continue;
          }
        }
        vertex(i*res, j*res, map[i][j].h*height_multiplier);
        if (j < h-1) {
          vertex(i*res, j*res+res, map[i][j+1].h*height_multiplier);
        }
      }
      endShape();
    }
  }
}
