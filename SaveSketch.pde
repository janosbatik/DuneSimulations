import java.io.File;
import processing.svg.*;

class SaveSketch {

  // Details of converting to .gif found here:
  // https://sighack.com/post/make-animated-gifs-in-processing

  String projName = "processing";
  String outPutFolder = "frames/";
  String contOutPutFolder = "animate/";
  String staticOutPutFolder = "static/";
  String outputFileType = ".png";
  boolean allowSave;
  int seed;
  boolean saving = false;
  String startTime;

  boolean CLEAR_FILES_ON_LOAD = true;
  boolean PRINT_PROCESS = true;

  int saveCount = 0;
  int maxFrames = 1500;

  SaveSketch(boolean allowSave, String projName)
  {
    this(allowSave);
    this.projName = projName;
  }

  SaveSketch(boolean allowSave, int maxFrames, int seed)
  {
    this(allowSave);
    this.seed = seed;
    this.maxFrames = maxFrames;
  }

  SaveSketch(boolean allowSave)
  {
    this.allowSave = allowSave;
    if (!allowSave)
      return;
    if (CLEAR_FILES_ON_LOAD)
      ClearFilesOnLoad();
    this.startTime = NowString();
  }

  void SaveStaticFrameOnKeyPress()
  {
    if (!allowSave)
      return; 
    if (keyPressed) {
      if (key == 'c' || key == 'C') {
        SaveStaticFrame();
      }
    }
  }

  boolean save_svg_started = false;

  void SaveSVG()
  {
    save_svg_started = true;
  }

  void SaveSVGStart() {
    if (save_svg_started) {
      String file_name = NowString() + "-frame-####" + "-" + ".svg";
      println("saving frame as svg");
      beginRecord(SVG, outPutFolder + "svg/" + file_name);
    }
  }

  void SaveSVGEnd() {
    if (save_svg_started) {
      endRecord();
      println("frame saved as svg");
      save_svg_started = false;
    }
  }

  void SaveStaticFrame()
  {
    if (!allowSave)
      return; 
    String fileName = FileName(contOutPutFolder, true);
    save(fileName);
    PrintLn("Saved frame: "+fileName);
  }

  void StartSaveAsAnimationOnKeyPress()
  {
    if (!allowSave)
      return; 
    if (keyPressed) {
      if (key == 's' || key == 'S') {
        saving = true;
      }
      if (key == 'x' || key == 'X') {
        saving = false;
        PrintLn("Paused saving frames");
      }
    }
    SaveFrameForAnimation();
  }

  void SaveAsAnimation()
  {
    if (!allowSave)
      return; 
    if (saveCount == 0)
      saving = true;
    if (keyPressed) {
      if (key == 'x' || key == 'X') {
        saving = false;
        PrintLn("Stoped saving frames");
      }
    }
    SaveFrameForAnimation();
  }

  private void SaveFrameForAnimation()
  {
    if (!saving)
      return;
    if (saveCount == 0)
      println("Starting to save frames");
    String fileName;
    fileName = FileName(contOutPutFolder, false);
    saveCount++;
    if (saveCount%(maxFrames/10)==0) {
      print(saveCount, " frames saved...    ");
      println("current frameRate=", frameRate);
    }
    if (saveCount <= maxFrames ) 
      save(fileName);
    else {
      println("Max frame count reached ending programe");
      println(saveCount, " total of frames saved.");
      exit();
    }
  }

  private String FileName(String folder, boolean time_stamp)
  {
    String file_name = outPutFolder+folder+"seed"+nf(seed);

    if (time_stamp) {
      file_name += startTime+nf(saveCount, 5)+outputFileType;
    } else {
      file_name += nf(saveCount, 5)+outputFileType;
    }
    return file_name;
  }

  private String NowString() {
    return 
      nf(year(), 4)
      +nf(month(), 2)
      +nf(day(), 2) 
      +"-"
      +nf(hour(), 2)+"h"
      +nf(minute(), 2)+"m"
      +nf(second(), 2);
  }

  private void ClearFilesOnLoad() {
    PrintLn("Starting file clean up");
    dataPath("");
    File dir =  new File(sketchPath(outPutFolder+contOutPutFolder));
    File[] files = dir.listFiles();
    boolean success = true;
    for (int i = 0; i < files.length; i++) {
      success = success && DeleteFile(files[i]);
    }
    if (success)
      PrintLn("\tDeleted files: " + files.length);
    else
      PrintLn("Error deleting");
    PrintLn("Finish file clean up");
    PrintLn("____________________");
  }

  private boolean DeleteFile(File f)
  {
    boolean r  = false;
    if (f.exists()) {
      r =  f.delete();
    }
    return r;
  }

  private void  PrintLn(String str)
  {
    if (PRINT_PROCESS)
      println(str);
  }
}
