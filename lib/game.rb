# frozen_string_literal: true

# Class representing the core game
class Game
  SHIP_LENGTHS = [5].freeze

  def initialize
    # Creates a new two-dimensional array representing a 10x10 game board
    @board = Array.new(10) { Array.new(10, :empty) }
  end

  # def place_ships

  def to_s
    @board.each_with_index do |row, index|
      puts "#{index + 1} #{row}"
    end
  end

  # Helper functions
  def empty?(col, row)
    @board[row - 1][col - 1] == :empty
  end

  def occupied?(col, row)
    @board[row - 1][col - 1] == :occupied
  end

  def sunk?(col, row)
    @board[row - 1][col - 1] == :sunk
  end

  def occupy(col, row)
    @board[row - 1][col - 1] = :occupied
  end

  def sink(col, row)
    @board[row - 1][col - 1] = :sunk
  end

  def random_pos
    [rand(1..10), rand(1..10)]
  end

  # TODO: create segment to add or randomize ship positions on board
  # TODO: create turn loop and win/lose conditions
end

x = Game.new

x.place_ships
puts x