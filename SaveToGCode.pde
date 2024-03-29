// TODO: create off screen rendering of print
// flip draw order


import geomerative.*;

boolean CONFIG_GCODE_KEEP_SVG = true; 
final boolean CONFIG_GCODE_WRITE_TO_FILE = true;
final String CONFIG_GCODE_OUTPUT_FOLDER = "frames/gcode/";

final int CONFIG_GCODE_WIDTH_MM = 150;
final int CONFIG_GCODE_HEIGHT_MM = 150;
final int CONFIG_GCODE_XOFFSET_MM = 40;
final int CONFIG_GCODE_YOFFSET_MM = 40;
final int CONFIG_GCODE_XMAX_MM = CONFIG_GCODE_WIDTH_MM+CONFIG_GCODE_XOFFSET_MM;
final int CONFIG_GCODE_YMAX_MM = CONFIG_GCODE_HEIGHT_MM+CONFIG_GCODE_YOFFSET_MM;

final String CONFIG_GCODE_PEN_UP = "G0 Z20 F4500 ; pen up\n";
final String CONFIG_GCODE_PEN_DOWN = "G0 Z15 F4500 ; pen down\n";
final String CONFIG_GCODE_MOVE_FEEDRATE = "4500";
final String CONFIG_GCODE_RAPID_FEEDRATE = "4500";
final String CONFIG_GCODE_PRE =
  "M75 ; Start print timer\n" +
  "G21 ; set coords to mm\n" +
  "G0 Z30 F4500.0 ; raise z-axis so it is clear before homing\n" +
  "G28 ; home all axis\n" +
  "G0 Z30 F4500.0 ; raise z-axis so it is clear for first move\n" +
  "G0 X40 Y40 F4500 ; move to start from height\n" +
  "(end of header)\n\n";
final String CONFIG_GCODE_POST =
  "\n\n(start footer)\n" +
  "G0 Z20.00 F600 ; Move print head up\n" +
  "G0 X5 Y180 F9000 ; present print\n" +
  "M84 X Y E ; disable motors\n" +
  "M77 ; Stop print timer\n";

boolean penDown = false;

final boolean CONFIG_GCODE_PRINT_PREVIEW = true;
final boolean CONFIG_GCODE_PRINT_PREVIEW_PRINT_GCODE = true;
final boolean CONFIG_PRINTPREVIEW_DRAW_TRAVELS = true; 
PrintPreviewPointObj CONFIG_GCODE_HOME_COORDS = new PrintPreviewPointObj(0, 0, false);
ArrayList<PrintPreviewPointObj> prtprvw_point_list = new ArrayList<PrintPreviewPointObj>();
int prtprvw_count = 0;


void savePrintSet()
{
  if (CONFIG_GCODE_PRINT_PREVIEW)
    prtprvw_point_list.add(CONFIG_GCODE_HOME_COORDS);
  CONFIG_GCODE_KEEP_SVG = true;
  String folder = "seed" + nf(seed, 10) + "-t" + nf(dune.errode_count, 4) + "-" + gcode_NowString();
  save(CONFIG_GCODE_OUTPUT_FOLDER + folder + ".png"); // save thumbnail
  for (int i = 0; i < dune.renderer.number_render_sections; i++) {
    println("saving ", i+1, " of ", dune.renderer.number_render_sections);
    dune.Render();
    String prefix = folder+"/rendsect"+nf(dune.renderer.render_section);
    saveGcode(prefix);
    save(gcode_FileName(prefix, ".png"));
    dune.renderer.NextRenderSection();
  }
  println("\nfinished rendering gcode.");
}

void saveGcode(String prefix) {
  println("Saving Gcode...");
  /* Write image to temporaray SVG file */
  String svg_file_name = gcode_SaveSVG(prefix);

  /* Generate Gcode */
  String gcode = __generateGcode(svg_file_name);

  if (CONFIG_GCODE_WRITE_TO_FILE) {
    /* Write out the Gcode file */
    String gcode_file_name = gcode_FileName(prefix, ".gcode");
    PrintWriter out = createWriter(gcode_file_name);
    out.println(gcode);
    out.flush();
    out.close();
    println("gcode saved as: ", gcode_file_name);
  } else {
    println(gcode);
  }

  if (!CONFIG_GCODE_KEEP_SVG) {
    File file = sketchFile(svg_file_name);
    file.delete();
  }

  println("Finished saving Gcode\n");
}

String gcode_SaveSVG(String prefix)
{
  String file_name = gcode_FileName(prefix, ".svg");
  beginRecord(SVG, file_name); 
  noFill();
  Render();
  endRecord();
  return file_name;
}

String gcode_FileName(String prefix, String ext) {
  return CONFIG_GCODE_OUTPUT_FOLDER + prefix +"-seed" + nf(seed, 10) + "-" + nf(dune.errode_count, 4) + "-" + gcode_NowString() + ext;
}
/*
 * Encode a given point (x, y) into the different regions of
 * a clip window as specified by its top-left corner (cx, cy)
 * and it's width and height (cw, ch).
 */
