# frozen_string_literal: true

# Player class
class Player
  attr_reader :id, :name
  attr_accessor :game_id

  def initialize(name = nil)
    @id = rand(10..99)
    @game_id = nil
    @name = name
  end
end
