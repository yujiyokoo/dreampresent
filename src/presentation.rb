class Page
  def initialize(dc_kos)
    @dc_kos = dc_kos
  end

  def load
    puts "loading text and images..."
    self
  end

  def render
    #puts "rendering page"
    #puts "about to load png"
    #@dc_kos.load_bg_png("/rd/test_image_512x512.png")
    #puts "done load png"

    @dc_kos.test_png("/rd/Dreamcast.png", 100, 100)
    @dc_kos.draw_str("Hello")
  end
end

class Presentation
  def initialize(dc_kos)
    @dc_kos = dc_kos
    @pages = [Page.new(@dc_kos)]
  end

  def wait_for_next_page_button
    while true do
      @dc_kos.draw_str("Waiting...")
      rand(1) # hopefully this would give us a "more random" start point
      button_state = @dc_kos::get_button_state

      break if @dc_kos::btn_start?(button_state)
    end
  end

  def run
    @dc_kos.load_bg_png("/rd/test_image_512x512.png")
      wait_for_next_page_button
    @dc_kos.test_png("/rd/test_image.png", 0, 0)
      wait_for_next_page_button
    @pages.each { |page|
      page.load.render
      wait_for_next_page_button
    }
  end
end
