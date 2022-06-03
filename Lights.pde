class Lights
{
  Sun sun;
  
  Lights() {
    sun = new Sun();
  }

  void Render(){
  Setup1();
  }
  
  void  Setup1()
  {
    sun.Render();
    directionalLight(255, 255, 140, 0, -1, 0);
    ambientLight(100, 100, 100);
    directionalLight(255, 0, 0, 0, -1, 0);
  }
}

class Sun
{
  boolean DRAW_SPHERE = true;
  int counter = 0;

  int distance_from_center = 100;
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
    pointLight(255, 255, 120, 0, 0, 0);
    //directionalLight(255, 255, 120, -1, 0, 0);
    if (DRAW_SPHERE)
      sphere(size);
    popMatrix();
  }
}
