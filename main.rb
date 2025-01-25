# frozen_string_literal: true

require 'sinatra'
require_relative 'lib/game'
require_relative 'lib/player'

games = {}
players = []

set :show_exceptions, false

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
  JSON.generate({ error: '500 Internal Server Error', message: env['sinatra.error'].message })
end

error 400 do
  JSON.generate({ error: '400 Bad Request', message: 'Invalid request body' })
end

get '/' do
  JSON.generate({ message: 'Hi!' })
end

post '/newplayer' do
  players << (params[:name].nil? ? Player.new : Player.new(params[:player]))

  JSON.generate(
    {
      id: players[-1].id,
      name: players[-1].name,
      message: 'New player created'
    }
  )
end

post '/new' do
  p @request_body
  halt 400 if @request_body['players'].nil?
  id = rand(100..999)
  games[id] = Game.new

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
  deleted = games.delete(id).nil?

  JSON.generate(
    {
      id: id,
      message: deleted ? 'Game not found' : 'Game deleted'
    }
  )
end

get '/games' do
  games_json = []

  games.each do |id, game|
    games_json << {
      id: id,
      ships_remaining: game.remaining_ships
    }
  end

  JSON.generate(games_json)
end

get '/ships/:id' do |id|
  id = id.to_i
  ships_json = []

  return JSON.generate(ships_json) unless games.key?(id)

  games[id].ships.each do |ship_name, ship|
    ships_json << {
      name: ship_name.to_s.split('_').map(&:capitalize).join(' '),
      size: ship[:size],
      location: ship[:location],
      hits: ship[:hit]
    }
  end
  JSON.generate(ships_json)
end
