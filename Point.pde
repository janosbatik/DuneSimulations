class Point
{
  int x, y, x_res, y_res, xy;
  int resolution = RESOLUTION;
  int w = width/RESOLUTION;
  int h = height/RESOLUTION;

  Point(int x, int y)
  {
    this.x = x;
    this.y = y;
    this.xy = y*w+x;
    Init();
  }

  Point(int xy)
  {
    this.x = xy%w;
    this.y = xy/h;
    this.xy = xy;
    Init();
  }

  void Init()
  {
    this.x_res = this.x * this.resolution;
    this.y_res = this.y * this.resolution;
  }

  Point Translate(int x, int y)
  {
    return new Point(this.x + x, this.y + y);
  }

  boolean Equals(Point p2) {
    return this.xy == p2.xy;
  }

  void DrawCircle(float diam)
  {
    circle(this.x_res, this.y_res, diam);
  }

  void DrawLine(Point p2)
  {
    line(this.x_res, this.y_res, p2.x_res, p2.y_res);
  }
  
  float Distance(Point p2)
  {
    return sqrt(pow(this.x - p2.x, 2)+pow(this.y-p2.y, 2));
  }
  
  void Print()
  {
    println("x: ", this.x, "y: ", this.y);
  }
}
