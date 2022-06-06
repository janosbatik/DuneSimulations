class Lights
{
  Sun sun;

  boolean INCLUDE_SUN = false;
  boolean ADDITIONAL_DEBUG_LIGHTING = true;

  Lights() {
    sun = new Sun();
  }

  void Render() {
    ambientLight(255,  255,  255);
    if (INCLUDE_SUN)
      sun.Render();
    if (ADDITIONAL_DEBUG_LIGHTING)
    {
     // directionalLight(255, 255, 120, -1, -1, -1);
      
    }
   // directionalLight(0, 0, 0, -1, -1, -1); // sky blue
   // directionalLight(128,128,128, -1, 0, 0); // sky blue
  //  directionalLight(255, 255, 128, 0, -1, 0); // yellow
    //ambientLight(100, 100, 100);
    
    int sl = 50;
  //  directionalLight(10, 10, 10, -1, -1, -1);
    directionalLight(sl, sl,sl, 0, -1, -0.2);
    directionalLight(sl,sl,sl, -1, 0, -0.2); 
  }
}

class Sun
{
  boolean DRAW_SPHERE = false;
  int counter = 0;

  int distance_from_center = 1000;
  int size = 50;

  Sun()
  {
  }

  void Render()
  {
    pushMatrix();
    noStroke();

    rotateX(radians(60));
    rotateY(-radians(count++));
    translate(width/2 + distance_from_center, 0, 0);
    pointLight(255-100, 247-100, 204-100, 0, 0, 0); // bright yellow
    //directionalLight(255, 247, 204, -1, 0, 0);
    if (DRAW_SPHERE)
      sphere(size);
    popMatrix();
  }
}
