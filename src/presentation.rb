class Presentation
  def initialize(dc_kos, pages)
    @dc_kos = dc_kos

    content_str = @dc_kos.read_whole_txt_file("/rd/content.dreampresent")

    @pages = pages
  end

  def next_or_back(length)
    while true do
      rand(1) # hopefully this would give us a "more random" start point
      button_state = @dc_kos::get_button_state

      # press STRAT or A to go forward
      return 1 if @dc_kos::btn_start?(button_state) || @dc_kos::btn_a?(button_state)
      return 1 if @dc_kos::btn_start?(button_state) || @dc_kos::btn_a?(button_state)

      # press B to go back
      return -1 if @dc_kos::btn_b?(button_state)

      # press DOWN and B to quit
      return length if @dc_kos::dpad_down?(button_state) || @dc_kos::btn_b?(button_state)
    end
  end

  def run
    idx = 0
    while(idx < @pages.length)
      @pages[idx].render(@dc_kos)
      idx += next_or_back(@pages.length)
      idx = 0 if idx < 0
    end
  end
end
