# frozen_string_literal: true

# Class representing the core game
class Game
  SHIP_LENGTHS = [5, 4, 3, 3, 2].freeze

  def initialize
    # Creates a new two-dimensional array representing a 10x10 game board
    # Each position can be 0 for empty, 1 for occupied, or 2 for sunk
    @board = Array.new(10) { Array.new(10, 0) }
  end

  # Get position on board given a range from (1,1) to (10,10)
  def get_coordinate(board_x, board_y)
    @board[board_x - 1][board_y - 1]
  end

  # Place a ship onto a coordinate on the grid, but only if that coordinate is not already marked as sunk
  def occupy(board_x, board_y)
    @board[board_x - 1][board_y - 1] == 2 ? return : @board[board_x - 1][board_y - 1] = 1
  end

  # Sink a ship on the coordinate grid, return if the coordinate is marked empty
  def sink(board_x, board_y)
    @board[board_x - 1][board_y - 1].zero? ? return : @board[board_x - 1][board_y - 1] = 2
  end

  def place_ships
    SHIP_LENGTHS.each do |ship_size|
      placed = false
      # Randomly decide whether or not the ship will be placed vertically
      is_ship_vertical = [true, false].sample

      until placed
        # Get a random empty square on the board - if the square is not empty, repeat until it is
        rand_x, rand_y = rand(1..10), rand(1..10) 
        rand_x, rand_y = rand(1..10), rand(1..10) until get_coordinate(rand_x, rand_y).zero?

        puts "(#{rand_x - 1}, #{rand_y - 1}) = #{get_coordinate(rand_x, rand_y)} for ship size #{ship_size}"
      end
    end
  end

  # TODO: create segment to add or randomize ship positions on board
  # TODO: create turn loop and win/lose conditions
end

x = Game.new

x.place_ships
