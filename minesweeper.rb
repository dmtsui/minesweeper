class BoardNode
  attr_accessor :neighbors, :bomb, :position

  def initialize(position)
    @neighbors = []
    @bomb = false
    @position = position
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

board_nodes = []

pos = 20

81.times do |position|
  board_nodes << BoardNode.new(position)
end

board_nodes[pos].add_neighbors(9, board_nodes)

board_nodes[pos].neighbors

board_nodes[pos].neighbors.each do |node|
  puts "Node position is #{node.position}."
end





