require 'debugger'
class Minesweeper
  attr_accessor :board_size, :board_nodes, :display_board, :spaces_cleared

  def initialize(board_size)
    @spaces_cleared = 0
    @board_size = board_size
    @board_nodes = []
    @display_board = ""
    (@board_size ** 2).times do |position|
      @board_nodes << BoardNode.new(position)
    end
    @board_nodes.each do |node|
      node.add_neighbors(@board_size)
    end

  end
  # since you're recalculating display board each time, doesn't seem
  # necessary to have a @display_board instance variable. Just call
  # the calc function when you want to display it
  def calc_display_board
    #display_board = Array.new(@board_size, Array.new(@board_size, '*'))
    @display_board = ""
    board = []
    position = 0
    @board_size.times do |row|
      board_row = []
      @board_size.times do |col|
        board_row << @board_nodes[position].display

        # "position is #{position} display is #{@board_nodes[position].bomb}"
        position += 1
      end
      board << board_row
    end
    board.each_with_index do |row, index|
      @display_board += "board row #{index}: #{row}\n"
    end
    display_board
  end

  def display_board
    system('clear')
    puts @display_board
  end

  def reveal_spaces(position)
    #debugger
    #puts "in reveal_spaces position is #{@board_nodes[position].position}"
    neighbors = @board_nodes[position].neighbors

    #puts "neighbors are #{neighbors}"

      if no_bombs?(neighbors)
        reveal_neighbors(neighbors)
      end
  end

  # def neighbors_not_revealed(n)
  #   unrevealed = []
  #   @board_nodes[position].neighbors.each do |neighbor|
  #     unless @board_nodes[neighbor].revealed
  #       unrevealed << neighbor
  #     end
  #   end
  #   puts "#{unrevealed}"
  # end

  def reveal_neighbors(neighbors)
    neighbors.each do |neighbor|
      @board_nodes[neighbor].revealed = true
      @spaces_cleared +=1
    end
  end
  # it's a bit odd to have a validation that checks for not having something
  # I would reverse the logic here
  def no_bombs?(neighbors)
    neighbors.each do |neighbor|
      return false if @board_nodes[neighbor].bomb
    end
    true
  end

  def get_user_decision
    puts "spaces cleared = #{@spaces_cleared}"
    puts "Enter state and coordinate f/r (x y): "
    input = gets.chomp.split(" ")
    #debugger
    state = input[0]
    x = input[1].to_i
    y = input[2].to_i
    position = (x * @board_size) + y
    [state, position]
  end
  # don't need the 'return true here'. just write the condition "@board_nodes..."
  def is_bomb?(position)
    return true if @board_nodes[position].bomb
    false
  end
  # same as above
  def win?
    return true if @spaces_cleared  >= @board_size**2 - 10
  end

  def set_status(state, position)
    if state == "f"
      @board_nodes[position].flag = true
    else
      @board_nodes[position].revealed = true
      @spaces_cleared += 1
    end
  end

  def set_bombs(num_bombs)
    @board_nodes.sample(num_bombs).each do |node|
      node.add_bomb
    end
  end

  def play
    set_bombs(10)
    game_over = false

    until game_over
      system('clear')
      calc_display_board
      input = get_user_decision
      if is_bomb?(input[1])
        puts "BOMB!"
        break
      end
      set_status(input[0], input[1])
      reveal_spaces(input[1])
      if win?
        puts "You win!"
        break
      end
    end
  end
# watch the spurious white space
end

class BoardNode
  attr_accessor :neighbors, :bomb, :flag, :position, :revealed

  def initialize(position)
    @neighbors = []
    @bomb = false
    @flag = false
    @revealed = false
    @position = position
  end

  def add_bomb
    self.bomb = true
  end

  def display
    return "F" if @flag
    return "@" if @bomb
    return "_" if @revealed
    return "*"
  end

  def add_neighbors(board_size)
    # not following what's going on here. why are you resetting the same variable
    # so many times?
    all_positions = [@position - board_size - 1, @position - board_size,
                    @position - board_size + 1, @position - 1,
                    @position + 1, @position + board_size - 1,
                    @position + board_size, @position + board_size + 1]
    #puts "all_possitions #{all_positions}"

    all_positions = no_top_edge(board_size, all_positions)
    all_positions = no_bottom_edge(board_size, all_positions)
    all_positions = no_left_edge(board_size, all_positions)
    all_positions = no_right_edge(board_size, all_positions)
    # all_positions.each do |position|
    #   @neighbors << board_nodes[position]
    # end
    @neighbors = all_positions
  end

  def no_top_edge(board_size, all_positions)
    if @position / board_size == 0
      all_positions -= [@position - board_size - 1, @position - board_size, @position - board_size + 1]
      #puts "delete bottom edge! #{[@position - board_size - 1, @position - board_size, @position - board_size + 1]}"
    end
    all_positions
  end

  def no_bottom_edge(board_size, all_positions)
    if @position / board_size == board_size - 1
      all_positions -= [@position + board_size - 1, @position + board_size, @position + board_size + 1]
      #puts "delete bottom edge! #{[@position + board_size - 1, @position + board_size, @position + board_size + 1]}"
    end
    all_positions
  end

  def no_left_edge(board_size, all_positions)
    if @position % board_size == 0
      all_positions -= [@position - 1, @position - board_size - 1,@position + board_size - 1]
      #puts "delete left edge! #{[@position - 1, @position_board_size + 1, @position + board_size + 1]}"
    end
    all_positions
  end

  def no_right_edge(board_size, all_positions)
    if @position % board_size == board_size - 1
      all_positions -= [@position + 1, @position - board_size + 1, @position + board_size + 1]
      #puts "delete right edge! #{[@position + 1, @position - board_size - 1, @position + board_size - 1]}"
    end
    all_positions
  end
end

mines = Minesweeper.new(9)
# mines.board_nodes[4].neighbors.each do |node|
#   puts "neighbor is #{node.position}"
# end
mines.play

#
# board_nodes = []
#
# pos = 20
#
# 81.times do |position|
#   board_nodes << BoardNode.new(position)
# end
#
# board_nodes[pos].add_neighbors(9, board_nodes)
#
# board_nodes[pos].neighbors
#
# board_nodes[pos].neighbors.each do |node|
#   puts "Node position is #{node.position}."
# end





