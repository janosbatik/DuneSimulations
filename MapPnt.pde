class MapPnt {

  float h;
  PVector grad;
  float rate_change_x;
  float rate_change_y;
  Concavity hor_concavity;
  Concavity vert_concavity;
  Concavity convacity;
  

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

  float AddHeight(float hp)
  {
    this.h += hp;
    return this.h;
  }

  float RemoveHeight(float hm)
  {
    this.h = max(0, h - hm);
    return this.h;
  }
}
