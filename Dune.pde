// TODO

class Dune {

  boolean PRINT_DETAILS = false;
  boolean PRINT_EVERY_ITERATION = false; // if false it and PRINT_DETAILS is true then it only prints every run of Errode()

  // settings
  boolean WRAP = true;
  boolean CIRCLE = false;
  RenderType RENDER_TYPE = RenderType.TEXTURED;
  color LINE_COLOR = color(255);
  boolean DRAW_WIND_SOCK = false;

  int resolution = 2; // how many pixels for one block on the map
  float height_multiplier = 1;
  boolean DEBUG = true;

  float threshold_angle = 55;
  float threshold_grad;

  float TEST_HIEGHTBASE = 10;


  // float minStartingSand = 0.1;

  PVector wind;   // wind vector. Its size corresponds to the wind intensity and its direction to the wind direction
  float wind_mag = 1.2;
  float l0 = 1.5;       // average hop distance
  float q0 = 0.5;  // average amount of sand moved [0.1, 1.0]


  MapPnt[][] map;
  int w, h;
  int errode_count = 0;
  int errode_limit = 1499;
  int last_csv_saved = -1;
  // statistics
  float max_h = 0;
  PVector max_grad = new PVector(0, 0);
  float max_l = 0;
  PVector ave_grad;
  float ave_h;
  float ave_l;
  float ave_q;




  Dune(int dune_px_width, int dune_px_height) {
    this.w = dune_px_width/resolution;
    this.h = dune_px_height/resolution;
    this.wind = new PVector(1, 1);
    wind.setMag(wind_mag);
    this.map = new MapPnt[w][h];
    GenerateRandomMap();
    PrintDetails();
    threshold_grad = tan(radians(threshold_angle));
    //PrintMap();
  }

  Dune(int pxW, int pxH, int errode_limit) {
    this(pxW, pxH);
    this.errode_limit = errode_limit;
  }

