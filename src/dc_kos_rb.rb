# Ruby-level wrapper to DcKos
class DcKosRb
  def initialize(dc_kos)
    @dc_kos = dc_kos
  end

  LINE_HEIGHT = 30
  # this understands '\n' as linebreak
  def draw_str(str, x, y, line_height = LINE_HEIGHT)
    str.split("\n").each_with_index { |line, idx|
      @dc_kos.draw_str(line, x, y + (line_height * idx+1))
    }
  end

  def respond_to?(method)
    if method == :respond_to?
      true
    else
      self.respond_to?(method) || @dc_kos.respond_to?(method)
    end
  end

  def method_missing(method, *args, &block)
    if @dc_kos.respond_to?(method)
      @dc_kos.send(method, *args, &block)
    else
      fail NoMethodError, "undefined method '#{method}'"
    end
  end
end
