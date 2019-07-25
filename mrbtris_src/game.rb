class BoardState
  attr_accessor :x, :y

  attr_reader :board, :shape, :shape_orientation, :next_shape, :score

  def initialize(x, y, screen)
    @x, @y = x, y
    @screen = screen
    @last_x, @last_y = 0, 0
    @board = new_empty_board
    @next_shape = BlockShapes.random_shape
    @shape = BlockShapes.random_shape
    @shape_orientation, @last_shape_orientation = 0, 0
    @score = 0
  end

  LEFT_AND_RIGHT_BLOCKS = ([:grey] + [false] * 10 + [:grey]).freeze
  HORIZONTAL_WALL = ([:grey]*12).freeze

  # note that board starts from -1 to allow easy comparison when block gets to the left all
  EMPTY_BOARD =
    [ HORIZONTAL_WALL ] +
    [ LEFT_AND_RIGHT_BLOCKS ] * 20 +
    [ HORIZONTAL_WALL ].freeze

  def new_empty_board
    new_board = Array.new

    EMPTY_BOARD.each { |row|
      new_board.push row.compact # compact simply copies if no nil present
    }

    new_board
  end

  def full_row_idxs
    idxs = []
    (1..20).each {|idx|
      if @board[idx].reduce {|a,b| a&&b}
        idxs << idx
      end
    }
    idxs
  end

  def clear_full_rows
    fr_idxs = full_row_idxs
    fr_idxs.each { |i|
      @board.delete_at(i)
      @board.insert(1, LEFT_AND_RIGHT_BLOCKS.compact) # compact simply copies if no nil present
    }
    scores = [0, 1, 2, 3, 8]
    @score += scores[fr_idxs.size]
  end

  def save_to_board
    @shape[@shape_orientation].each_with_index { |row, rownum|
      row.each_with_index { |cell, colnum|
        @board[@y+rownum][@x+colnum] = cell if cell
      }
    }
  end

  def next_orientation(orientation)
    (orientation + 1) % 4
  end

  def previous_orientation(orientation)
    (orientation + 3) % 4
  end

  def clockwise
    @shape_orientation = next_orientation(@shape_orientation) if can_rotate_cw?
  end

  def anticlockwise
    @shape_orientation = previous_orientation(@shape_orientation) if can_rotate_anticw?
  end

  def zero_if_negative(x)
    if x < 0 ; 0 ; else ; x ; end
  end

  def board_section_for(x, y, horizontal_shift, vertical_shift)
    original_left = x + horizontal_shift
    adjusted_left = zero_if_negative(original_left)
    right = original_left + 3
    top = (y + vertical_shift)

    left_outside_area = if original_left < 0
      [false] * [(0-original_left), 4].min
    else
      []
    end

    right_outside_area = if right > 11
      [false] * [(right-11), 4].min
    else
      []
    end

    [
      (row(top, adjusted_left, right, left_outside_area, right_outside_area)),
      (row(top+1, adjusted_left, right, left_outside_area, right_outside_area)),
      (row(top+2, adjusted_left, right, left_outside_area, right_outside_area)),
      (row(top+3, adjusted_left, right, left_outside_area, right_outside_area))
    ]
  end

  private
  def row(row_idx, l, r, left_outside_area, right_outside_area)
    if row_idx < 0 || row_idx >= @board.size || r < 0 || l > 11
      [false, false, false, false]
    else
      left_outside_area + Array(@board[row_idx][l..r]) + right_outside_area
    end
  end

  public
  def can_rotate_cw?
    board_section = board_section_for(@x, @y, 0, 0)
    next_shape = @shape[next_orientation(@shape_orientation)]
    !collides?(board_section, next_shape)
  end

  def can_rotate_anticw?
    board_section = board_section_for(@x, @y, 0, 0)
    previous_shape = @shape[previous_orientation(@shape_orientation)]
    !collides?(board_section, previous_shape)
  end

  def move_left
    @x -= 1 if can_go_left?
  end

  def can_go_left?
    board_section = board_section_for(@x, @y, -1, 0)
    !collides?(board_section, @shape[@shape_orientation])
  end

  def collides?(board_section, block)
    board_section
      .zip(block)
      .map{|a,b| a.zip(b)}
      .flatten(1)
      .map {|a, b| a&&b}
      .reduce {|a,b| a||b}
  end

  def move_right
    @x += 1 if can_go_right?
  end

  def can_go_right?
    board_section = board_section_for(@x, @y, 1, 0)
    !collides?(board_section, @shape[@shape_orientation])
  end

  def move_down
    @y += 1 if can_drop?
  end

  def move_down!
    @y += 1
  end

  def can_drop?
    board_section = board_section_for(@x, @y, 0, 1)
    !collides?(board_section, @shape[@shape_orientation])
  end

  def save_current_position
    @last_x = @x
    @last_y = @y
    @last_shape_orientation = @shape_orientation
  end

  def moved_horizontal?
    @last_x != @x
  end

  def moved_vertical?
    @last_y != @y
  end

  def rotated?
    @last_shape_orientation != @shape_orientation
  end

  def moved?
    @last_x != @x || @last_y != @y
  end

  # TODO: should be on Screen?
  def render_if_moved
    if moved? || rotated?
      erase_last_pos
      @shape[@shape_orientation].each_with_index { |row, rownum|
        row.each_with_index { |cell, colnum|
          @screen.draw_colour_square(@x+colnum, @y+rownum, cell, false) if cell
        }
      }
    end
  end

  def erase_last_pos
    @shape[@last_shape_orientation].each_with_index { |row, rownum|
      row.each_with_index { |cell, colnum|
        @screen.draw_black_square(@last_x+colnum, @last_y+rownum, false) if cell
      }
    }
  end

  def next_block(x, y)
    @x, @y = x, y
    @last_x, @last_y = 0, 0
    @shape = @next_shape
    @next_shape = BlockShapes.random_shape
    @shape_orientation = 0
  end
