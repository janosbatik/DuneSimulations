// TODO

class Dune {
  // debug
  boolean ERRODE_ON_BUTTON_PRESS = false;
  boolean PRINT_DETAILS = false;
  int PRINT_EVERY_X_ITERATIONS = 10; // if PRINT_DETAILS is true, this will print out useful stats ever x interations of errode

  // visual settings
  boolean WRAP = true;     // sand loops back around the map
  boolean CIRCLE = false;
  color LINE_COLOR = color(255);
  boolean DRAW_WIND_SOCK = false;

  // algo settings
  boolean CALC_CONCAVITY = true;
  boolean VARIABLE_WIND = true;
  float max_wind_diviation_angle = 90;
  float wind_noise = 0;
  float wind_noise_incr = 0.1;
  RenderType render_type = RenderType.TEXTURED; 


  int resolution = 2; // how many pixels for one block on the map
  float height_multiplier = 1;

  // blur
  float blur_fact = 0.4;
  // slip
  float threshold_angle = 55;
  float threshold_grad;

  float base_h = 10;
  float base_h_mult = 1;

  PVector wind = new PVector(1, 1);   // wind vector. Its size corresponds to the wind intensity and its direction to the wind direction
  PVector wind_base;
  float wind_mag = 1.2;
  float l0 = 8;       // average hop distance
  float q0 = 0.12;  // average amount of sand moved [0.1, 1.0]


  MapPnt[][] map;
  int w, h;
  int errode_count = 0;
  int errode_limit = 1499;
  int last_csv_saved = -1;

  // statistics
  float max_h = 0;
  float min_h = 0;
  PVector max_grad = new PVector(0, 0);
  float max_l = 0;
  float max_q = 0;
  float ave_h;
  float ave_l;
  float ave_q;


  Dune(int px_w, int px_h) { 
    this.w = px_w/resolution;
    this.h = px_h/resolution;
    this.wind_base = wind.copy();
    wind.setMag(wind_mag);
    this.map = new MapPnt[w][h];
    GenerateRandomMap();
    Is3D();
    threshold_grad = tan(radians(threshold_angle));

    PrintDetails();
  }

  Dune(RenderType render_type, int px_w, int px_h) {
    this(px_w, px_h);
    this.render_type= render_type;
  }

  void Debug()
  {
    if (keyPressed) {
      switch (key) {
      case 's':
        if (last_csv_saved != errode_count) {
          SaveToCSV();
          last_csv_saved = errode_count;
        }
        break;
      }
    }    
    Render();
    errode_limit++;
  } 

  void Render()
  {
    if (ERRODE_ON_BUTTON_PRESS)
    {
      if (keyPressed) {
        switch (key) {
        case 'n':
          Errode();
          break;
        }
      }
    } else {
      dune.Errode();
    }
    switch(render_type) {
    case TRIANGLE_STRIPS: 
    case TEXTURED: 
    case TEXTURED_WITH_LINES:
    case X_LINES : 
    case  Y_LINES:
    case GRID:
      Render3D();
      break;
    case CONCAVITY:
      Render2D();
      break;
    default:
      throw new IllegalArgumentException ("unaccounted render type");
    }
  }

  void Render2D()
  {
    switch (render_type) { 
    case CONCAVITY:
      RenderByConcavity();
      break;
    }
  }

  void Render3D() {
    pushMatrix();
    if (DRAW_WIND_SOCK) {
      DrawWindVec();
    }
    //ambient(#DD8144); // sand orange lifted from desert photo
    fill(#DD8144);
    translate(-w*resolution/2, -w*resolution/2, 0);

    switch (render_type) { 
    case TRIANGLE_STRIPS: 
    case TEXTURED: 
    case TEXTURED_WITH_LINES:
      RenderAsTriangleStrip(); 
      break;
    case X_LINES : 
    case  Y_LINES:
    case GRID:
      RenderAsCurves();
      break;
    }
    popMatrix();
  }

  void RenderAsCurves()
  {

    noFill();
    stroke(LINE_COLOR);
    if (render_type == RenderType.Y_LINES || render_type == RenderType.GRID) {
      for (int y = 0; y < h; y++) {

        beginShape();
        for (int x = 0; x < w; x++) {
          curveVertex(x*resolution, y*resolution, hf(x, y)*height_multiplier);
        }
        endShape();
      }
    }
    if (render_type == RenderType.X_LINES || render_type == RenderType.GRID) {

      for (int x = 0; x < w; x++) {
        if (x%5 != 0)
          continue;
        beginShape();
        for (int y = 0; y < h; y++) {  
          curveVertex(x*resolution, y*resolution, hf(x, y)*height_multiplier);
        }
        endShape();
      }
    }
  }

  void  RenderAsTriangleStrip()
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
    for (int j = 0; j < h; j++) {
      beginShape(TRIANGLE_STRIP);
      for (int i = 0; i < w; i++) {
        if (CIRCLE) {
          int radius = min(h, w)/2;
          if ( pow(i-w/2.0, 2) + pow(j-h/2, 2) > pow(radius, 2)) {
            continue;
          }
        }
        vertex(i*resolution, j*resolution, map[i][j].h*height_multiplier);
        if (j < h-1) {
          vertex(i*resolution, j*resolution+resolution, map[i][j+1].h*height_multiplier);
        }
      }
      endShape();
    }
  }

