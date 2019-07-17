class Dreampresent
  attr_reader :screen, :dc_cos

  def initialize(screen, dc_kos)
    @screen = screen
    @dc_kos = dc_kos
    @dc_kos.pvr_initialise
  end

  def start
    puts "Dreampresent: starting"
    Presentation.new(@dc_kos, PageData.new(@dc_kos).all).run
  end
end
