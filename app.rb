require './environment'
require 'json'
require 'sinatra'
require 'sinatra/activerecord'
require 'airbrake'

Airbrake.configure do |c|
  c.project_id = ENV['AIRBRAKE_ID']
  c.project_key = ENV['AIRBRAKE_KEY']
  c.ignore_environments = [:development, :test]
  c.logger.level = Logger::DEBUG
end

class App < Sinatra::Base
  DYEE    = 'http://youth.boston.gov/todo-default-page'
  ACCEPT  = 'http://youth.boston.gov/todo-accept-page'
  DECLINE = 'http://youth.boston.gov/todo-decline-page'
  ERROR   = 'http://youth.boston.gov/todo-error-page'
  EXPIRED = 'http://youth.boston.gov/todo-expired-page'

  get '/' do
    redirect DYEE, 308
  end

  get '/placements/:id/:action' do
    # load_placement
    @action = filter_action
    # assert_unexpired
    # assert_hireable
    # @placement.send @action
    # notify_icims
    # redirect action_route
    str =  "placement: #{params[:id]}<br/>"
    str << "applicant: #{params[:applicant_id]}<br/>"
    str << "position: #{params[:position_id]}<br/>"
    str << "action: #{@action}"
    str

  end

  def load_placement
    applicant = Applicant.find_by uuid: params[:applicant_id]
    position  = Position.find_by  uuid: params[:position_id]
    @placement = Placement.find_by(
      id: params[:id], applicant: applicant, position: position
    )
  end

  def filter_action
    action = params[:action].to_sym
    if [:accept, :decline].include?(action)
      action
    else
      raise
    end
  end

  def assert_unexpired
    redirect EXPIRED, 308 if @placement.expired?
  end

  def assert_hireable
    # TODO: Interact with ICIMS API, make sure they're not hired.
    # If they are, invalidate the user.
    redirect ERROR, 308 if @placement.invalid?
  end

  def notify_icims
    # TODO: Either create or update recruiting workflow in ICIMS
  end

  def action_route
    @action.to_s.upcase.constantize
  end

  error 404 do
    Airbrake.notify('Record not found', params: params)
    redirect ERROR, 307
  end

  error 422 do
    Airbrake.notify('Unprocessable entity', params: params)
    redirect ERROR, 307
  end
end

run App.run!
