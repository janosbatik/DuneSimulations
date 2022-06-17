class Renderer3DLines extends Renderer
{
  final color LINE_COLOR = color(255);
  final boolean draw_every_line = false;
  final int draw_every_n_lines = 5;

  Renderer3DLines(MapPnt[][] map, RenderType render_type, int  w, int  h, int res) {
    super( map, render_type, w, h, res);
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
  RendererXLines(MapPnt[][] map, int  w, int  h, int res) {
    super( map, RenderType.X_LINES, w, h, res);
  }

  void Render() {
    noFill();
    stroke(LINE_COLOR);
    for (int x = 0; x < w; x++) {
      if ( !ShouldDrawLine(x))
        continue;
      beginShape();
      for (int y = 0; y < h; y++) {  
        curveVertex(x*res, y*res, hf(x, y)*height_multiplier);
      }
      endShape();
    }
  }
}

class RendererYLines extends  Renderer3DLines
{
  RendererYLines(MapPnt[][] map, int  w, int  h, int res) {
    super( map, RenderType.Y_LINES, w, h, res);
  }

  void Render() {
    noFill();
    stroke(LINE_COLOR);
    for (int y = 0; y < h; y++) {
      if ( !ShouldDrawLine(y))
        continue;
      beginShape();
      for (int x = 0; x < w; x++) {
        curveVertex(x*res, y*res, hf(x, y)*height_multiplier);
      }
      endShape();
    }
  }
}

class RendererGrid extends  Renderer3DLines
{
  Renderer xlines;
  Renderer ylines;

  RendererGrid(MapPnt[][] map, int  w, int  h, int res) {
    super( map, RenderType.GRID, w, h, res);
    this.xlines = new RendererXLines(map, w, h, res);
    this.ylines = new RendererYLines(map, w, h, res);
  }

  void Render() {
    xlines.Render();
    ylines.Render();
  }
}

class RendererTriangleStrip extends  Renderer
{
  final color LINE_COLOR = color(255);

  RendererTriangleStrip(MapPnt[][] map, RenderType render_type, int  w, int  h, int res) {
    super( map, render_type, w, h, res);
  }

  void SetStrokeAndFill()
  {
    switch (render_type) { 
    case TRIANGLE_STRIPS:
      stroke(LINE_COLOR);
      noFill();
      break;
    case TEXTURED:
      noStroke();
      break;
    case TEXTURED_WITH_LINES:
      stroke(0, 0, 0, 100); 
      break;
    }
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
