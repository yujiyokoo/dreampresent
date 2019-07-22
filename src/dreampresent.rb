class Dreampresent
  attr_reader :dc_cos

  def initialize(dc_kos)
    @dc_kos = dc_kos
  end

  def start
    puts "Dreampresent: starting"
    Presentation.new(@dc_kos,
      PageData.new(@dc_kos, Time.now).all
    ).run
  end
end
