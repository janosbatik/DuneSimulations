public static enum RenderType
{
  TRIANGLE_MESH, 
    X_LINES, 
    Y_LINES, 
    GRID, 
    TEXTURED, 
    TEXTURED_WITH_TRIANGLE_MESH, 
    CONCAVITY_DISCRETE, 
    CONCAVITY_GRADIENT, 
    CONCAVITY_LINEWORK_STRING,
    CONCAVITY_LINEWORK_STRAIGHT,
    HEIGHT_GRADIENT, 
    HEIGHT_DISCRETE
    ;


  private static final RenderType[] values = values();

  boolean Is3D()
  {
    switch(this) {
    case TRIANGLE_MESH: 
    case TEXTURED: 
    case TEXTURED_WITH_TRIANGLE_MESH:
    case X_LINES : 
    case  Y_LINES:
    case GRID:
      return true;
    case CONCAVITY_DISCRETE:
    case CONCAVITY_GRADIENT:
    case CONCAVITY_LINEWORK_STRING:
    case CONCAVITY_LINEWORK_STRAIGHT:
    case HEIGHT_GRADIENT:
    case HEIGHT_DISCRETE:
      return false;
    default:
      throw new IllegalArgumentException ("unaccounted render type");
    }
  }

  boolean BasedOnConcavity()
  {
    switch (this) {
    case CONCAVITY_DISCRETE:    
    case CONCAVITY_GRADIENT:
    case CONCAVITY_LINEWORK_STRING:
    case CONCAVITY_LINEWORK_STRAIGHT:
      return true;
    default:
      return false;
    }
  }
  
    boolean OutputsGCode()
  {
    switch (this) {
    case CONCAVITY_LINEWORK_STRING:
    case CONCAVITY_LINEWORK_STRAIGHT:
      return true;
    default:
      return false;
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

enum Directions
{
  N, 
    NE, 
    E, 
    SE, 
    S, 
    SW, 
    W, 
    NW;

  int XMove()
  {
    switch (this)
    {  
    case N: 
    case S:
      return 0;
    case NE:
    case E:
    case SE:
      return 1;
    case SW:
    case W:
    case NW:
      return -1;
    default:
      return 0;
    }
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
