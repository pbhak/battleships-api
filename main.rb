# frozen_string_literal: true

require 'sinatra'
require_relative 'lib/game'
require_relative 'lib/player'

games = {}
players = []

set :port, 43357 # rubocop:disable Style/NumericLiterals
set :environment, 'production'
# set :environment, 'development'

before do
  content_type 'application/json'
  if request.body.read.empty?
    @request_body = {}
    return
  end
  request.body.rewind
  @request_body = JSON.parse(request.body.read)
end

error 500 do
  JSON.generate(
    { 
      error: '500 Internal Server Error', 
      message: env['sinatra.error'].message 
    }
  )
end

error 400 do
  JSON.generate(
    {
      error: '400 Bad Request',
      message: 'Invalid request'
    }
  )
end

not_found do
  'Not Found'
end

post '/newplayer' do
  players << (params['name'].nil? ? Player.new(players) : Player.new(players, params['name']))

  JSON.generate(
    {
      id: players[-1].id,
      name: players[-1].name,
      message: 'New player created'
    }
  )
end

post '/newgame' do
  halt 400 if @request_body['players'].nil?
  halt 400 unless @request_body['players'].length == 2
  unless players.map(&:id).include?(@request_body['players'][0]) && players.map(&:id).include?(@request_body['players'][1])
    halt 400
  end

  id = rand(100..999)
  games[id] = Game.new(@request_body['players'])

  JSON.generate(
    {
      id: id,
      message: 'New game created',
      players: @request_body['players']
    }
  )
end

delete '/delete/:id' do |id|
  id = id.to_i

  if id.digits.length == 3
    deleted = games.delete(id).nil?

    return JSON.generate(
      {
        id: id,
        message: deleted ? 'Game not found' : 'Game deleted'
      }
    )
  elsif id.digits.length == 4
    deleted = players.delete(id).nil?

    return JSON.generate(
      {
        id: id,
        message: deleted ? 'Player not found' : 'Player deleted'
      }
    )
  end

  halt 400
end

get '/games' do
  games_json = []

  games.each do |id, game|
    games_json << {
      id: id,
      ships_remaining: game.remaining_ships,
      players: game.players
    }
  end

  JSON.generate(games_json)
end

get '/players' do
  players_json = {}

  players_json['players'] = players.length
  players.each do |player|
    players_json[player.id] = {
      name: player.name
    }
  end

  JSON.generate(players_json)
end

get '/ships/:id' do |id|
  id = id.to_i
  ships_json = []

  return JSON.generate(ships_json) unless games.key?(id)

  games[id].ships.each do |ship_name, ship|
    ships_json << {
      name: ship_name.to_s.split('_').map(&:capitalize).join(' '),
      size: ship[:size],
      location: ship[:location].map { |location| Game.convert_to_letters(location) },
      hits: ship[:hit].map { |location| Game.convert_to_letters(location) },
      sunk: ship[:location] == ship[:hit]
    }
  end
  JSON.generate(ships_json)
end

post '/attack/:game/:location' do |game, location|
  game = game.to_i
  halt 400 unless games.key?(game)

  attack = games[game].attack(location)

  unless attack == false
    return JSON.generate(
      {
        hit: true,
        sunk: attack == :sunk
      }
    )
  end

  return JSON.generate({ hit: false })
end

post '/attack/:game' do |game|
  game = game.to_i
  halt 400 unless games.key?(game)

  attack = games[game].attack(games[game].random_pos_letters)

  unless attack == false
    return JSON.generate(
      {
        hit: true,
        sunk: attack == :sunk
      }
    )
  end

  return JSON.generate({ hit: false })
end

post '/place/:game/*-*' do |game, start_location, end_location|
  game = game.to_i
  halt 400 unless games.key?(game)

  if games[game].place_ship(start_location, end_location)
    return JSON.generate(
      {
        message: 'Ship placed'
      }
    )
  end

  halt 400
end

post '/place/:game/random' do |game|
  game = game.to_i
  halt 400 unless games.key?(game)

  halt 400 unless games[game].randomly_place_ships

  JSON.generate(
    {
      message: 'Ships placed'
    }
  )
end

get '/board/:game' do |game|
  content_type 'application/octet-stream'

  board_str = ['    A B C D E F G H I J']
  game = game.to_i
  halt 400 unless games.key?(game)

  board = games[game].board
  current_row = 0
  board.each do |row|
    row_str = []
    row_str << (current_row + 1 == 10 ? "#{(current_row += 1).to_i} " : "#{(current_row += 1).to_i}  ")
    row.each do |cell|
      case cell
      when :empty
        row_str << '|_'
      when :occupied
        row_str << '|o'
      when :sunk
        row_str << '|x'
      end
    end
    row_str << '|'
    board_str << row_str.join('')
  end

  board_str.join("\n")
end
