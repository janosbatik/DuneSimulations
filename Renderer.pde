class Renderer 
{
  RenderType render_type;
  Dune dune;
  MapPnt[][] map;
  int w, h, res;

  float height_multiplier = 1; // applies to 3D renderings only
  boolean CIRCLE = false;

  int render_section = 0;
  int number_render_sections = 1;

  Renderer(RenderType render_type)
  {
    this.render_type = render_type;
  }

  public void Init(Dune dune)
  {
    this.dune = dune;
    this.w = dune.w;
    this.h = dune.h;
    this.res = dune.resolution;
    this.map = dune.map;
    AdditionalSetup();
  }
  
void AdditionalSetup(){} 
  
  void Render() // to be overwritten
  {
  }

  public void RenderDune()
  {
    if (this.render_type.Is3D()) {
      Render3D();
    } else {
      Render2D();
    }
  }

  private void Render2D()
  {
    Render();
  }

  private void Render3D()
  {
    background(0);
    pushMatrix();
    //ambient(#DD8144); // sand orange lifted from desert photo
    fill(#DD8144);
    translate(-w*res/2, -w*res/2, 0);

    Render();
    popMatrix();
  }

  color DuneColoring(float n, int opac)
  {
    return color(floor(n), round(n/1.93), round(n/5.565), opac);
  }

  color DuneColoring(float n)
  {
    return DuneColoring(n, 255);
  }

  void ColorPixels(int x, int y, color c) {
    for (int i = 0; i < res; i ++) {
      for (int j = 0; j < res; j ++) {
        pixels[(y*res+i)*(w*res)+(x*res+j)] = c;
      }
    }
  }

  boolean IsPointInMap(int x, int y)
  {
    if  (x < 0 || y < 0)
      return false;
    if (x >= w || y >= h)
      return false;
    return true;
  }

  boolean IsPointInMap(Point p) {
    return IsPointInMap(p.x, p.y);
  }

  void NextRenderSection() {
    render_section = (render_section +1)%number_render_sections;
  }
}
