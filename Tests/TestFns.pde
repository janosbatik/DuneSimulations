static class TestFns
{
  /*
    color TranslateToGreyScale(float p)
  {
    return color(ceil(map(p, 0, max_h, 0, 255)));
    //return color(ceil(map(min(p, 1), 0, 1, 0, 255)));
  }
  */
  
  /*
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
  */
  
  /*
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
   */
   
  /*
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
   */
}
