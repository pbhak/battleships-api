# frozen_string_literal: true

# Class representing the core game
class Game # rubocop:disable Metrics/ClassLength
  attr_reader :ships, :players, :board

  SHIPS = {
    carrier: 5,
    battleship: 4,
    destroyer: 3,
    submarine: 3,
    patrol_boat: 2
  }.freeze

  def initialize(players)
    # Creates a new two-dimensional array representing a 10x10 game board
    @board = Array.new(10) { Array.new(10, :empty) }
    @ships = create_ships
    @players = players
  end

  def place_ship(start_location, end_location) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    current_ship = nil
    @ships.each_value do |ship|
      if ship[:location].empty?
        current_ship = ship
        break
      end
    end

    return false if current_ship.nil?
    return false unless valid_position?(start_location, end_location, current_ship[:size])

    # Both location parameters MUST start with a letter for this to work properly
    start_col = start_location[0].ord - 96 # f5 -> 6 (f is column 6)
    end_col = end_location[0].ord - 96

    start_row = start_location[1].to_i # f5 -> 5 (row 5)
    end_row = end_location[1].to_i

    is_vertical = start_col == end_col # true if ship is to be placed vertically

    if is_vertical
      # column stays the same
      until start_row == end_row + 1
        occupy(start_col, start_row)
        @ships.each do |ship_name, ship|
          next unless ship == current_ship

          @ships[ship_name][:location] << [start_col, start_row]
          break
        end
        start_row += 1
      end
    else
      # row stays the same
      until start_col == end_col + 1
        occupy(start_col, start_row)
        @ships.each do |ship_name, ship|
          next unless ship == current_ship

          @ships[ship_name][:location] << [start_col, start_row]
          break
        end
        start_col += 1
      end
    end

    true
  end

  def attack(location) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity
    col = location[0].ord - 96
    row = location[1].to_i
    sunk = false

    return false unless col.between?(1, 10) && row.between?(1, 10)
    return false unless occupied?(col, row)

    # Find the ship that was hit
    @ships.each do |ship_name, ship|
      next unless ship[:location].include?([col, row])

      sink(col, row)
      @ships[ship_name][:hit] << [col, row]
      # Mark ship as sunk if all of its points have been hit
      if @ships[ship_name][:hit].sort == @ships[ship_name][:location].sort
        @ships[ship_name][:sunk] = true
        sunk = true
      end
      break
    end

    return :hit unless sunk

    :sunk
  end

  def to_s
    @board.each_with_index do |row, index|
      puts "#{index + 1} #{row}"
    end
  end

  # Helper functions
  def valid_position?(start_location, end_location, size) # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/PerceivedComplexity
    start_location = start_location.downcase
    end_location = end_location.downcase

    # Both location parameters MUST start with a letter for this to work properly
    start_col = start_location[0].ord - 96 # f5 -> 6 (f is column 6)
    end_col = end_location[0].ord - 96

    start_row = start_location[1].to_i # f5 -> 5 (row 5)
    end_row = end_location[1].to_i

    is_vertical = start_col == end_col

    # Start and end locations must actually exist
    unless start_col.between?(1, 10) && end_col.between?(1, 10) && start_row.between?(1, 10) && end_row.between?(1, 10)
      return false
    end

    # Start and end location must be on the same column or the same row - ships cannot be placed diagonally
    return false unless start_col == end_col || start_row == end_row

    # Distance between start and end location must match the size of the ship being placed
    return false unless [(end_row - start_row + 1), (end_col - start_col + 1)].include?(size)

    # All space between start and end must be empty
    if is_vertical
      until start_row == end_row + 1
        return false unless empty?(start_col, start_row)

        start_row += 1
      end
    else
      until start_col == end_col + 1
        return false unless empty?(start_col, start_row)

        start_col += 1
      end
    end

    true
  end

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

  def create_ships
    ships = {}
    SHIPS.each do |ship_name, ship_size|
      ships[ship_name] = {
        size: ship_size,
        sunk: false,
        location: [],
        hit: []
      }
    end
    ships
  end

  def remaining_ships
    ships_left = 0
    @ships.each_value do |ship|
      ships_left += 1 unless ship[:sunk]
    end

    ships_left
  end

  def self.convert_to_letters(location)
    "#{(location[0] + 96).chr}#{location[1]}"
  end
end
