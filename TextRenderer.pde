class TextRenderer
{

  char[] text;
  int last_render;
  int character_count = 0;
  color text_color = color(255);
  int next_char_every = 100;

  int pause_on_whitespace = 100;
  boolean fin = false;


  TextRenderer(String text)
  {
    this.text =  text.toCharArray();
    textSize(44);
    textAlign(LEFT, TOP);
    last_render = millis();
  }

  void Render() {
    fill(text_color);
    text(text, 0, character_count+1, 100, 100);
    int millis_to_pass = Character.isWhitespace(text[character_count]) ? next_char_every + pause_on_whitespace : next_char_every;
    println(millis_to_pass, text[character_count]);
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
