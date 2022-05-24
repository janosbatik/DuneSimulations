// TODO

class Dune {

  boolean PRINT_DETAILS = false;
  boolean PRINT_EVERY_ITERATION = false; // if false it and PRINT_DETAILS is true then it only prints every run of Errode()
  boolean CIRCLE = true;

  MapPnt[][] map;
  int w, h;
  int resolution = 1; // how many pixels for one block on the map

  // float minStartingSand = 0.1;

  PVector wind;   // wind vector. Its size corresponds to the wind intensity and its direction to the wind direction
  float wind_mag = 0.8;
  float l0 = 1.05;       // average hop distance
  float q0 = 0.12;  // average amount of sand moved [0.1, 1.0]

  float max_h = 0;
  PVector max_grad = new PVector(0, 0);
  float max_l = 0;
  PVector ave_grad;
  float ave_h;
  float ave_l;
  float ave_q;
  int errode_count = 0;
  int errode_limit = 240;

  Dune(int dune_px_width, int dune_px_height) {
    this.w = dune_px_width/resolution;
    this.h = dune_px_height/resolution;
    this.wind = new PVector(1, 1);
    wind.setMag(wind_mag);
    this.map = new MapPnt[w][h];
    GenerateRandomMap();

    PrintDetails();
    //PrintMap();
  }

  Dune(int pxW, int pxH, int errode_limit) {
    this(pxW, pxH);
    this.errode_limit = errode_limit;
  }

  color TranslateToGreyScale(float p)
  {
    // return color(ceil(map(p, 0, max_h, 0, 255)));
    return color(ceil(map(min(p, 1), 0, 1, 0, 255)));
  }

  void Render2D()
  {
    loadPixels();
    color c;
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        c = TranslateToGreyScale(hf(x, y));
        SetPixel(x, y, c);
      }
    }
    updatePixels();
  }

  void Render3D() {
    pushMatrix();
    ambient(255, 122, 100);
    translate(-dune_px_w/2, -dune_px_h/2, 0);
    noStroke(); 
    float hMult=2;
    for (int j = 0; j < h; j++) {
      beginShape(TRIANGLE_STRIP);
      for (int i = 0; i < w; i++) {
        if (CIRCLE) {
          int radius = min(h, w)/2;
          if ( pow(i-w/2.0, 2) + pow(j-h/2, 2) > pow(radius, 2)) {
            continue;
          }
        }
        vertex(i*resolution, j*resolution, map[i][j].h*hMult);
        if (j < h-1) {
          vertex(i*resolution, j*resolution+resolution, map[i][j+1].h*hMult);
        }
      }
      endShape();
    }
    popMatrix();
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
      Creep();
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
  }

  void Creep() {
    PVector l, grad;
    float q;
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        grad = gf(x, y);
        l = sign(grad);  
        q = 0.2*q0*tanh(grad.mag());
        MoveQuantity(x, y, l, q);
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
    return map[x][y].h;
  }

  float QuantityMoved(int x, int y) {
    float q = q0*(1 - tanh(wind.dot(gf(x, y))));
    return min(hf(x, y), q);
  }

  void MoveQuantity(int x, int y, PVector l, float q)
  {
    map[x][y].RemoveHeight(q);
    int xl = x + ceil(l.x); 
    int  yl = y + ceil(l.y);
    if (xl>=0 && yl >=0 && xl<w && yl<h)
    {
      map[xl][yl].AddHeight(q);
    }
  }

  PVector Gradient(int x, int y) {

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
    max_grad.x = max( max_grad.x, dx);
    max_grad.y = max( max_grad.y, dy);
    return new PVector(dx, dy);
    /* 
     // simpler gradient calc:
     float x = hf(x+1][y] - hf(x-1][y];
     float y = hf(x][y+1] - hf(x][y-1];
     return new PVector(x, y);
     */
  }

  void GenerateRandomMap()
  {
    float scale = 50; // noise scale
    float p;
    float sum_h = 0;
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        p = noise(x/scale, y/scale);
        switch (30)
        {
        case 1:
          p = noise(x, y)*100;
          break;
        case 2:
          p = 1;
          break;
        case 3:
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

    if (CIRCLE) {
      for (int x = 0; x < w; x++) {
        for (int y = 0; y < h; y++) {
          int radius = min(h, w)/2;
          if ( pow(x-w/2.0, 2) + pow(y-h/2, 2) > pow(radius, 2))
            map[x][y] = new MapPnt (0);
        }
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

  void SetPixel(int x, int y, color c)
  {
    int px = x*resolution; 
    int py = y*resolution;
    for (int i = 0; i < resolution; i++) {
      for (int j = 0; j < resolution; j++) {
        pixels[(py+i)*width+(px+j)] = c;
      }
    }
  }

  void PrintMap()
  {
    Render2D();
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        print("(", x, y, ")");
        print(rd(hf(x, y)), " ");
      }
      println("");
    }
    println("gradient");
    for (int y = 0; y < h; y++)
    {
      for (int x = 0; x < w; x++) {

        print("(", rd(gf(x, y).x), ",", rd(gf(x, y).y), ")\t");
      }
      println("");
    }
    println("wind dot", wind);
    for (int y = 0; y < h; y++)
    {
      for (int x = 0; x < w; x++) {
        print(rd(wind.dot(gf(x, y))), "\t");
      }
      println("");
    }
    println("qunatity moved:");
    for (int y = 0; y < h; y++)
    {
      for (int x = 0; x < w; x++) {
        print(rd(QuantityMoved(x, y)), "\t");
      }
      println("");
    }
    println("hop dist");
    for (int y = 0; y < h; y++)
    {
      for (int x = 0; x < w; x++) {
        PVector hop = HopDistance(x, y);//.normalize().mult(50);
        ellipse(x*resolution, y * resolution, 10, 10);
        line(x*resolution, y * resolution, x*resolution+hop.x, y * resolution + hop.y);  
        print("(", rd(hop.x), ",", rd(hop.y), ")\t");
      }
      println("");
    }
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
}


class MapPnt {

  private float h;
  PVector grad;
  int concavity;

  MapPnt(float h)
  {
    this.h = h;
  }

  void SetGradient(PVector grad)
  {
    this.grad = grad;
  }

  void SetGradient(float dx, float dy)
  {
    this.grad = new PVector(dx, dy);
  }

  void AddHeight(float hp)
  {
    h += hp;
  }

  void RemoveHeight(float hm)
  {
    h = max(0, h - hm);
  }
}
