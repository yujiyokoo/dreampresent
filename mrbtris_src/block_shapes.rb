class BlockShapes
  def self.freeze_3_levels(x)
    x.map { |shape| shape.map { |row| row.freeze } ; shape.freeze }
  end

  SQ = freeze_3_levels [
      [ [false, :yellow, :yellow], [false, :yellow, :yellow], [], [] ],
      [ [false, :yellow, :yellow], [false, :yellow, :yellow], [], [] ],
      [ [false, :yellow, :yellow], [false, :yellow, :yellow], [], [] ],
      [ [false, :yellow, :yellow], [false, :yellow, :yellow], [], [] ],
    ]

  I = freeze_3_levels [
      [ [], [:cyan, :cyan, :cyan, :cyan], [], [] ],
      [ [false, false, :cyan], [false, false, :cyan], [false, false, :cyan], [false, false, :cyan] ],
      [ [], [], [:cyan, :cyan, :cyan, :cyan], [] ],
      [ [false, :cyan], [false, :cyan], [false, :cyan], [false, :cyan] ]
    ]

  L = freeze_3_levels  [
      [ [false, false, :orange], [:orange, :orange, :orange], [], [] ],
      [ [false, :orange, false], [false, :orange, false], [false, :orange, :orange], [] ],
      [ [false, false, false], [:orange, :orange, :orange], [:orange, false, false], [] ],
      [ [:orange, :orange, false], [false, :orange, false], [false, :orange, false], [] ]
    ]

  J = freeze_3_levels [
      [ [:blue, false, false], [:blue, :blue, :blue], [], [] ],
      [ [false, :blue, :blue], [false, :blue, false], [false, :blue, false], [] ],
      [ [false, false, false], [:blue, :blue, :blue], [false, false, :blue], [] ],
      [ [false, :blue, false], [false, :blue, false], [:blue, :blue, false], [] ]
    ]

  S = freeze_3_levels [
      [ [false, :green, :green], [:green, :green, false], [], [] ],
      [ [false, :green, false], [false, :green, :green], [false, false, :green], [] ],
      [ [false, false, false], [false, :green, :green], [:green, :green, false], [] ],
      [ [:green, false, false], [:green, :green, false], [false, :green, false], [] ]
    ]

  Z = freeze_3_levels [
      [ [:red, :red, false], [false, :red, :red], [], [] ],
      [ [false, false, :red], [false, :red, :red], [false, :red, false], [] ],
      [ [false, false, false], [:red, :red, false], [false, :red, :red], [] ],
      [ [false, :red, false], [:red, :red, false], [:red, false, false], [] ]
    ]

  T = freeze_3_levels [
      [ [false, :purple, false], [:purple, :purple, :purple], [], [] ],
      [ [false, :purple, false], [false, :purple, :purple], [false, :purple, false], [] ],
      [ [false, false, false], [:purple, :purple, :purple], [false, :purple, false], [] ],
      [ [false, :purple, false], [:purple, :purple, false], [false, :purple, false], [] ]
    ]

  def self.colour_to_rgb(colour)
    case colour
    when :grey
      [192, 192, 192]
    when :cyan
      [0, 192, 192]
    when :yellow
      [192, 192, 0]
    when :purple
      [128, 0, 128]
    when :green
      [0, 128, 0]
    when :red
      [255, 0, 0]
    when :blue
      [0, 0, 255]
    when :orange
      [255, 165, 0]
    else
      [0, 0, 0]
    end
  end

  def self.random_shape
    candidates = [SQ, I, L, J, S, Z, T]

    candidates[rand(candidates.size)]
  end
end
