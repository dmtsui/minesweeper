class Minesweeper
  attr_accessor :board_size, :board_nodes, :display_board

  def initialize(board_size)
    @board_size = board_size
    @board_nodes = []
    @display_board = ""
    (@board_size ** 2).times do |position|
      @board_nodes << BoardNode.new(position)
    end
  end

  def calc_display_board
    #display_board = Array.new(@board_size, Array.new(@board_size, '*'))
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
  end

  def display_board
    puts @display_board
  end

  def get_user_position
    puts "Enter coordinate (x y): "
    input = gets.chomp.split(" ")
    x = input[0].to_i
    y = input[1].to_i
    position = ((x / @board_size) * @board_size) + y
  end

  def set_status(state)
    position = get_user_position
    @board_nodes[position].state = true
  end

  # def set_revealed
  #   position = get_user_position
  #   @board_nodes[position].revealed = true
  # end

  def set_bombs(num_bombs)
    @board_nodes.sample(num_bombs).each do |node|
      node.add_bomb
    end
  end

  def play
    set_bombs(10)
    calc_display_board
    # @board_nodes.each do |node|
    #   if node.bomb
    #     puts "bomb at node #{node.position} #{node.display}"
    #   end
    # end
    display_board
  end

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
    return " " if @revealed
    return "*"
  end

  def add_neighbors(board_size, board_nodes)
    all_positions = [@position - board_size - 1, @position - board_size,
                    @position - board_size + 1, @position - 1,
                    @position + 1, @position + board_size - 1,
                    @position + board_size, @position + board_size + 1]
    #puts "all_possitions #{all_positions}"

    all_positions = no_top_edge(board_size, board_nodes, all_positions)
    all_positions = no_bottom_edge(board_size, board_nodes, all_positions)
    all_positions = no_left_edge(board_size, board_nodes, all_positions)
    all_positions = no_right_edge(board_size, board_nodes, all_positions)
    all_positions.each do |position|
      @neighbors << board_nodes[position]
    end
  end

  def no_top_edge(board_size, board_nodes, all_positions)
    if @position / board_size == 0
      all_positions -= [@position - board_size - 1, @position - board_size, @position - board_size + 1]
      #puts "delete bottom edge! #{[@position - board_size - 1, @position - board_size, @position - board_size + 1]}"
    end
    all_positions
  end

  def no_bottom_edge(board_size, board_nodes, all_positions)
    if @position / board_size == board_size - 1
      all_positions -= [@position + board_size - 1, @position + board_size, @position + board_size + 1]
      #puts "delete bottom edge! #{[@position + board_size - 1, @position + board_size, @position + board_size + 1]}"
    end
    all_positions
  end

  def no_left_edge(board_size, board_nodes, all_positions)
    if @position % board_size == 0
      all_positions -= [@position - 1, @position - board_size - 1,@position + board_size - 1]
      #puts "delete left edge! #{[@position - 1, @position_board_size + 1, @position + board_size + 1]}"
    end
    all_positions
  end

  def no_right_edge(board_size, board_nodes, all_positions)
    if @position % board_size == board_size - 1
      all_positions -= [@position + 1, @position - board_size + 1, @position + board_size + 1]
      #puts "delete right edge! #{[@position + 1, @position - board_size - 1, @position + board_size - 1]}"
    end
    all_positions
  end
end

mines = Minesweeper.new(9)
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





