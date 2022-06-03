float map[][];
int scale;
int w, h;
float max_h;
PVector max_grad;

void setup() {
  size(600, 600);
  noLoop();
  scale = 60;
  w = width/scale; 
  h = height/scale;
  map = new float[w][h];
  background(255);
  float p;
  max_h = 0;
  max_grad = new PVector(0, 0);
  float noiseScale = 10;
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      //p = pow(2, min(x > w/2 ? w-x: x +1, y > h/2 ? h-y: y +1));
      p = noise(x/noiseScale, y/noiseScale);
      max_h = max(p, max_h);
      map[x][y] = p; 
    }
  }
}

void draw() {
  RenderMap();
}

void RenderMap(){
    color c;
    noStroke();
    PVector wind = new PVector(1, 1);
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        int cVal= ceil(map(hf(x,y), 0, max_h, 0, 255));
        c = color(cVal);
        fill(cVal);
        rect(x*scale, y*scale, scale, scale);
        int invCVal = cVal > 255/2 ? 0 : 255; 
        fill(invCVal);
        text(hf(x,y), x*scale, y*scale+10);
        PVector g = Gradient(x,y);
        text(PVecToStr(g), x*scale, y*scale+20);
        text(g.dot(wind), x*scale, y*scale+30);
      }
    }
}

String PVecToStr(PVector p){
  return  "("+p.x+","+p.y+")";
}

float hf(int x, int y){
  return map[x][y];
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
