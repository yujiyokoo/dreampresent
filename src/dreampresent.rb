class Dreampresent
  attr_reader :screen, :dc_cos

  def initialize(screen, dc_kos)
    @screen = screen
    @dc_kos = dc_kos
  end

  def start
    puts "Dreampresent: starting"
    Presentation.new(@dc_kos).run
  end
end
