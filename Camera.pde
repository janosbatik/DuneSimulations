import peasy.*;

class Camera {

  CameraType camType = CameraType.TOPVIEW;

  float camZ = 280;
  float camX;
  float camY;
  PeasyCam cam;


  Camera(PApplet parent)
  {
    camX = width/2.0;
    camY = height/2.0;
    if (camType == CameraType.PEASY) {
      cam = new PeasyCam(parent, 100);
      cam.setMinimumDistance(50);
      cam.setMaximumDistance(500);
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
    case TOPVIEW:
      camera(0, 0, 200, // eyeX, eyeY, eyeZ
        0, 0, 0.0, // centerX, centerY, centerZ
        0.0, 0.0, -1.0); // upX, upY, upZ;
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
