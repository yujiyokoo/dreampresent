class Dreampresent
  def initialize(dc_kos)
    @dc_kos = dc_kos
  end

  def start
    puts "Dreampresent: starting"
    Presentation.new(@dc_kos,
      PageData.new(@dc_kos).all
    ).run
  end
end