  void Debug()
  {
    if (keyPressed) {
      switch (key) {
      case 'n':
        Errode();
        break;
      case 's':
        if (last_csv_saved != errode_count) {
          SaveToCSV();
          last_csv_saved = errode_count;
        }
        break;
      }
    }
    directionalLight(255, 255, 120, -1, -1, -1);
    Render3D();
    errode_limit++;
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

  void Render3D() {
    pushMatrix();
    if (DRAW_WIND_SOCK) {
      DrawWindVec();
    }
    ambient(255, 122, 100);
    translate(-dune_px_w/2, -dune_px_h/2, 0);

    switch (RENDER_TYPE) { 
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
    if (RENDER_TYPE == RenderType.Y_LINES || RENDER_TYPE == RenderType.GRID) {
      for (int y = 0; y < h; y++) {
        beginShape();
        for (int x = 0; x < w; x++) {

          curveVertex(x*resolution, y*resolution, hf(x, y)*height_multiplier);
        }
        endShape();
      }
    }
    if (RENDER_TYPE == RenderType.Y_LINES || RENDER_TYPE == RenderType.GRID) {
      for (int x = 0; x < w; x++) {
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

    if (RENDER_TYPE == RenderType.TRIANGLE_STRIPS || RENDER_TYPE == RenderType.TEXTURED_WITH_LINES) {
      stroke(LINE_COLOR);
    } else {
      noStroke();
    }
    if (RENDER_TYPE == RenderType.TRIANGLE_STRIPS) {
      noFill();
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
    if (errode_count>errode_limit)
      return;
    float sum_h, sum_q, sum_l;
    for (int i = 0; i < iter; i++) {
      sum_h = sum_q = sum_l = 0;
      max_h  = 0;
      ave_h = 0;
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          PVector l  = HopDistance(x, y);
          float q = QuantityMoved(x, y);
          MoveQuantity(x, y, l, q);

          max_h = max(hf(x, y), max_h);
          max_l = max(l.mag(), max_l);
          sum_h += hf(x, y);
          sum_l += l.mag();
          sum_q += q;
        }
      }
      UpdateGradient();
      //Slip();
      //Creep();
      Blur();
      UpdateGradient();
      ave_h = sum_h/(h*w);
      ave_q = sum_q/(h*w);
      ave_l = sum_l/(h*w);
      errode_count++;
      if (PRINT_EVERY_ITERATION)
        PrintDetails();
    }
    if (!PRINT_EVERY_ITERATION)
      PrintDetails();
  }


  void PrintDetails()
  {
    if (!PRINT_DETAILS)
      return;
    println("iteration ", errode_count);
    println("max height: ", max_h);
    println("ave height:", ave_h);
    println("ave quant moved:", ave_q);
    println("ave hop len:", ave_l);
    println("max hop len:", max_l);

    println("ave grad:", ave_grad);
    println("max_grad:", max_grad);
    print("ave grad x (deg):", degrees(atan( max_grad.x)));
    println("   max_grad y (deg):", degrees(atan(max_grad.y)));
    println("total sand: ", TotalSand());
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

  float TotalSand() {
    float sand = 0;
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++)
        sand += hf(x, y);
    }
    return sand;
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
    float v1 = 0.4;
    float v2 = 0.075;
    float[][] kernel = 
      {{ v2, v2, v2 }, 
      { v2, v1, v2 }, 
      { v2, v2, v2 }};

    for (int y = 1; y < h-1; y++) {   // Skip top and bottom edges
      for (int x = 1; x < w-1; x++) {  // Skip left and right edges
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
  }

  PVector HopDistance(int x, int y) {
    PVector grad = Gradient(x, y);
    float h = hf(x, y);
    float lx = (l0 * wind.x * h)*(1 - tanh(grad.x));
    float ly = (l0 * wind.y * h)*(1 - tanh(grad.y));
    return new PVector(lx, ly);
  }



  PVector gf(int x, int y) {
    return map[x][y].grad;
  }

  float hf(int x, int y)
  {
    return map[x][y].h;
  }

  float QuantityMoved(int x, int y) {
    float q = q0*(1 - tanh(wind.dot(gf(x, y))));
    //float q = q0*(1 + tanh( gf(x, y).x + gf(x, y).y));
    return min(hf(x, y), q);
  }

  void MoveQuantity(int x, int y, PVector l, float q)
  {
    map[x][y].RemoveHeight(q);
    int xl = x + ceil(l.x); 
    int  yl = y + ceil(l.y);
    if (WRAP)
    {
      xl = xl % w;
      yl = yl % h;
    }
    if (xl>=0 && yl >=0 && xl<w && yl<h)
    {
      map[xl][yl].AddHeight(q);
    }
  }

  void DrawWindVec()
  {
    translate(0, 0, 200);
    sphere(5);
    PVector dir = wind.normalize().mult(100);
    stroke(255, 0, 0);
    line(0, 0, 0, dir.x, dir.y, 0);
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
        Maps m = Maps.TEST_HIGHT;
        switch (m)
        {
        case TEST_HIGHT:
          p = noise(x/scale, y/scale)+TEST_HIEGHTBASE;
          break;
        case FLAT:
          p = 1;
          break;
        case DEBUG1:
          p = pow(2, min(x > w/2 ? w-x: x +1, y > h/2 ? h-y: y +1));//+noise(x/scale, y/scale);
          break;
        default:
          p = noise(x/scale, y/scale);
        }
        map[x][y] = new MapPnt (p);
        max_h = max(p, max_h);
        sum_h += p;
      }
    }
    ave_h = sum_h/(h*w);
    UpdateGradient();
  }


  void UpdateGradient()
  {
    max_grad = new PVector(0, 0);
    PVector sum_grad = new PVector(0, 0);
    PVector g;
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        g = Gradient(x, y);
        sum_grad.add(g);
        map[x][y].SetGradient(g);
      }
    }
    ave_grad = sum_grad.mult(1.0/(w*h));
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
}
