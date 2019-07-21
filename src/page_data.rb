class PresentationState
  attr_reader :page_index, :time_adjustment

  def initialize(page_index, time_adjustment)
    @page_index, @time_adjustment = page_index, time_adjustment
  end
end

class BasePage
  def render_bg(dc_kos)
    dc_kos.render_png("/rd/test_image.png", 0, 0)
  end
end

class ResultConstants
  OK = 0
end

class PageTitleContent
  def initialize(content)
    @content = content
  end

  def render(dc_kos, _presentation_state)
    dc_kos.draw_str(@content, 10, 2, 'white', 'yes')
    ResultConstants::OK
  end
end

class TextContent
  def initialize(x, y, content, colour, show_bg)
    @x, @y, @content, @colour, @show_bg =
      x, y, content, colour, show_bg
  end

  def render(dc_kos, _presentation_state)
    dc_kos.draw_str(@content, @x, @y, @colour, @show_bg)
    ResultConstants::OK
  end
end

class ImageContent
  def initialize(x, y, path)
    @x, @y, @path = x, y, path.strip
  end

  def render(dc_kos, _presentation_state)
    dc_kos.render_png(@path, @x, @y)
    ResultConstants::OK
  end
end

# This renders a 'background' with 640x480 image
# It also renders timer and page progress
class PageBaseContent
  def initialize(path, page_count, start_time)
    @page_count, @start_time = page_count, start_time
    @path = String(path).strip
    puts "-------- Background. path is: "
    p @path
  end

  def render(dc_kos, presentation_state)
    if @path && !@path.empty?
      dc_kos.render_png(@path, 0, 0)
    else
      puts "Rendering background image with no path. Skipping."
    end

    render_timer_progress(dc_kos, @start_time, presentation_state.time_adjustment)
    render_page_progress(dc_kos, @page_count, presentation_state.page_index)
    ResultConstants::OK
  end

  def render_page_progress(dc_kos, page_count, page_index)
    PAGES_BAR_LEN = 640 - 32
    PAGES_Y_POS = 410

    pos_x =
      if page_count <= 1
        0
      else
        (page_index / (page_count - 1) * PAGES_BAR_LEN).to_i
      end

    dc_kos.render_png("/rd/swirl_blue_32x28.png", pos_x, PAGES_Y_POS)
  end

  def render_timer_progress(dc_kos, start_time, time_adjustment)
    DURATION = 40 * 60 # 40 mins
    PROGRESS_LEN = 640 - 32
    PROGRESS_Y_POS = 440

    pos_x = ((Time.now.to_i - start_time.to_i + time_adjustment) / DURATION * PROGRESS_LEN).to_i
    pos_x = PROGRESS_LEN if pos_x > PROGRESS_LEN
    pos_x = 0 if pos_x < 0

    dc_kos.render_png("/rd/swirl_red_32x28.png", pos_x, PROGRESS_Y_POS)
  end
end

# Wait for A or Start in page to go to next section
class WaitButtonContent
  def render(dc_kos, _presentation_state)
    key_input = dc_kos.next_or_back

    if key_input == dc_kos.class::NEXT_PAGE
      ResultConstants::OK
    else
      key_input
    end
  end
end

class DrawHorizontalLineContent
  def initialize(x, y, len, colour)
    @x, @y, @len, @colour = x, y, len, colour.strip.downcase
  end

  def render(dc_kos, _presentation_state)
    # currently supports 'red'
    # everything else will be white
    r, g, b = if @colour == 'red'
      [255, 0, 0]
    else
      [255, 255, 255]
    end

    dc_kos.draw_horizontal_line(@x, @y, @len, r, g, b)
    ResultConstants::OK
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

  def show(dc_kos, presentation_state)
    puts "------ about to call each on @sections"
    p @sections
    @sections.each { |s|
      render_result = s.render(dc_kos, presentation_state)
      puts "-------- section render result: #{ render_result }"

      # return if user pressed PREV, QUIT, etc.
      return render_result unless [dc_kos.class::NEXT_PAGE, ResultConstants::OK].include?(render_result)
    }

    # if waiting for input between sections above did not result in returning
    # input result, get input result here and return it
    return dc_kos.next_or_back
  end
end

class Parser
  def parse_line_xy_col_bg(line)
    split_line = line.split(':')
    tag = split_line[0]
    _unused, x, y, colour, show_bg = tag.split(',')
    rest = split_line[1..-1].join(':')
    return x.to_i, y.to_i, colour, show_bg, rest
  end

  def parse_line_xy_len_col(line)
    split_line = line.split(':')
    tag = split_line[0]
    _unused, x, y, len = tag.split(',')

    return x.to_i, y.to_i, len.to_i, split_line[1]
  end

  def parse_line_no_xy(line)
    split_line = line.split(':')
    path = split_line[1..-1].join(':')
    return path
  end

  def parse(input_str, start_time)
    pages = input_str
      .split("\n")
      .reject { |l| l.slice(0, 1) == '#' } # remove comment lines
      .join("\n")
      .split("\n=")

    page_count = pages.size
    last_background = [PageBaseContent.new(nil, page_count, start_time)]

    page_objs = pages.map { |page|
      parsed_page = page.split("\n-").each_with_index.map { |section, idx|
        case
        when idx == 0
          title = section.sub('=', '').strip # remove the first '='
          PageTitleContent.new(title)
        when section.slice(0,3) == 'txt'
          x, y, colour, show_bg, text_content = parse_line_xy_col_bg(section)
          TextContent.new(x, y, text_content, colour, show_bg)
        when section.slice(0,3) == 'img'
          x, y, _colour, _bg_colour, image_path = parse_line_xy_col_bg(section)
          ImageContent.new(x, y, image_path)
        when section.slice(0,3) == 'bkg'
          bg_path = parse_line_no_xy(section)
          PageBaseContent.new(bg_path, page_count, start_time)
        when section.slice(0,4) == 'wait'
          WaitButtonContent.new
        when section.slice(0,4) == 'line'
          x, y, len,colour = parse_line_xy_len_col(section)
          DrawHorizontalLineContent.new(x, y, len,colour)
        else
          # not sure. keep it as nil
        end
      }.compact

      background_sections = parsed_page.select { |elem| elem.is_a?(PageBaseContent) }
      other_sections = parsed_page.select { |elem| !elem.is_a?(PageBaseContent) }

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
  def initialize(dc_kos, start_time)
    @dc_kos, @start_time = dc_kos, start_time
  end

  def all
    content_str = @dc_kos.read_whole_txt_file("/rd/content.dreampresent")
    parsed_content = Parser.new.parse(content_str, @start_time)
  end
end
