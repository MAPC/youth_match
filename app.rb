require './environment'
require 'json'
require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'tilt/haml'

class App < Sinatra::Base

  get '/' do
    "Hello, world!"
  end

  get '/runs' do
    @runs = Run.all
    haml :'runs/index'
  end

  get '/runs/:id' do
    @run = Run.find params[:id]
    haml :'runs/show'
  end
end

run App.run!
