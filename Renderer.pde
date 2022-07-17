class Renderer 
{
  RenderType render_type;
  MapPnt[][] map;
  int w, h, res;

  float height_multiplier = 1; // applies to 3D renderings only
  boolean CIRCLE = false;

  Renderer(MapPnt[][] map, RenderType render_type, int  w, int  h, int res)
  {
    this.render_type = render_type;
    this.w = w;
    this.h = h;
    this.res = res;
    this.map = map;
  }

  void Render()
  {
  }

  void Render2D()
  {
    Render();
  }

  void Render3D()
  {
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
  
  boolean IsPointInMap(Point p){
    return IsPointInMap(p.x, p.y);
  }
  
  float hf(int x, int y)
  {    
    x = x < 0 ? x + 1: x;
    x = x >= w ? x - 1: x;
    y = y < 0 ? y + 1: y;
    y = y >= h ? y - 1: y;  
    return map[x][y].h;
  }
}
