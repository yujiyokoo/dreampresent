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
  def parse_line(line)
    split_line = line.split(': ')
    tag = split_line[0]
    _unused, x, y = tag.split(',')
    rest = split_line[1..-1].join(': ')
    return x.to_i, y.to_i, rest
  end

  def parse(input_str)
    pages = input_str.split("\n=")

    pages.map { |page|
      parsed_page = page.split("\n-").each_with_index.map { |section, idx|
        case
        when idx == 0
          title = section.sub('=', '')
          puts "title found: #{title}"
          p PageTitle.new(title)
          PageTitle.new(title)
        when section.slice(0,3) == 'txt'
          puts "******** text content found"
          p section
          x, y, text_content = parse_line(section)
          puts "******** parsed:"
          p x, y, text_content
          # it's text
          TextContent.new(x, y, text_content)
        when section.slice(0,3) == 'img'
          # it's image
          x, y, image_path = parse_line(section)
          ImageContent.new(x, y, image_path)
        else
          # not sure. keep it as nil
        end
      }.compact
      puts "==== parsed page:"
      p parsed_page
      Page.new(parsed_page)
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
