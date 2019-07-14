class Page
  def initialize(page_data, dc_kos)
    @page_data = page_data
    @dc_kos = dc_kos
  end

  def render
    @page_data.render(@dc_kos)
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
      rand(1) # hopefully this would give us a "more random" start point
      button_state = @dc_kos::get_button_state

      break if @dc_kos::btn_start?(button_state)
    end
  end

  def run
    @pages.each { |page|
      page.render
      wait_for_next_page_button
    }
  end
end
