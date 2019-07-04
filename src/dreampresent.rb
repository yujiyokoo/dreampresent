class Dreampresent
  attr_reader :screen, :dc_cos

  def initialize(screen, dc_kos)
    @screen = screen
    @dc_kos = dc_kos
  end

  def start
    puts "in start"
    file_content = @dc_kos.read_whole_txt_file "/rd/foobar.txt"
    puts "before draw str"
    @dc_kos.draw_str file_content
    puts "started"
  end
end
