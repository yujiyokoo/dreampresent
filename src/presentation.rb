class Presentation
  def initialize(dc_kos, pages)
    @dc_kos = dc_kos

    content_str = @dc_kos.read_whole_txt_file("/rd/content.dreampresent")

    @pages = pages
  end

  def wait_for_next_page_button
    while true do
      rand(1) # hopefully this would give us a "more random" start point
      button_state = @dc_kos::get_button_state

      break if @dc_kos::btn_start?(button_state) || @dc_kos::btn_a?(button_state)
    end
  end

  def run
    @pages.each { |page|
      page.render(@dc_kos)
      wait_for_next_page_button
    }
  end
end
