# frozen_string_literal: true

# Class representing the core game
class Game
  SHIP_LENGTHS = [5, 4, 3, 3, 2].freeze

  def initialize
    # Creates a new two-dimensional array representing a 10x10 game board
    # Each position can be 0 for empty, 1 for occupied, or 2 for sunk
    @board = Array.new(10) { Array.new(10, 0) }
  end

  # Get board position as a ranging from (1,1) to (10,10)
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


  # TODO: create segment to add or randomize ship positions on board
  # TODO: create turn loop and win/lose conditions
end

x = Game.new

p x.get_coordinate(1, 1)
