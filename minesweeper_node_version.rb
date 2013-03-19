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
      node.add_neighbors(@board_size, @board_nodes)
    end
  end

  def set_bombs_near
    @board_nodes.each do |node|
      num_bombs = 0
      node.neighbors.each do |node|
        num_bombs += 1 if node.bomb
      end
      node.bombs_near = num_bombs
    end
  end

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

  def reveal_spaces(node)
    nodes = bfs(node)
    nodes.each do |node|
      #debugger
      neighbors = node.neighbors
      reveal_neighbors(neighbors)
    end
  end

  def bfs(node)
    visited = []
    nodes = []
    que = [node]
    while que.count > 0
      current_node = que.shift
      neighbors = current_node.neighbors
      visited << current_node
      #debugger
      if no_bombs?(neighbors)
        nodes << current_node
        neighbors.each do |neighbor|
          que << neighbor unless visited.include?(neighbor)
          visited << neighbor
        end
      end
    end
    #debugger
    return nodes
  end

  def reveal_neighbors(neighbors)
    neighbors.each do |neighbor|
      neighbor.revealed = true
    end
  end

  def no_bombs?(neighbors)
    #debugger
    neighbors.each do |neighbor|
      return false if neighbor.bomb
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

  def is_bomb?(node)
    return true if node.bomb
    false
  end

  def win?
    return true if @spaces_cleared  >= @board_size**2 - 10
  end

  def clear_space_count
    @spaces_cleared = 0
    count = 0
    @board_nodes.each do |node| 
      if node.revealed
        count += 1 
      end
    end
    @spaces_cleared = count
  end

  def set_status(state, position)
    if state == "f"
      @board_nodes[position].flag = true
    else
      @board_nodes[position].revealed = true
    end
  end

  def set_bombs(num_bombs)
    @board_nodes.sample(num_bombs).each do |node|
      node.add_bomb
    end
  end

  def play
    set_bombs(10)
    set_bombs_near
    game_over = false

    until game_over
      system('clear')
      calc_display_board
      input = get_user_decision
      if is_bomb?(@board_nodes[input[1]])
        puts "BOMB!"
        break
      end
      set_status(input[0], input[1])
      #debugger
      reveal_spaces(@board_nodes[input[1]])
      clear_space_count
      if win?
        puts "You win!"
        break
      end
    end
  end

end

class BoardNode
  attr_accessor :neighbors, :bomb, :flag, :position, :revealed, :bombs_near, :perp_neighbors

  def initialize(position)
    @neighbors = []
    @perp_neighbors = []
    @bomb = false
    @flag = false
    @revealed = false
    @bombs_near = nil
    @position = position
  end

  def add_bomb
    self.bomb = true
  end

  def display
    return "F" if @flag
    return "@" if @bomb
    return "_" if @revealed
    @perp_neighbors.each do |neighbor|
      return @bombs_near if neighbor.revealed
    end
    return "*"
  end

  def add_neighbors(board_size, board_nodes)
    perp_positions = [@position - 1, @position + 1,  @position - board_size,@position + board_size]
    all_positions = [@position - board_size - 1, @position - board_size + 1, @position + board_size - 1, @position + board_size + 1] + perp_positions     

    all_positions = no_top_edge(board_size, all_positions, perp_positions)
    all_positions = no_bottom_edge(board_size, all_positions, perp_positions)
    all_positions = no_left_edge(board_size, all_positions, perp_positions)
    all_positions = no_right_edge(board_size, all_positions, perp_positions)
    all_positions.each do |position|
      @neighbors << board_nodes[position]
    end
    perp_positions.each do |position|
      @perp_neighbors << board_nodes[position]
    end
  end

  def no_top_edge(board_size, all_positions, perp_positions)
    if @position / board_size == 0
      all_positions -= [@position - board_size - 1, @position - board_size, @position - board_size + 1]
      perp_positions.delete(@position - board_size) 
      #puts "delete bottom edge! #{[@position - board_size - 1, @position - board_size, @position - board_size + 1]}"
    end
    all_positions
  end

  def no_bottom_edge(board_size, all_positions, perp_positions)
    if @position / board_size == board_size - 1
      all_positions -= [@position + board_size - 1, @position + board_size, @position + board_size + 1]
      perp_positions.delete(@position + board_size) 
      #puts "delete bottom edge! #{[@position + board_size - 1, @position + board_size, @position + board_size + 1]}"
    end
    all_positions
  end

  def no_left_edge(board_size, all_positions, perp_positions)
    if @position % board_size == 0
      all_positions -= [@position - 1, @position - board_size - 1,@position + board_size - 1]
      perp_positions.delete(@position - 1) 
      #puts "delete left edge! #{[@position - 1, @position_board_size + 1, @position + board_size + 1]}"
    end
    all_positions
  end

  def no_right_edge(board_size, all_positions, perp_positions)
    if @position % board_size == board_size - 1
      all_positions -= [@position + 1, @position - board_size + 1, @position + board_size + 1]
      perp_positions.delete(@position + 1)
      #puts "delete right edge! #{[@position + 1, @position - board_size - 1, @position + board_size - 1]}"
    end
    all_positions
  end
end

mines = Minesweeper.new(9)

mines.play






