class BasePage
  def render_bg(dc_kos)
    dc_kos.load_bg_png("/rd/test_image_512x512.png")
  end
end

class Page1 < BasePage
  def render(dc_kos)
    render_bg(dc_kos)
    dc_kos.test_png("/rd/Dreamcast.png", 100, 100)
    dc_kos.draw_str("Hello")
  end
end

class Page2 < BasePage
  def render(dc_kos)
    render_bg(dc_kos)
    dc_kos.test_png("/rd/Dreamcast.png", 200, 200)
    dc_kos.draw_str("Hola")
  end
end

class PageData
  def self.all
    [ Page1.new,
      Page2.new
    ]
  end
end
