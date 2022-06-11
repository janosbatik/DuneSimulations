public static enum RenderType
{
  TRIANGLE_STRIPS, 
    X_LINES, 
    Y_LINES, 
    GRID, 
    TEXTURED, 
    TEXTURED_WITH_LINES, 
    CONCAVITY_DISCRETE, 
    CONCAVITY_GRADIENT, 
    HEIGHT_GRADIENT,
    HEIGHT_DISCRETE;
    

  private static final RenderType[] values = values();

  boolean Is3D()
  {
    switch(this) {
    case TRIANGLE_STRIPS: 
    case TEXTURED: 
    case TEXTURED_WITH_LINES:
    case X_LINES : 
    case  Y_LINES:
    case GRID:
      return true;
    case CONCAVITY_DISCRETE:
    case CONCAVITY_GRADIENT:
    case HEIGHT_GRADIENT:
    case HEIGHT_DISCRETE:
      return false;
    default:
      throw new IllegalArgumentException ("unaccounted render type");
    }
  }

  public RenderType Next()
  {
    boolean t = this.Is3D();
    int i  = 1;
    while (values[(this.ordinal()+i) % values.length].Is3D() != t)
    {
      i++;
    }
    return values[(this.ordinal()+i) % values.length];
  }

  public RenderType Prev() {
    boolean t = this.Is3D();
    int i  = 1;
    while (values[(ordinal() - i  + values.length) % values.length].Is3D() != t)
    {
      i++;
    }
    return values[(ordinal() - i  + values.length) % values.length];
  }
}

enum Concavity
{
  PEAK, 
    TROUGH, 
    INCLINE, 
    DECLINE, 
    FLAT
}
