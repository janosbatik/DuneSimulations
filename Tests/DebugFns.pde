class DebugFns
{
void DrawAxisBox()
{
  color red = color(255, 0, 0);
  color blue = color(0, 0, 255);
  color green =  color(0, 255, 0);

  // x-axis
  stroke(red);
  line(-100, 0, 0, 100, 0, 0);
  line(0, 1, 0, 100, 1, 0);
  // y-axis
  stroke(blue);
  line(0, -100, 0, 0, 100, 0);
  line(1, 0, 0, 1, 100, 0);
  // z-axis
  stroke(green);
  line(0, 0, -100, 0, 0, 100);
  line(1, 0, 0, 1, 0, 100);

  stroke(255);
  box(50);
}
}
