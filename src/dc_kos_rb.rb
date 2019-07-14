# Ruby-level wrapper to DcKos
class DcKosRb
  def initialize(dc_kos)
    @dc_kos = dc_kos
  end

  LINE_HEIGHT = 30
  # this understands '\n' as linebreak
  def draw_str(str, x, y, line_height = LINE_HEIGHT)
    str.split("\n").each_with_index { |line, idx|
      @dc_kos.draw_str(line, x, y + (line_height * idx+1))
    }
  end

  def pvr_initialise(*args)
    @dc_kos.pvr_initialise(*args)
  end

  def test_png(*args)
    @dc_kos.test_png(*args)
  end

  def load_bg_png(*args)
    @dc_kos.load_bg_png(*args)
  end

  def console_print(*args)
    @dc_kos.console_print(*args)
  end

  def get_button_state(*args)
    @dc_kos.get_button_state(*args)
  end

  def btn_start?(*args)
    @dc_kos.btn_start?(*args)
  end
end
