class RendererHeightMap extends Renderer
{
  float max_h, min_h, ave_h;
  
  RendererHeightMap(MapPnt[][] map, RenderType render_type, int  w, int  h, int res) {
    super( map, render_type, w, h, res);
     UpdateHeightStats();
  }
  
  void UpdateHeightStats()
  {
    float sum_h =  0;
    float hxy = 0;
    min_h = 999999;
    max_h  = 0;
    ave_h = 0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        hxy = hf(x, y);
        max_h = max(hxy, max_h);
        min_h = min(hxy, min_h);
        sum_h += hxy;
      }
    }
    ave_h = sum_h/(h*w);
  }
}

class RendererDiscreteHeightMap extends RendererHeightMap
{
  RendererDiscreteHeightMap(MapPnt[][] map, int  w, int  h, int res) {
    super( map, RenderType.HEIGHT_DISCRETE, w, h, res);
  }

  void Render() {
    UpdateHeightStats();
    int number_color_bands = 6;
    color[] colors = new color[number_color_bands];
    float step = floor(255.0/(number_color_bands-1));
    for (int i = 0; i < number_color_bands; i++) {
      colors[i]=DuneColoring(step*i);
    }
    float range = max_h - min_h;
    float interval = range/number_color_bands;

    color c;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {        
        c = colors[min(number_color_bands-1, floor((hf(x, y) - min_h)/interval))];
        ColorPixels(x, y, c);
      }
    }
    updatePixels();
  }
}

class RendererGradientHeightMap extends RendererHeightMap
{
  RendererGradientHeightMap(MapPnt[][] map, int  w, int  h, int res) {
    super( map, RenderType.HEIGHT_GRADIENT, w, h, res);
  }

  void Render() {
    UpdateHeightStats();
    color c;
    float c_map;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        c_map = map(hf(x, y), min_h, max_h, 0, 255);
        c = DuneColoring(c_map, 180); 
        ColorPixels(x, y, c);
      }
    }
    updatePixels();
  }
}
