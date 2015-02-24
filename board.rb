require 'yaml'
require 'byebug'

class Board

  PERMUTATIONS = [[-1,-1],[-1,0],[-1,1],[0,1],[0,-1],[1,-1],[1,0],[1,1]]

  def initialize(x = 9, y = 9, bombs = 10)
    @board_x_size = x
    @board_y_size = y
    @bombs = bombs
    @game_board = []
    blank_board
    fill_with_bombs
    populate_neighbors
  end


  def any?(&condition)
    @game_board.any? do |row|
      row.any? do |tile|
        condition.call(tile)
      end
    end
  end

  def all?(&condition)
    @game_board.all? do |row|
      row.all? do |tile|
        condition.call(tile)
      end
    end
  end

  def reveal(pos)
    tile = @game_board[pos[0]][pos[1]]
    tile.revealed = true
    if tile.neighbor_bomb_count == 0
      tile.neighbors.each do |neighbor|
        unless neighbor.revealed
          reveal(neighbor.position)
        end
      end
    end
  end

  def flag(pos)
    tile = @game_board[pos[0]][pos[1]]
    tile.flagged = !tile.flagged unless tile.revealed
  end

  def won?
    all? { |tile| tile.bomb ? !tile.revealed : tile.revealed }
  end

  def dead?
    any?{ |tile| tile.revealed && tile.bomb }
  end

  def over?
    won? || dead?
  end

  def blank_board
    @board_y_size.times do
      @game_board << []
    end
    @board_y_size.times do |row|
      @board_x_size.times do |column|
        @game_board[row][column] = Tile.new(false, [row,column])
      end
    end
  end

  def random_bomb_locations
    num_tiles = @board_x_size * @board_y_size
    locations = (0..num_tiles-1).to_a.sample(@bombs)
    coordinates = []
    locations.each do |location|
      r = location % @board_x_size
      c = location / @board_x_size
      # x = rand(self.x_dimension)
      coordinates << [r,c]
    end
    coordinates
  end

  def fill_with_bombs
    random_bomb_locations.each do |coordinate|
      @game_board[coordinate[0]][coordinate[1]].bomb = true
    end
  end

  def populate_neighbors
    @board_y_size.times do |row|
      @board_x_size.times do |col|
        neighbor_coord = get_neighbor_positions([row,col])
        neighbor_coord.each do |coord|
          @game_board[row][col].add_neighbor(@game_board[coord[0]][coord[1]])
        end
      end
    end
  end

  def get_neighbor_positions(pos)
    neighbors = []
    PERMUTATIONS.each do |permutation|
      row = pos.first + permutation.first
      col = pos.last + permutation.last
      if in_range?([row,col])
        neighbors << [row,col]
      end
    end
    neighbors
  end

  def in_range?(pos)
    row, col = pos
    col < @board_x_size && col >= 0 && row < @board_y_size && row >= 0
  end

  def display
    puts render_board
  end

  def render_board
    board = ""

    @game_board.each_with_index do |row, index|
      board += " " if index < 10
      board += index.to_s + "|  "
      row.each do |tile|
        board += tile.inspect + " "
      end
      board += "\n"
    end
    board += "_" * (@board_x_size * 2 + 4) + "\n"
    board += "  |  " + (0..@board_x_size-1).to_a.map{ | x | x / 10}.join(" ")
    board += "\n"
    board += "  |  " + (0..@board_x_size-1).to_a.map{ | x | x % 10}.join(" ")
    board
  end
end
