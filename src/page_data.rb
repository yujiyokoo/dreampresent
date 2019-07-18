class BasePage
  def render_bg(dc_kos)
    dc_kos.render_png("/rd/test_image.png", 0, 0)
  end
end

class PageTitle
  def initialize(content)
    @content = content
  end

  def render(dc_kos)
    dc_kos.draw_str(@content, 10, 2)
  end
end

class TextContent
  def initialize(x, y, content)
    @x = x
    @y = y
    @content = content
  end

  def render(dc_kos)
    dc_kos.draw_str(@content, @x, @y)
  end
end

class ImageContent
  def initialize(x, y, path)
    @x, @y, @path = x, y, path.strip
    puts "-------- ImageContent. path is: "
    p @path
  end

  def render(dc_kos)
    dc_kos.render_png(@path, @x, @y)
  end
end

# This only works as a 'background' with 640x480 image
class BackgroundImage
  def initialize(path)
    @path = String(path).strip
    puts "-------- Background. path is: "
    p @path
  end

  def render(dc_kos)
    if @path && !@path.empty?
      dc_kos.render_png(@path, 0, 0)
    else
      puts "Rendering background image with no path. Skipping."
    end
  end
end

=begin
Parser parses input string (which is prepared by you, or read from a file).

= Equal sign at the beginning of line is start of new page with a title.

-txt,120,200: This means text is shown from (120, 200).
Newlines should be respected.
-img,120,300: /rd/Dreamcast.png
-txt,120,400: The above img line says show the image ("/rd/Dreamcast.png")
from (120, 300)
=

-txt,80,40: This is a title-less page.

=end

class Page
  def initialize(sections)
    @sections = sections
  end

  def render(dc_kos)
    puts "------ about to call each on @sections"
    p @sections
    @sections.each { |s| s.render(dc_kos) }
  end
end

class Parser
  def parse_line_xy(line)
    split_line = line.split(':')
    tag = split_line[0]
    _unused, x, y = tag.split(',')
    rest = split_line[1..-1].join(':').strip
    return x.to_i, y.to_i, rest
  end

  def parse_line_no_xy(line)
    split_line = line.split(':')
    path = split_line[1..-1].join(':')
    return path
  end

  def parse(input_str)
    pages = input_str.split("\n=")

    last_background = [BackgroundImage.new(nil)]

    page_objs = pages.map { |page|
      parsed_page = page.split("\n-").each_with_index.map { |section, idx|
        case
        when idx == 0
          title = section.sub('=', '').strip # remove the first '='
          PageTitle.new(title)
        when section.slice(0,3) == 'txt'
          x, y, text_content = parse_line_xy(section)
          TextContent.new(x, y, text_content)
        when section.slice(0,3) == 'img'
          x, y, image_path = parse_line_xy(section)
          ImageContent.new(x, y, image_path)
        when section.slice(0,3) == 'bkg'
          bg_path = parse_line_no_xy(section)
          BackgroundImage.new(bg_path)
        else
          # not sure. keep it as nil
        end
      }.compact

      background_sections = parsed_page.select { |elem| elem.is_a?(BackgroundImage) }
      other_sections = parsed_page.select { |elem| !elem.is_a?(BackgroundImage) }

      sorted_page =
        if background_sections.empty?
          last_background + other_sections
        else
          last_background = background_sections
          background_sections + other_sections
        end

      puts "==== sorted page:"
      p sorted_page
      Page.new(sorted_page)
    }
  end
end

class PageData
  def initialize(dc_kos)
    @dc_kos = dc_kos
  end

  def all
    content_str = @dc_kos.read_whole_txt_file("/rd/content.dreampresent")
    parsed_content = Parser.new.parse(content_str)
  end
end