int encode_endpoint(
  float x, float y, 
  float clipx, float clipy, float clipw, float cliph)
{
  int code = 0; /* Initialized to being inside clip window */

  /* Calculate the min and max coordinates of clip window */
  float xmin = clipx;
  float xmax = clipx + clipw;
  float ymin = clipy;
  float ymax = clipy + clipw;

  if (x < xmin)       /* to left of clip window */
    code |= (1 << 0);
  else if (x > xmax)  /* to right of clip window */
    code |= (1 << 1);

  if (y < ymin)       /* below clip window */
    code |= (1 << 2);
  else if (y > ymax)  /* above clip window */
    code |= (1 << 3);

  return code;
}

class ClippedLineResponse {
  public float x0, y0;
  public float x1, y1;
  public boolean clipped;
  public boolean reject;

  ClippedLineResponse() {
    clipped = false;
    reject = false;
  }

  void set(float px0, float py0, float px1, float py1) {
    x0 = px0;
    y0 = py0;
    x1 = px1;
    y1 = py1;
  }
};

ClippedLineResponse line_clipped(
  float x0, float y0, float x1, float y1, 
  float clipx, float clipy, float clipw, float cliph) {

  /* Stores encodings for the two endpoints of our line */
  int e0code, e1code;

  ClippedLineResponse ret = new ClippedLineResponse();

  /* Calculate X and Y ranges for our clip window */
  float xmin = clipx;
  float xmax = clipx + clipw;
  float ymin = clipy;
  float ymax = clipy + cliph;

  /* Whether the line should be drawn or not */
  //boolean accept = false;
  ret.reject = true;

  do {
    /* Get encodings for the two endpoints of our line */
    e0code = encode_endpoint(x0, y0, clipx, clipy, clipw, cliph);
    e1code = encode_endpoint(x1, y1, clipx, clipy, clipw, cliph);

    if (e0code == 0 && e1code == 0) {
      /* If line inside window, accept and break out of loop */
      //accept = true;
      ret.reject = false;
      break;
    } else if ((e0code & e1code) != 0) {
      /*
       * If the bitwise AND is not 0, it means both points share
       * an outside zone. Leave accept as 'false' and exit loop.
       */
      break;
    } else {
      /* Pick an endpoint that is outside the clip window */
      int code = e0code != 0 ? e0code : e1code;

      float newx = 0, newy = 0;

      /*
       * Now figure out the new endpoint that needs to replace
       * the current one. Each of the four cases are handled
       * separately.
       */
      if ((code & (1 << 0)) != 0) {
        /* Endpoint is to the left of clip window */
        newx = xmin;
        newy = ((y1 - y0) / (x1 - x0)) * (newx - x0) + y0;
      } else if ((code & (1 << 1)) != 0) {
        /* Endpoint is to the right of clip window */
        newx = xmax;
        newy = ((y1 - y0) / (x1 - x0)) * (newx - x0) + y0;
      } else if ((code & (1 << 3)) != 0) {
        /* Endpoint is above the clip window */
        newy = ymax;
        newx = ((x1 - x0) / (y1 - y0)) * (newy - y0) + x0;
      } else if ((code & (1 << 2)) != 0) {
        /* Endpoint is below the clip window */
        newy = ymin;
        newx = ((x1 - x0) / (y1 - y0)) * (newy - y0) + x0;
      }

      /* Now we replace the old endpoint depending on which we chose */
      if (code == e0code) {
        x0 = newx;
        y0 = newy;
      } else {
        x1 = newx;
        y1 = newy;
      }

      ret.clipped = true;
    }
  } while (true);

  /* Only draw the line if it was not rejected */
  if (!ret.reject)
    ret.set(x0, y0, x1, y1);

  return ret;
}



String __moveTo(float x, float y, boolean penDown) {
  boolean in_bounds = LimitCheck(x, y);

  String feed = penDown ?  CONFIG_GCODE_MOVE_FEEDRATE : CONFIG_GCODE_RAPID_FEEDRATE;
  String G = penDown ? "G1" : "G0";
  String gcode =  
    G + 
    " X" + str(x+CONFIG_GCODE_XOFFSET_MM) +
    " Y" + str(y+CONFIG_GCODE_YOFFSET_MM) +
    " F" + feed +
    "\n";
  StorePrintPreviewData(x, y, penDown, gcode);
  if (in_bounds) {
    return gcode;
  } else { 
    return "(ATTEMPTED TO ADD BAD GCODE: " + gcode + ")";
  }
}

void StorePrintPreviewData(float x, float y, boolean penDown, String gcode)
{
  if (CONFIG_GCODE_PRINT_PREVIEW) {
    if (CONFIG_GCODE_PRINT_PREVIEW_PRINT_GCODE) {
      prtprvw_point_list.add(new PrintPreviewPointObj(x, y, penDown, gcode));
    } else {
      prtprvw_point_list.add(new PrintPreviewPointObj(x, y, penDown));
    }
  }
}

