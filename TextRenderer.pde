// TODO: change from millis to frames. Millis doesnt work when framerate drops because of saving  

class TextRenderer
{

  ArrayList<SectionObj> sectioned_text;
  int rendering_section = 0;

  // timing 
  IntObj shared_previous_state_change_frm_cnt = new IntObj(frameCount);
  TimingObj letter_timing = new TimingObj(50, shared_previous_state_change_frm_cnt);
  TimingObj whitespace_timing = new TimingObj(100, shared_previous_state_change_frm_cnt);
  TimingObj blink_timing = new TimingObj(400, shared_previous_state_change_frm_cnt);
  TimingObj end_of_section_timing = new TimingObj(1600);

  // positioning
  int w = width;
  int h = height;  
  int translate_x =-w/2;
  int translate_y = -h/2;
  float z_offset = 180;

  // font
  color text_color = color(0);
  int font_size = 20;
  String font_dir = "assets/";
  String font_file = "SourceCodePro-Medium.otf";

  // curser
  boolean include_cursor = true;
  char cursor_on = '';
  char cursor_off = '';


  // settings
  boolean render_text = true;
  boolean completed_rendering;
  String delimiter = "#";

  TextRenderer(String full_text)
  {
    ParseText(full_text);

    PFont f = createFont(font_dir+font_file, 50);
    textFont(f);
    textSize(font_size);
    textAlign(LEFT, TOP);
  }

  void ParseText(String full_text)
  {
    String tx;
    SectionObj so = null;
    sectioned_text = new ArrayList<SectionObj> ();
    String[] split = full_text.split(delimiter);
    for (int i = 0; i < split.length; i++) {
      tx = split[i];
      if (i%2 == 0) {
        if (include_cursor)
          tx = tx + cursor_off;
        so =  new SectionObj(tx);
        sectioned_text.add(so);
      } else {
        String[] pos = tx.split(",");
        so.x_pos =  Integer.parseInt(pos[0]);
        so.y_pos =  Integer.parseInt(pos[1]);
      }
    }
  }

  void RenderSection(SectionObj sect)
  {
    if (render_text) {
      text(sect.text, 0, sect.character_count+1, sect.x_pos, sect.y_pos, z_offset);
    }
    TimingObj timing = Character.isWhitespace(sect.GetLastChar()) ? whitespace_timing : letter_timing; 
    if (!sect.finished) {
      if ( ShouldContinue(timing) )
      {
        sect.IncrementCharCount();
        if (sect.finished) {
          end_of_section_timing.Update();
        }
      }
    } else {
      BlinkCursor(sect);
    }
  }

  void BlinkCursor(SectionObj sect)
  {
    if (include_cursor) {
      if (ShouldContinue(blink_timing))
      {
        sect.text[sect.text.length-1] = sect.GetLastChar() == cursor_on ? cursor_off : cursor_on;
      }
    }
  }

  boolean ShouldContinue(TimingObj timing) {

    if (frameCount - timing.previous_state_change_frm_cnt.Get() >= timing.frms_between_state_change) {
      timing.Update();
      return true;
    } else {
      return false;
    }
  }

  void Render3D()
  { 
    pushMatrix(); 
    fill(text_color, 10); 
    translate(translate_x, translate_y, 0); 
    fill(text_color); 

    SectionObj sect = sectioned_text.get(rendering_section);
    if (sect.finished && !completed_rendering) {
      if (ShouldContinue(end_of_section_timing))
      {
        if (rendering_section < sectioned_text.size() - 1) {
          rendering_section++;
          sect = sectioned_text.get(rendering_section);
        } else {
          completed_rendering = true;
        }
      }
    } 
    RenderSection(sect);

    if (completed_rendering)
      OnCompletion();


    popMatrix();
  }

  float vel = 0;
  float acc = 10/FRAME_RATE;
  float sink = 15;
  void OnCompletion()
  {

    if (z_offset > 15) {
      vel += acc;
      z_offset = max(15, z_offset - vel);
    } else {
      z_offset -= 0.05;
    }
  }
}

class TimingObj {

  int frms_between_state_change;
  int millis;
  IntObj previous_state_change_frm_cnt;
  float expected_frame_rate = FRAME_RATE;

  TimingObj(float millis, IntObj shared_previous_state_change_frm_cnt)
  {
    this.millis = ceil(millis);
    this.frms_between_state_change = ceil(millis/1000.0*expected_frame_rate);
    this.previous_state_change_frm_cnt = shared_previous_state_change_frm_cnt;
  }

  TimingObj(float millis)
  {
    this(millis, new IntObj(frameCount));
  }

  void Update() {
    this.previous_state_change_frm_cnt.Set(frameCount);
  }
}

class IntObj
{
  private int value;

  IntObj(int value) {
    this.value = value;
  }

  void Set(int value) {
    this.value = value;
  }
  int Get() {
    return this.value;
  }
}

class SectionObj
{
  int x_pos = 100;
  int y_pos = 100;

  boolean finished = false;
  int character_count = 0;
  char[] text;

  SectionObj(String str) {
    this.text = str.toCharArray();
  }

  char GetLastChar()
  {
    return text[character_count];
  }

  void IncrementCharCount()
  {
    if (character_count < text.length)
      character_count++;
    if (character_count == text.length - 1)
      finished = true;
  }
}
