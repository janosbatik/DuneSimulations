import peasy.*;

class Camera {

  CameraType camType = CameraType.PEASY;

  float camX, camY, camZ;
  PeasyCam peasyCam;


  Camera(PApplet parent)
  {
    camX = width/2.0;
    camY = height/2.0;
    camZ = 525;
    switch(camType)
    {
    case FIXED:
      break;
    case MOVING:
      break;
    case TOPVIEW:
      camX = 0;
      camY = 0;
      camZ = 650;
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

  void SetCamera()
  {
    switch(camType)
    {
    case FIXED:
      camera(camX, camY, camZ, // eyeX, eyeY, eyeZ
        30, 30, 0.0, // centerX, centerY, centerZ
        0.0, 0.0, -1.0); // upX, upY, upZ;
      break;
    case MOVING:
      camera(camX, camY, mouseY+1, // eyeX, eyeY, eyeZ
        30, 30, 0.0, // centerX, centerY, centerZ
        0.0, 0.0, -1.0); // upX, upY, upZ
      float rot = map(mouseX, 0, width, 0, 2*PI);
      rotateZ(rot);
      break;
    case TOPVIEW:
      camera(0, 0, camZ, // eyeX, eyeY, eyeZ
        0, 0, 0.0, // centerX, centerY, centerZ
        0.0, 1.0, 0); // upX, upY, upZ;
      break;
    case PEASY:

      break;
    }
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
    PEASY
}