boolean LimitCheck(float x, float y)
{
  boolean in_bounds = true;
  if (x > CONFIG_GCODE_XMAX_MM)
    in_bounds = false;
  if (y > CONFIG_GCODE_YMAX_MM)
    in_bounds = false;
  if (!in_bounds)
    println("WARNING: attempting to write gcode out of bounds: x: ", x, "y; ", y);
  return in_bounds;
}

int count = 0;

String __drawLine(float x0, float y0, float x1, float y1) {
  String snippet = "";
  ClippedLineResponse ret = line_clipped(x0, y0, x1, y1, 0, 0, CONFIG_GCODE_WIDTH_MM, CONFIG_GCODE_HEIGHT_MM);
  if (ret.reject) {  
    if (penDown) {
      snippet += CONFIG_GCODE_PEN_UP;
      penDown = false;
    }
    return snippet;
  }
  snippet += __moveTo(ret.x0, ret.y0, penDown);
  if (!penDown) {
    snippet += CONFIG_GCODE_PEN_DOWN;
    penDown = true;
  }
  snippet += __moveTo(ret.x1, ret.y1, penDown);

  if (ret.clipped) {
    snippet += CONFIG_GCODE_PEN_UP;
    penDown = false;
  }

  return snippet;
}

RPoint[][] gcode_SVGToPointArray(String svg_file)
{
  RShape grp;
  RPoint[][] paths;
  boolean ignoringStyles = false;

  /* Load SVG file and convert to paths */
  RG.init(this);
  RG.ignoreStyles(ignoringStyles);
  RG.setPolygonizer(RG.ADAPTATIVE);
  grp = RG.loadShape(svg_file);
  grp.centerIn(g, 0, 0, 0);
  paths = grp.getPointsInPaths();
  return paths;
}

String __generateGcode(String svg_file) {
  String gcode = CONFIG_GCODE_PRE;
  RPoint[][] paths = gcode_SVGToPointArray(svg_file);
  for (int i = 0; i < paths.length; i++) {
    if (paths[i] == null)
      continue;
    //boolean outOfClip = true;
    float lastx = 0;
    float lasty = 0;
    gcode += "(starting path " + nf(i) + " of " + nf(paths.length) + ")\n";
    for (int j = 0; j < paths[i].length; j++) {
      //vertex(pointPaths[i][j].x, pointPaths[i][j].y);
      float xmapped = map(paths[i][j].x, 0, width, 0, CONFIG_GCODE_WIDTH_MM);
      /* Flip Y axis since GRBL expects (0, 0) to be at the bottom left */
      float ymapped = map(paths[i][j].y, 0, height, CONFIG_GCODE_HEIGHT_MM, 0);

      if (j == 0) {
        lastx = xmapped;
        lasty = ymapped;
        continue;
      }
      if (lastx == xmapped && lasty == ymapped)
        continue;

      gcode += __drawLine(lastx, lasty, xmapped, ymapped);
      lastx = xmapped;
      lasty = ymapped;
    }
    gcode += CONFIG_GCODE_PEN_UP;
    penDown = false;
  }

  gcode += CONFIG_GCODE_POST;
  return gcode;
}

String gcode_NowString() {
  return 
    nf(year(), 4)
    +nf(month(), 2)
    +nf(day(), 2) 
    +"-"
    +nf(hour(), 2)+"h"
    +nf(minute(), 2)+"m"
    +nf(second(), 2);
}


/*
//
 //  PRINT PREVIEW
 //
 */


class PrintPreviewPointObj {
  float x;
  float y;
  boolean penDown;
  String gcode;

  PrintPreviewPointObj(float x, float y, boolean penDown, String gcode) {
    this(x, y, penDown);
    this.gcode = gcode;
  }

  PrintPreviewPointObj(float x, float y, boolean penDown)
  {
    this.x = map(x, 0, CONFIG_GCODE_WIDTH_MM, 0, width);
    this.y = map(y, 0, CONFIG_GCODE_HEIGHT_MM, 0, height);
    this.penDown = penDown;
  }
}

boolean PrintPreview() {

  if (prtprvw_count == 0)
    background(255); // clear background
  if (prtprvw_count>=prtprvw_point_list.size()-1) {
    return true;
  }
  PrintPreviewPointObj p1, p2;
  p1 = prtprvw_point_list.get(prtprvw_count);
  p2 = prtprvw_point_list.get(prtprvw_count+1);
  if (p1.penDown) {
    stroke(0);
  } else {
    stroke(255, 0, 0, 10);
  }
  pushMatrix();
  rotate(PI);
  translate(-width, -height);
  line(p1.x, p1.y, p2.x, p2.y);
  popMatrix();
  if (CONFIG_GCODE_PRINT_PREVIEW_PRINT_GCODE)
    print(p2.gcode);
  prtprvw_count ++;
  return false;
}
