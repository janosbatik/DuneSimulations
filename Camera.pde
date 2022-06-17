import peasy.*;

class Camera {

  CameraType camType = CameraType.PEASY;

  float camX, camY, camZ;
  float centerX, centerY, centerZ;
  float upX, upY, upZ;
  PeasyCam peasyCam;


  Camera(PApplet parent)
  {
    switch(camType)
    {
    case FIXED:
    case MOVING:
      SetEye(width/2.0, height/2.0, 525);
      SetCenter(30, 30, 0);
      SetUp(0, 0, -1);
      break;
    case TOPVIEW:
      SetEye(0, 0, 650);
      SetCenter(0, 0, 0);
      SetUp(0, 1, 0);
      break;
    case PEASY:
      peasyCam = new PeasyCam(parent, 525);
      peasyCam.setMinimumDistance(50);
      peasyCam.setMaximumDistance(730);
      break;
    }
  }

  void Reset()
  {
    camX = width/2.0;
    camY = height/2.0;
  }

  void SetEye(float camX, float camY, float camZ) {
    this.camX = camX;  
    this.camY = camY; 
    this.camZ = camZ;
  }
  void SetCenter(  float centerX, float centerY, float centerZ) {
    this.centerX = centerX; 
    this.centerY = centerY; 
    this.centerZ = centerZ;
  }
  void SetUp(float upX, float upY, float upZ) {
    this.upX = upX; 
    this.upY = upY; 
    this.upZ = upZ;
  }


  void SetCamera()
  {
    switch(camType)
    {
    case FIXED:
    case TOPVIEW:
      InvokeCamera();
      break;
    case MOVING:
      camZ = mouseY+1;
      InvokeCamera();
      float rot = map(mouseX, 0, width, 0, 2*PI);
      rotateZ(rot);
      break;
    case TRIGGERED:
      break;
    case PEASY:
      break;
    }
  }

  void InvokeCamera() {
    camera(camX, camY, camZ, centerX, centerY, centerZ, upX, upY, upZ);
  }

  void ScrollToZoom(MouseEvent event) {
    int fact = 4;
    int move = event.getCount()*fact;
    switch(camType)
    {
    case MOVING:
      camX += move;
      camY += move;
      break;
    case TOPVIEW:
      camZ += move;
      break;
    }
  }
}

enum CameraType {
  MOVING, 
    FIXED, 
    TOPVIEW, 
    TRIGGERED, 
    PEASY
}
