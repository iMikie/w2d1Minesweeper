class Tile
  attr_accessor :position, :bomb, :flagged, :revealed, :neighbors

  def initialize(bomb, position)
    @revealed = false
    @flagged = false
    @bomb  = bomb
    @position = position
    @neighbors = []
  end

  def neighbor_bomb_count
    count = 0
    @neighbors.each do |neighbor|
      count += 1 if neighbor.bomb
    end
    count
  end

  def add_neighbor(tile)
    @neighbors << tile
  end

  def inspect
    if revealed
      if bomb
        return 'B'
      elsif neighbor_bomb_count == 0
        return '_'
      else
        neighbor_bomb_count.to_s
      end
    else
      if flagged
        return 'F'
      else
        return '*'
      end
    end
  end
end
