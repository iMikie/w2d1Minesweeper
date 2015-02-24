load './board.rb'
load './tile.rb'

class Game
  def initialize
  end

  # def print_instructions
  #
  # end

  def load_or_new_game
    while true
      puts "Play minesweeper! To start a new game, enter 'N'"
      puts "  or enter 'L' to load a previously saved game"
      input = gets.chomp
      case input
      when 'N'
        @board = Board.new
        break
      when 'L'
        @board = YAML::load(File.read('SavedGame.yml'))
        break
      else
        "INVALID INPUT"
      end
    end
  end

  def play
    load_or_new_game
    @board.display
    until @board.over?
      input = get_user_input
      case input[0]
      when 'r'
        @board.reveal(input[1])
      when 'f'
        @board.flag(input[1])
      when 'q'
        break
      when 's'
        File.open('SavedGame.yml', 'w') do |f|
          f.puts @board.to_yaml
        end
        break
      end

      @board.display
    end

    if @board.dead?
      puts "YOU EXPLODED!"
    elsif @board.won?
      puts "Good job! You did it in time"
    else
      puts "you quit or saved it"
    end
  end

  def get_user_input
    valid_inputs = ['r', 'f', 'q', 's']
    while true
      puts "Enter move (r 2,3): "
      input = gets.chomp
      if input =~ /\A[rfqs]\s\d\d?[,]\d\d?\z/
        move, coord = input.split(' ')
        coord = coord.split(',').map(&:to_i)
        if coord[0] < Board::BOARD_X_SIZE && coord[1] < Board::BOARD_Y_SIZE
          return [move, coord]
        end
      else
        return input if valid_inputs.include?(input)

        puts "INVALID INPUT"
      end
    end
  end
end
