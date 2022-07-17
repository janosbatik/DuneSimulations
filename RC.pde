class RendererConcavity extends Renderer
{
  color PEAK_COLOR = color(#231411);
  color INCLINE_COLOR = color(#DD8144);
  color DECLINE_COLOR = color(#66717E);    
  color TROUGH_COLOR = color(#D4D6B9);

  RendererConcavity(MapPnt[][] map, RenderType render_type, int  w, int  h, int res)
  {
    super(map, render_type, w, h, res);
  }

  boolean ContainsConcavity(int x, int y, Concavity type)
  {  
    return map[x][y].ContainsConcavity(type);
  }

  boolean ContainsConcavity(Point p, Concavity type)
  {  
    return ContainsConcavity(p.x, p.y, type);
  }

  color GetConcavityColorByType(Concavity type)
  {
    switch(type)
    {
    case DECLINE:
      return DECLINE_COLOR;
    case INCLINE:
      return INCLINE_COLOR;
    case TROUGH:
      return TROUGH_COLOR;
    case PEAK:
      return PEAK_COLOR;
    default:
      return color(0);
    }
  }
}

class RendererDiscreteConcavityMap extends RendererConcavity
{
  RendererDiscreteConcavityMap(MapPnt[][] map, int  w, int  h, int res) {
    super( map, RenderType.CONCAVITY_DISCRETE, w, h, res);
  }

  void Render() {
    Concavity type;
    color c;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        type = x%2 == 0 ?  map[x][y].vert_concavity : map[x][y].hor_concavity;
        c = GetConcavityColorByType(type);
        ColorPixels(x, y, c);
      }
    }
    updatePixels();
  }
}

class RendererGradientConcavityMap extends RendererConcavity
{
  int  gradient_concavity_map_stat_count = 0;
  float max_rate_change_y;
  float min_rate_change_y = 0;
  float max_rate_change_x = 0;
  float min_rate_change_x = 0;

  RendererGradientConcavityMap(MapPnt[][] map, int  w, int  h, int res) {
    super( map, RenderType.CONCAVITY_GRADIENT, w, h, res);
  }

  void Render() {
    if ( gradient_concavity_map_stat_count < 10) {
      gradient_concavity_map_stat_count++;
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          max_rate_change_y = max(map[x][y].rate_change_y, max_rate_change_y);
          max_rate_change_x = max(map[x][y].rate_change_x, max_rate_change_x);
          min_rate_change_y = min(map[x][y].rate_change_y, min_rate_change_y);
          min_rate_change_x = min(map[x][y].rate_change_x, min_rate_change_x);
        }
      }
    }

    noStroke();
    color c;
    float c_map;
    //background(#d36b26);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        float space = abs((max_rate_change_y-min_rate_change_y)/4.0);
        c_map = map(map[x][y].rate_change_y, min_rate_change_y+space, max_rate_change_y-space, 0, 255);
        //c = DuneColoring(c_map, 180);
        c = DuneColoring(c_map);
        ColorPixels(x, y, c);
      }
    }
    updatePixels();
  }
}
