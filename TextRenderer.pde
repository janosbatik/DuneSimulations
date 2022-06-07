class TextRenderer
{

  char[] text;
  int last_render;
  int character_count = 0;
  color text_color = color(0);
  int next_char_every = 100;
  boolean is_3D = true;
  int z_offset = 200;
  int pause_on_whitespace = 100;
  boolean fin = false;
  int w;
  int h;
  // font
  String font_dir = "assets/";
  String font_file = "typewriterA602.ttf";
  // curser
  char curser_on = '';
  char curser_off = '';

  TextRenderer()
  {
    PFont f = createFont(font_dir+font_file, 32);
    textFont(f);
    textSize(44);
    textAlign(LEFT, TOP);
    this.last_render = millis();
    this.w = width;
    this.h = height;
  }

  TextRenderer(String text)
  {
    this();
    this.text =  text.toCharArray();
  }

  void Render() {

    fill(text_color);
    text(text, 0, character_count+1, 100, 100, z_offset);
    int millis_to_pass = Character.isWhitespace(text[character_count]) ? next_char_every + pause_on_whitespace : next_char_every;
    if ( millis() - last_render > millis_to_pass )
    {
      if (character_count < text.length - 1) {
        character_count++;
      } else {
        fin = true;
      }
      last_render = millis();
    }
  }


}
