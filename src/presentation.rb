class Presentation
  def initialize(dc_kos, pages)
    @dc_kos, @pages  = dc_kos, pages
  end

  def run
    idx = 0
    time_adjustment = 0
    while(idx < @pages.length)
      input = @pages[idx].show(@dc_kos, PresentationState.new(idx, time_adjustment))
      puts "* * * * * * button pressed: #{input}"
      case
      when input == @dc_kos.class::PREVIOUS_PAGE
        # page returned PREV - probably 'B' butten pressed
        idx -= 1
      when input == @dc_kos.class::QUIT
        idx += @pages.length
      when input == @dc_kos.class::SWITCH_VIDEO_MODE
        @dc_kos.next_video_mode
      when input == @dc_kos.class::NEXT_PAGE # if NEXT given, go to next page
          idx += 1
      when input == @dc_kos.class::FWD
        time_adjustment += 300
        time_adjustment = (40 * 60) if time_adjustment > (40 * 60)
      when input == @dc_kos.class::REW
        time_adjustment -= 300
        time_adjustment = 0 if time_adjustment < 0
      end
      puts "- - - - current idx = #{idx}"
      idx = 0 if idx < 0 # do not wrap around backwards
    end
  end
end
