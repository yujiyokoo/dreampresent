class Presentation
  def initialize(dc_kos, pages)
    @dc_kos = dc_kos

    content_str = @dc_kos.read_whole_txt_file("/rd/content.dreampresent")

    @pages = pages
  end

  def run
    idx = 0
    time_adjustment = 0
    while(idx < @pages.length)
      page_result = @pages[idx].render(@dc_kos, PresentationState.new(idx, time_adjustment))
      puts "* * * * * * button pressed: #{page_result}"
      if page_result == @dc_kos.class::PREVIOUS_PAGE
        # page returned PREV - probably 'B' butten pressed
        idx -= 1
      elsif page_result == @dc_kos.class::QUIT # page returned QUIT
        idx += @pages.length
      elsif page_result == @dc_kos.class::FWD
        time_adjustment += 300
        time_adjustment = (40 * 60) if time_adjustment > (40 * 60)
      elsif page_result == @dc_kos.class::REW
        time_adjustment -= 300
        time_adjustment = 0 if time_adjustment < 0
      else
        # page did not return PREV. Now wait for next_page button
        key_input = @dc_kos.next_or_back

        case
        when key_input == @dc_kos.class::NEXT_PAGE # if NEXT given, go to next page
          idx += 1
        when key_input == @dc_kos.class::PREVIOUS_PAGE # if PREV given, go to previous page
          idx -= 1
        when key_input == @dc_kos.class::QUIT # if QUIT given, go to the end
          idx += @pages.length
        when key_input == @dc_kos.class::FWD
          time_adjustment += 300
          time_adjustment = (40 * 60) if time_adjustment > (40 * 60)
        when key_input == @dc_kos.class::REW
          time_adjustment -= 300
          time_adjustment = 0 if time_adjustment < 0
        end
      end
      puts "- - - - current idx = #{idx}"
      idx = 0 if idx < 0 # do not wrap around backwards
    end
  end
end