  void Errode()
  {
    Errode(1);
  }

  void Errode(int iter)
  {
    if (VARIABLE_WIND) {
      RotateWind();
    }
    if (errode_count>errode_limit)
      return;
    float sum_q, sum_l;
    max_l = max_q = 0;
    for (int i = 0; i < iter; i++) {
      sum_q = sum_l = 0;

      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {

          PVector l  = HopDistance(x, y);
          float q = QuantityMoved(x, y);
          MoveQuantity(x, y, l, q);

          max_l = max(l.mag(), max_l);
          max_q = max(q, max_q);
          sum_l += l.mag();
          sum_q += q;
        }
      }
      UpdateHeightStats();
      UpdateGradient();
      //Slip();
      //Creep();
      Blur();
      UpdateHeightStats();
      //ave_h = sum_h/(h*w);
      ave_q = sum_q/(h*w);
      ave_l = sum_l/(h*w);
      errode_count++;
      if (errode_count%PRINT_EVERY_X_ITERATIONS == 0)
        PrintDetails();
    }
  }


  void RotateWind() {
    float rot = radians( max_wind_diviation_angle * map(noise(wind_noise), 0, 1, -1, 1));
    wind = wind_base.copy();
    wind.rotate(rot);
    wind_noise += wind_noise_incr;
  }

  void Creep() {
    PVector l, grad;
    float q;
    float mx = 0;
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        grad = gf(x, y);
        l = sign(grad);  
        q = 0.2*q0*tanh(grad.mag());
        mx = max(q, mx);
        MoveQuantity(x, y, l, q);
      }
    }
  }

  void Slip() {
    PVector l, grad;
    float q, mx;
    int s;
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        grad = gf(x, y);
        mx = max(abs(grad.x), abs(grad.y));
        if (mx > threshold_grad) {
          if (abs(grad.x) > abs(grad.y)) {
            s = sign(grad.x);
            q = abs(hf(x+1, y) - hf(x, y)) - threshold_grad; 
            l = new PVector (-s, 0);
            MoveQuantity(x+(1+s)/2, y, l, q*0.5);
            MoveQuantity(x+(1+s)/2, y, l.mult(2), q*0.3);
            MoveQuantity(x+(1+s)/2, y, l.add(0, 1), q*0.2);
            MoveQuantity(x+(1+s)/2, y, l.add(0, -2), q*0.2);
          } else {
            s = sign(grad.y);
            q = abs(hf(x, y+1) - hf(x, y)) - threshold_grad; 
            l = new PVector (0, -s);
            MoveQuantity(x, y+(1+s)/2, l, q*0.5);
            MoveQuantity(x, y+(1+s)/2, l.mult(2), q*0.3);
            MoveQuantity(x, y+(1+s)/2, l.add(1, 0), q*0.2);
            MoveQuantity(x, y+(1+s)/2, l.add(-2, 0), q*0.2);
          }
        }
      }
    }
  }

  void Blur()
  {
    float[][] new_map = new float[w][h];
    float v2 = (1-blur_fact)/8.0;
    float[][] kernel = 
      {{ v2, v2, v2 }, 
      { v2, blur_fact, v2 }, 
      { v2, v2, v2 }};

    for (int y = 0; y < h; y++) {   // Skip top and bottom edges
      for (int x = 0; x < w; x++) {  // Skip left and right edges
        float sum = 0; // Kernel sum for this pixel
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            sum += kernel[kx + 1][ky + 1] * hf(x+kx, y+ky);
          }
        }
        new_map[x][y] = sum;
      }
    }
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        map[x][y].h = new_map[x][y];
      }
    }
    UpdateGradient();
  }

  PVector HopDistance(int x, int y) {
    PVector grad = Gradient(x, y);
    float rel_hieght = map(hf(x, y), min_h, max_h, 0, 2); 
    float lx = (l0 * wind.x * rel_hieght)*(1 - tanh(grad.x));
    float ly = (l0 * wind.y * rel_hieght)*(1 - tanh(grad.y));
    return new PVector(lx, ly);
  }

  float QuantityMoved(int x, int y) {
    float q = q0*(1 - tanh(wind.dot(gf(x, y))));
    //float q = q0*(1 + tanh( gf(x, y).x + gf(x, y).y));
    return min(hf(x, y), q);
  }

  float MoveQuantity(int x, int y, PVector l, float q)
  {
    float hi = map[x][y].RemoveHeight(q);
    int xl = x + ceil(l.x); 
    int  yl = y + ceil(l.y);
    if (WRAP)
    {
      xl = xl % w;
      yl = yl % h;
      xl = xl < 0 ? xl + w: xl;
      yl = yl < 0 ? yl + h: yl;
    }
    if (xl>=0 && yl >=0 && xl<w && yl<h)
    {
      map[xl][yl].AddHeight(q);
    }
    return hi;
  }

  PVector Gradient(int x, int y) {

    /*
    float dx; 
     if (x == 0)
     dx = hf(x, y) - hf(x+1, y);
     else if (x == w -1)
     dx = hf(x-1, y) - hf(x, y);
     else {
     float dx_left = hf(x-1, y) - hf(x, y);  
     float dx_right = hf(x, y) - hf(x+1, y);
     dx = (dx_left + dx_right)/2;
     }
     float dy; 
     if (y == 0)
     dy = hf(x, y) - hf(x, y+1);
     else if (y == h - 1)
     dy = hf(x, y-1) - hf(x, y);
     else {
     float y1 = hf(x, y - 1) - hf(x, y);  
     float y2 = hf(x, y) - hf(x, y+1);
     dy = (y1 + y2)/2;
     }
     */

    // simpler gradient calc:
    float dx = x == w - 1 ? 0 : hf(x+1, y) - hf(x, y);
    float dy = y == h - 1 ? 0 : hf(x, y+1) - hf(x, y);


    max_grad.x = max( abs(max_grad.x), dx);
    max_grad.y = max( abs(max_grad.y), dy);
    return new PVector(dx, dy);
  }

  void UpdateGradient()
  {
    max_grad = new PVector(0, 0);
    PVector g;
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        g = Gradient(x, y);
        map[x][y].SetGradient(g);
      }
    }
    UpdateConcavity();
  }
  void UpdateConcavity()
  {
    if (!CALC_CONCAVITY)
      return;
    PVector g, g_xp, g_yp;
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        g = gf(x, y);
        if (x < w-1) {
          g_xp = gf(x + 1, y);
          map[x][y].hor_concavity = CalcConcavity(g.x, g_xp.x);
          map[x][y].rate_change_x = g_xp.x - g.x;
        } else {
          map[x][y].hor_concavity = g.x > 0 ? Concavity.INCLINE : Concavity.DECLINE;
          map[x][y].rate_change_x = 0;
        }

        if (y < h-1) {
          g_yp = gf(x, y + 1);
          map[x][y].vert_concavity = CalcConcavity(g.y, g_yp.y);
          map[x][y].rate_change_y = g_yp.y - g.y;
        } else {
          map[x][y].vert_concavity = g.y > 0 ? Concavity.INCLINE : Concavity.DECLINE;
          map[x][y].rate_change_y = 0;
        }
      }
    }
  }

  void RenderByConcavity()
  {
    RenderDescreteConcavityMap();
    //RenderGradientConcavityMap();
  }

  void RenderGradientConcavityMap()
  { 
    background(#DD8144);
    float max_rate_change_y = 0;
    float min_rate_change_y = 0;
    float max_rate_change_x = 0;
    float min_rate_change_x = 0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        max_rate_change_y = max(map[x][y].rate_change_y, max_rate_change_y);
        max_rate_change_x = max(map[x][y].rate_change_x, max_rate_change_x);
        min_rate_change_y = min(map[x][y].rate_change_y, min_rate_change_y);
        min_rate_change_x = min(map[x][y].rate_change_x, min_rate_change_x);
      }
    }
    noStroke();
    color c;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        c = color(map(map[x][y].rate_change_y, min_rate_change_y, max_rate_change_y, 0, 255), 50); 
        fill(c);
        DrawConcavity(x, y);
      }
    }
  }

  void RenderDescreteConcavityMap()
  {
    noStroke();
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        DrawConcavityType(x, y, Concavity.DECLINE, color(#7D3C21, 100));
        DrawConcavityType(x, y, Concavity.INCLINE, color(#DD8144, 100));
        DrawConcavityType(x, y, Concavity.TROUGH, color( #231411));
        DrawConcavityType(x, y, Concavity.PEAK, color(#8F4928));
      }
    }
  }

  void DrawConcavityType(int x, int y, Concavity type, color c)
  {
    fill(c);
    switch (2) {
    case 1:  
      if (map[x][y].vert_concavity == type && map[x][y].hor_concavity == type) {
        DrawConcavity(x, y);
      }
      break;
    case 2:
      if (map[x][y].vert_concavity == type || map[x][y].hor_concavity == type) {
        DrawConcavity(x, y);
      }
      break;
    case 3:
      if (map[x][y].vert_concavity == type) {
        DrawConcavity(x, y);
      }
      break;
    case 4:
      if (map[x][y].hor_concavity == type) {
        DrawConcavity(x, y);
      }
      break;
    }
  }

  void DrawConcavity(int x, int y, float offset)
  {
    circle((x*resolution)+resolution/2 + offset, y*resolution+resolution/2 + offset, 2*resolution);
  }

  void DrawConcavity(int x, int y)
  {
    circle((x*resolution)+resolution/2, y*resolution+resolution/2, 2*resolution);
  }


  /*
  void DrawConcavity(IntList checked, Point xy)
   {
   if (RENDER_TYPE == RenderType.Y_LINES || RENDER_TYPE == RenderType.GRID) {
   for (int y = 0; y < h; y++) {
   if (map[xy.x][xy.y].convacity == Concavity.PEAK) {
   println("");
   }
   }
   }
   }
   */

  Concavity CalcConcavity(float grad, float grad_p)
  {  
    if (grad > 0 && grad_p > 0)
      return Concavity.INCLINE;
    if (grad < 0 && grad_p < 0)
      return Concavity.DECLINE;
    if (grad < 0 && grad_p > 0)
      return Concavity.TROUGH;
    if (grad > 0 && grad_p < 0)
      return Concavity.PEAK;
    return Concavity.FLAT;
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

  float TotalSand() {
    float sand = 0;
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++)
        sand += hf(x, y);
    }
    return sand;
  }

  void GenerateRandomMap()
  {
    float scale = 50; // noise scale
    float p;
    float sum_h = 0;
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        /*
        if (CIRCLE) {
         int radius = min(h, w)/2;
         if ( pow(x-w/2.0, 2) + pow(y-h/2.0, 2) > pow(radius, 2)) {
         map[x][y] = new MapPnt (0);
         }
         }*/
        p = noise(x/scale, y/scale);
        p = noise(x/scale, y/scale)*base_h_mult + base_h;
        map[x][y] = new MapPnt (p);
        max_h = max(p, max_h);
        min_h = min(p, max_h);
        sum_h += p;
      }
    }
    ave_h = sum_h/(h*w);
    UpdateGradient();
  }
  void SaveToCSV()
  {
    String dir = "data/";
    PrintWriter hfile = createWriter(dir+"h"+errode_count+".csv"); 
    ; 
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        hfile.print(hf(x, y));
        hfile.print(" | ");
        hfile.print(gf(x, y));
        if (x != w-1)
          hfile.print(",");
      }
      hfile.print("\r\n");
    }
    hfile.flush(); // Writes the remaining data to the file
    hfile.close(); // Finishes the file
  }
  void DrawWindVec()
  {
    pushMatrix();
    translate(-(w*resolution/2+30), -(w*resolution/2+30), 200);
    sphere(5);
    PVector dir = wind.copy();
    dir.normalize().mult(30);
    stroke(255, 0, 0);
    line(0, 0, 0, dir.x, dir.y, 0);
    popMatrix();
  }

  void PrintDetails()
  {
    if (!PRINT_DETAILS)
      return;
    println("iteration ", errode_count);
    println("____________");
    print("max height: ", max_h);
    println(";\tmin height: ", min_h);
    println("ave height:", ave_h);
    print("max q moved:", max_q);
    println(";\tave q moved:", ave_q);
    println("ave hop len:", ave_l);
    println("max hop len:", max_l);

    print("max_grad:", max_grad);
    println("    (deg):", degrees(atan(max_grad.y)));
    println("total sand: ", TotalSand());
    println("");
  }

  int sign(float n)
  {
    if (n !=0)
      return int(n/abs(n));
    return int(n);
  }

  PVector sign(PVector p) {
    return new PVector(sign(p.x), sign(p.y));
  }

  float rd(float n, int decimals)
  {
    float fact = pow(10, decimals);
    return round(n*fact)/fact;
  }

  float rd(float n) {
    return rd(n, 3);
  }

  float tanh(float a)
  {
    return (float)Math.tanh(a);
  }

  PVector tanh(PVector a)
  {
    return new PVector(tanh(a.x), tanh(a.y));
  }

  PVector gf(int x, int y) {
    return map[x][y].grad;
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

class Point
{
  int x;
  int y;
  int xy;
  int w = 400/20;
  int h = 400/20;

  Point(int x, int y)
  {
    this.x = x;
    this.y = y;
    this.xy = y*w+x;
  }

  Point(int xy)
  {
    this.x = xy%w;
    this.y = xy/h;
    this.xy = xy;
  }
}
