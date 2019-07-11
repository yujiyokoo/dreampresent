class Page
  def initialize(page_data, dc_kos)
    @page_data = page_data
    @dc_kos = dc_kos
  end

  def render
    #puts "rendering page"
    #puts "about to load png"
    #@dc_kos.load_bg_png("/rd/test_image_512x512.png")
    #puts "done load png"

    @page_data.render(@dc_kos)
    #@dc_kos.test_png("/rd/Dreamcast.png", 100, 100)
    #@dc_kos.draw_str("Hello")
  end
end

class Presentation
  def initialize(dc_kos, page_data)
    @dc_kos = dc_kos
    @pages = page_data.map do |pd|
      Page.new(pd, @dc_kos)
    end
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
   # @dc_kos.load_bg_png("/rd/test_image_512x512.png")
   #   wait_for_next_page_button
   # @dc_kos.test_png("/rd/test_image.png", 0, 0)
   #   wait_for_next_page_button
    @pages.each { |page|
      page.render
      wait_for_next_page_button
    }
  end
end
