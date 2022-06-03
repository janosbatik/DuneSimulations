class MapPnt {

  private float h;
  PVector grad;
  int concavity;

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

  void AddHeight(float hp)
  {
    h += hp;
  }

  void RemoveHeight(float hm)
  {
    h = max(0, h - hm);
  }
}
