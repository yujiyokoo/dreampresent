class BasePage
  def render_bg(dc_kos)
    dc_kos.render_png("/rd/test_image.png", 0, 0)
  end
end

PageClasses = []

PageClasses.push (Class.new(BasePage) do
  def render(dc_kos)
    render_bg(dc_kos)
    dc_kos.console_print("----------------")
    dc_kos.render_png("/rd/Dreamcast.png", 100, 100)
    dc_kos.draw_str("Developing Dreamcast games with mruby", 60, 30)
    dc_kos.draw_str("Yuji Yokoo - @yujiyokoo", 60, 60)
  end
end).new

PageClasses.push (Class.new(BasePage) do
  def render(dc_kos)
    render_bg(dc_kos)
    dc_kos.console_print("----------------")
    dc_kos.draw_str("About me (Yuji)", 60, 30 )
    dc_kos.draw_str("Yuji Yokoo - Software developer\n15 years ago: Win32/MFC Desktop application developer", 60, 60 )
    dc_kos.draw_str("Likes: Ruby, Console games", 60, 120 )
  end
end).new

class PageData
  def self.all
    PageClasses
  end
end
