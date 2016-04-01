require './environment'
require 'json'
require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'tilt/haml'

class Apps::Relay < Sinatra::Base

  set :method_override, true

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

  delete '/runs/:id' do
    Run.find(params[:id]).destroy
    redirect '/runs'
  end
end
