# frozen_string_literal: true

# Player class
class Player
  attr_reader :id, :name
  attr_accessor :game_id, :turn, :opponent

  def initialize(players, name = nil)
    @id = rand(1000..9999)
    if players.map(&:id).include?(@id)
      raise('Max players reached') if players.length == 1800

      @id = rand(1000..9999) while players.map(&:id).include?(@id)
    end
    @name = name
  end
end
