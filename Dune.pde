// TODO

class Dune {
  // debug
  boolean ERRODE_ON_BUTTON_PRESS = true;
  boolean PRINT_DETAILS = false;
  int PRINT_EVERY_X_ITERATIONS = 10; // if PRINT_DETAILS is true, this will print out useful stats ever x interations of errode

  // visual settings
  boolean WRAP = true;     // sand loops back around the map
  int LINE_WORK_RENDERER = 1;

  // wind settings
  boolean VARIABLE_WIND = true;
  boolean RANDOM_STARTING_WIND = true;
  PVector wind = new PVector(1, 1); // wind vector. Its mag set later, direction is all this is important
  PVector wind_base;
  float wind_mag = 1.2;
  float max_wind_diviation_angle = 70;
  float wind_noise = 0;
  float wind_noise_incr = 0.1;

  Renderer renderer;
  RenderType render_type;
  RenderType default_3D_render_type = RenderType.TEXTURED; 
  RenderType default_2D_render_type = RenderType.CONCAVITY_LINEWORK; 


  int resolution; // how many pixels for one block on the map

  // blur
  float blur_fact = 0.4;
  // slip
  // float threshold_angle = 55;
  // float threshold_grad;n

  float base_h = 10;
  float base_h_mult = 5;

  float l0;            // average hop distance
  float l0_base = 16;  // l0 = l0_base/resolution (this creates more uniform spacing across different resolutions) (16 seems to be a happy number)
  float q0 = 0.2;      // average amount of sand moved [0.1, 1.0]


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

  Dune(boolean is_3D, int px_w, int px_h, int res) { 
    this.render_type= is_3D ? default_3D_render_type : default_2D_render_type;
    this.resolution = res;
    Init(px_w, px_h);
  }

  void Init(int px_w, int px_h)
  {
    this.w = px_w/resolution;
    this.h = px_h/resolution;
    this.map = new MapPnt[w][h];

    if (RANDOM_STARTING_WIND)
      wind = new PVector(random(2)-1, random(2)-1);   
    wind.setMag(wind_mag);
    this.wind_base = wind.copy();
    this.l0 = l0_base/resolution;
    GenerateRandomMap();
    SetRenderer();
    //threshold_grad = tan(radians(threshold_angle));

    PrintDetails();
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
    if (render_type.Is3D()) {
      renderer.Render3D();
    } else {
      renderer.Render2D();
    }
  }

  void PrevRenderType()
  {
    this.render_type = render_type.Prev();
    SetRenderer();
  }

  void NextRenderType()
  {
    this.render_type = render_type.Next();
    SetRenderer();
  }

  void SetRenderer()
  {
    switch(render_type) {
    case TRIANGLE_STRIPS: 
    case TEXTURED: 
    case TEXTURED_WITH_LINES:
      renderer = new RendererTriangleStrip(map, render_type, w, h, resolution);
      break;
    case X_LINES :
      renderer = new RendererXLines(map, w, h, resolution);
      break;
    case  Y_LINES:
      renderer = new RendererYLines(map, w, h, resolution);
      break;
    case GRID:
      renderer = new RendererGrid(map, w, h, resolution);
      break;
    case CONCAVITY_DISCRETE:
      renderer = new RendererDiscreteConcavityMap(map, w, h, resolution);
      break;
    case CONCAVITY_GRADIENT:
      renderer = new RendererGradientConcavityMap(map, w, h, resolution);
      break;
    case CONCAVITY_LINEWORK:
      switch(LINE_WORK_RENDERER)
      {
      case 1: 
        renderer = new RendererConcavityLinework1(this, map, w, h, resolution);  
        break;
      case 2:
        renderer = new RendererConcavityLinework2(this, map, w, h, resolution);
        break;
        case 3:
        renderer = new RendererConcavityLinework3(this, map, w, h, resolution);
        break;
      }

      break;
    case HEIGHT_GRADIENT:
      renderer = new RendererGradientHeightMap(map, w, h, resolution);
      break;
    case HEIGHT_DISCRETE:
      renderer = new RendererDiscreteHeightMap(map, w, h, resolution);
      break;
    default:
      throw new IllegalArgumentException ("unaccounted render type");
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
      //UpdateGradient();

      Blur();
      UpdateHeightStats();

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

  /*
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
   */

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

  void UpdateConcavity()
  {
    if (!render_type.BasedOnConcavity())
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

  void PrintDetails()
  {
    if (!PRINT_DETAILS)
      return;
    println("iteration ", errode_count);
    println("____________");
    println("frameRate: ", frameRate);
    println("wind: ", wind);
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
