class RendererConcavityLinework extends RendererConcavity 
{
  RendererConcavityLinework(MapPnt[][] map, int  w, int  h, int res)
  {
    super( map, RenderType.CONCAVITY_LINEWORK, w, h, res);
  }

  void Render() {
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
      if (!PointIsValid(p))
        continue;
      if (GetConvacity(p) == Concavity.PEAK) {
        dune_line = new ArrayList<Point>();
        dune_line.add(p);
        
        AddToDuneLine(p, dune_line, checked);
        dune_lines.add(dune_line);
      } else {
        checked.append(p.xy);
        continue;
      }
    }

    for (int i = 0; i <  dune_lines.size(); i++)
    {
        DrawDuneLine(dune_lines.get(i));
    }
  }

  Concavity GetConvacity(Point xy)
  {  
    if (map[xy.x][xy.y].ContainsConcavity(Concavity.PEAK))  
      return  Concavity.PEAK;
    if (map[xy.x][xy.y].ContainsConcavity(Concavity.TROUGH))  
      return  Concavity.TROUGH;
    return Concavity.FLAT;
  }

  void DrawDuneLine(ArrayList<Point> dune_line)
  {
    stroke(PEAK_COLOR);
    noFill();
    Point p1, p2;
    //dune_line.get(0).DrawCircle(3);
    if (dune_line.size() > 1) {
      for (int i = 1; i < dune_line.size(); i++) {
        p1 = dune_line.get(i-1);
        p2 = dune_line.get(i);
        p1.DrawLine(p2);
      }
    }
  }


  void AddToDuneLine(Point p, ArrayList<Point> dune_line, IntList checked)
  {
    Point pn;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        pn = p.Translate(i, j);
        if (checked.hasValue(pn.xy) || !PointIsValid(pn))
          continue;
        checked.append(pn.xy);
        if (GetConvacity(pn) == Concavity.PEAK) {
          dune_line.add(pn);
          AddToDuneLine(pn, dune_line, checked);
          return;
        }
      }
    }
    return;
  }

  boolean PointIsValid(Point p)
  {
    if (p.x < 0 || p.y < 0)
      return false;
    if (p.x >= w || p.y >= h)
      return false;
    return true;
  }
}
