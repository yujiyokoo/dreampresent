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

  # this is for 512x512 images
  def load_fullscreen_png(filepath)
    load_png(filepath, 1, 1, 640, 640)
  end

  # This and method_missing are for delegating functions not defined here to @dc_kos
  def respond_to?(method)
    if method == :respond_to?
      true
    else
      self.respond_to?(method) || @dc_kos.respond_to?(method)
    end
  end

  # This and respond_to? are for delegating functions not defined here to @dc_kos
  def method_missing(method, *args, &block)
    if @dc_kos.respond_to?(method)
      @dc_kos.send(method, *args, &block)
    else
      fail NoMethodError, "undefined method '#{method}'"
    end
  end

  NEXT_PAGE = 1
  PREVIOUS_PAGE = -1
  QUIT = -2

  def next_or_back
    while true do
      rand(1) # hopefully this would give us a "more random" start point
      button_state = @dc_kos::get_button_state

      # press STRAT or A to go forward
      return NEXT_PAGE if @dc_kos::btn_start?(button_state) || @dc_kos::btn_a?(button_state)
      return NEXT_PAGE if @dc_kos::btn_start?(button_state) || @dc_kos::btn_a?(button_state)

      # press B to go back
      return PREVIOUS_PAGE if @dc_kos::btn_b?(button_state)

      # press DOWN and B to quit
      return QUIT if @dc_kos::dpad_down?(button_state) || @dc_kos::btn_b?(button_state)
    end
  end
end
