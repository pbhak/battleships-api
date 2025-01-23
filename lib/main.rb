# frozen_string_literal: true

require 'sinatra'

before do
  content_type 'text/plain'
end

get '/' do
  'Hi!'
end
