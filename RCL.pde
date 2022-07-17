class RendererConcavityLinework extends RendererConcavity 
{
  Dune dune;
  int number_sketch_lines = 3; 

  RendererConcavityLinework(Dune dune, MapPnt[][] map, RenderType render_type, int  w, int  h, int res)
  {
    super(map, render_type, w, h, res);
    this.dune = dune;
  }

  ArrayList<ArrayList<Point>> CreateDuneLines(Concavity type)
  {
    background(255);
    IntList checked = new IntList();
    ArrayList<ArrayList<Point>> dune_lines = new ArrayList<ArrayList<Point>>(); 
    ArrayList<Point> dune_line;
    Point p;
    for (int xy = 0; xy < (w-1)*(h-1); xy++)
    {
      if (checked.hasValue(xy))
        continue;
      checked.append(xy);
      p = new Point(xy);
      if (!IsPointInMap(p))
        continue;
      if (ContainsConcavity(p, type)) {
        dune_line = new ArrayList<Point>();
        dune_line.add(p);

        AddToDuneLine(p, dune_line, checked, type);
        dune_lines.add(dune_line);
      } else {
        checked.append(p.xy);
        continue;
      }
    } 
    return dune_lines;
  }

  void SearchDirection()
{
  
  PVector wind_orth = dune.wind.copy().rotate(HALF_PI);
  wind_orth.normalize();
  int x = round(wind_orth.x);
  int y = round(wind_orth.y);

}

  void DrawDuneLines(ArrayList<ArrayList<Point>> dune_lines, color c)
  {
    ArrayList<Point> dune_line;
    stroke(c);
    noFill();
    for (int i = 0; i <  dune_lines.size(); i++)
    {
      dune_line = dune_lines.get(i);
      switch(2) {
      case 1:
        DrawWithLine(dune_line);
        break;
      case 2:
        DrawWithCurve(dune_line);
        break;
      }
    }
  }

  void DrawWithLine(ArrayList<Point> dune_line)
  {
    Point p1, p2;
    //dune_line.get(0).DrawCircle(3);
    if (dune_line.size() > 1) {
      for (int j = 1; j < dune_line.size(); j++) {
        p1 = dune_line.get(j-1);
        p2 = dune_line.get(j);
        p1.DrawLine(p2);
      }
    }
  }
  
  void DrawWithCurve(ArrayList<Point> dune_line) {
    noFill();
    Point p;
    if (dune_line.size() > number_sketch_lines - 1) {
      for (int j = 0; j < number_sketch_lines; j++) {
        beginShape();
        for (int i = j; i < dune_line.size(); i+=number_sketch_lines) {
          p = dune_line.get(i);
          curveVertex(p.x_res, p.y_res);
        }
        endShape();
      }
    }
  }

  void AddToDuneLine(Point p, ArrayList<Point> dune_line, IntList checked, Concavity type)
  {
    Point pn;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        pn = p.Translate(i, j);
        if (checked.hasValue(pn.xy) || !IsPointInMap(pn))
          continue;
        checked.append(pn.xy);
        if (ContainsConcavity(pn, type)) {
          dune_line.add(pn);
          AddToDuneLine(pn, dune_line, checked, type);
          return;
        }
      }
    }
    return;
  }


  void ConnectTheDots(int x_move, int y_move, Concavity type, color c)
  {
    //int every_n_lines = 2;
    stroke(c);
    int x_n, y_n;
    for (int y = 0; y < h; y++) {
      // if (y%every_n_lines != 0)
      //   continue;
      for (int x = 0; x < w; x++) {
        //  if (x%every_n_lines != 0)
        //    continue;
        if (ContainsConcavity(x, y, type)) {
          x_n = x + x_move; 
          y_n = y + y_move;
          if (IsPointInMap(x_n, y_n) && ContainsConcavity(x_n, y_n, type)) {
            line(x*res, y*res, x_n*res, y_n*res);
          }
        }
      }
    }
  }
}



/* looks good with:
 * random wind but no variation,
 * l0_base = 16; q0 = 0.2; base_h = 10; base_h_mult = 5;
 * 600x600 at 3 resolution
 */

class RendererConcavityLinework1 extends  RendererConcavityLinework 
{
  RendererConcavityLinework1(Dune dune, MapPnt[][] map, int  w, int  h, int res)
  {
    super(dune, map, RenderType.CONCAVITY_LINEWORK, w, h, res);
  }

  void Render() {
    ArrayList<ArrayList<Point>> peak_lines = CreateDuneLines(Concavity.INCLINE);
    ArrayList<ArrayList<Point>> trough_lines = CreateDuneLines(Concavity.DECLINE);
    DrawDuneLines(peak_lines, INCLINE_COLOR);
    DrawDuneLines(trough_lines, DECLINE_COLOR);
  }
}

class RendererConcavityLinework2 extends  RendererConcavityLinework 
{
  RendererConcavityLinework2(Dune dune, MapPnt[][] map, int  w, int  h, int res)
  {
    super(dune, map, RenderType.CONCAVITY_LINEWORK, w, h, res);
  }

  void Render() {
    ArrayList<ArrayList<Point>> peak_lines = CreateDuneLines(Concavity.PEAK);
    ArrayList<ArrayList<Point>> trough_lines = CreateDuneLines(Concavity.TROUGH);
    DrawDuneLines(peak_lines, PEAK_COLOR);
    DrawDuneLines(trough_lines, TROUGH_COLOR);
  }
}

class RendererConcavityLinework3 extends  RendererConcavityLinework 
{
  PVector dir = new PVector(1, 1);
  int ch_x_1 = -1;
  int ch_y_1 = -1;
  
  int ch_x_2 = -1;
  int ch_y_2 = 1;
  
  RendererConcavityLinework3(Dune dune, MapPnt[][] map, int  w, int  h, int res)
  {
    super(dune, map, RenderType.CONCAVITY_LINEWORK, w, h, res);
    number_sketch_lines = 1;
  }
  
  
  
  void Render() {
    background(255);
    /*
    ArrayList<ArrayList<Point>> peak_lines = CreateDuneLines(Concavity.PEAK);
    ArrayList<ArrayList<Point>> trough_lines = CreateDuneLines(Concavity.TROUGH);
    DrawDuneLines(peak_lines, PEAK_COLOR);
    DrawDuneLines(trough_lines, TROUGH_COLOR);
    */
    Concavity conc = Concavity.INCLINE;
    ConnectTheDots(ch_x_1, ch_y_1, conc, GetConcavityColorByType(conc));
    conc = Concavity.DECLINE;
    ConnectTheDots(ch_x_2, ch_y_2, conc, GetConcavityColorByType(conc));
  }
}