end

class Screen
  LEFT_SPACE_PX=260
  TOP_SPACE_PX=20

  attr_reader :dc2d

  def initialize(dc2d)
    @dc2d = dc2d
  end

  def render_score(board_state)
    @dc2d::render_score(board_state.score)
  end

  def render_upcoming_block_pane(board_state)
    normalised_next_shape = make_4x4(board_state.next_shape[0])
    normalised_next_shape.each_with_index { |row, rownum|
      row.each_with_index { |cell, colnum|
        if cell
          draw_colour_square(colnum + 14, rownum + 2, cell, true)
        else
          draw_black_square(colnum + 14, rownum + 2, true)
        end
      }
    }
  end

  def make_4x4(shape)
    shape.map { |row| row + [false] * (4 - row.size) }
  end

  def draw_square(x, y, r, g, b, ignore_boundary)
    if (x > 0 && x < 11 && y > 0 && y < 21) || ignore_boundary
      @dc2d::draw20x20_640(x*20+LEFT_SPACE_PX, y*20+TOP_SPACE_PX, r, g, b)
    end
  end

  def draw_colour_square(x, y, colour, ignore_boundary)
    draw_square(x, y, *(BlockShapes.colour_to_rgb colour), ignore_boundary)
  end

  def draw_black_square(x, y, ignore_boundary)
    draw_square(x, y, 0, 0, 0, ignore_boundary)
  end

  def draw_board(board)
    board.each_with_index { |row, y|
      row.each_with_index { |cell, x|
        if cell
          draw_colour_square(x, y, cell, true)
        else
          draw_black_square(x, y, true)
        end
      }
    }
  end
end

class GameState
  FPS = 50

  attr_accessor :frame, :tick, :curr_wait, :ticks_since_wait_change, :last_button_state, :button_state_unchanged_for, :board_state

  def initialize(screen, board_state_class)
    @screen = screen
    @board_state_class = board_state_class
    reset
  end

  def reset
    @frame = 0
    @tick = 0
    @curr_wait = 10
    @ticks_since_wait_change = 0
    @last_button_state = 0
    @button_state_unchanged_for = 0
    @board_state = @board_state_class.new(4, 1, @screen)
  end

  def increment_frame
    @frame = (@frame + 1) % FPS
  end

  def update_board_for_button_state
    dc2d = @screen.dc2d
    button_state = dc2d.get_button_state

    if @last_button_state == button_state
      @button_state_unchanged_for += 1
    else
      @button_state_unchanged_for = 0
    end

    if button_state
      unless (@board_state.moved_horizontal? || @board_state.rotated?)
        @board_state.move_left if dc2d.dpad_left?(button_state) && first_press_or_held_long
        @board_state.move_right if dc2d.dpad_right?(button_state) && first_press_or_held_long
        @board_state.clockwise if dc2d.btn_a?(button_state) && first_press_or_held_long
        @board_state.anticlockwise if dc2d.btn_b?(button_state) && first_press_or_held_long
      end

      unless @board_state.moved_vertical?
        @board_state.move_down if dc2d.dpad_down?(button_state)
      end
    end

    @last_button_state = button_state
  end

  # TODO: state changes need to be tracked per button.
  # This method faild to track 'up' press if you press b while you keep dpad up pressed
  def first_press_or_held_long
    @button_state_unchanged_for == 0 || @button_state_unchanged_for > 9
  end

  def board
    @board_state.board
  end
end

class MainGame
  SOLID_BOARD_BEFORE_START = ([].push [:grey] * 12) * 22

  def initialize(screen, dc2d)
    @dc2d = dc2d
    @screen = screen.new(@dc2d)
    @game_state = GameState.new(@screen, BoardState)
  end

  def wait_for_start_button
    while true do
      rand(1) # hopefully this would give us a "more random" start point
      button_state = @dc2d::get_button_state

      break if button_state && @dc2d::start_btn?(button_state)
    end
  end

  def main_loop
    @dc2d::clear_score(@score)

    while true do # 'main loop'
      @screen.draw_board(SOLID_BOARD_BEFORE_START)

      wait_for_start_button
      running = true

      @game_state.reset

      @screen.draw_board(@game_state.board)
      @screen.render_upcoming_block_pane(@game_state.board_state)
      @screen.render_score(@game_state.board_state)

      while running do
        # for the moment, let's assume this gives us 50hz...
        @dc2d::waitvbl
        @game_state.increment_frame

        # even if update doesn't happen, input should be recorded every frame

        @game_state.update_board_for_button_state

        next unless (@game_state.frame % 3) == 0

        @game_state.board_state.render_if_moved

        @game_state.board_state.save_current_position

        @game_state.tick = (@game_state.tick + 1) % @game_state.curr_wait
        next unless @game_state.tick == 0

        @game_state.ticks_since_wait_change += 1
        if @game_state.ticks_since_wait_change >= 30
          @game_state.curr_wait -= 1 unless @game_state.curr_wait == 1
          @game_state.ticks_since_wait_change = 0
        end

        if @game_state.board_state.can_drop?
          @game_state.board_state.move_down
        else
          @game_state.board_state.save_to_board
          @game_state.board_state.clear_full_rows
          @screen.draw_board(@game_state.board_state.board)

          @game_state.board_state.next_block(4, 0)
          running = false unless @game_state.board_state.can_drop?
          @game_state.board_state.move_down!

          @screen.render_upcoming_block_pane(@game_state.board_state)
          @screen.render_score(@game_state.board_state)
        end
      end
    end
  end
end
