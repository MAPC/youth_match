require './environment'
require 'sinatra'
require 'sinatra/activerecord'

# Airbrake.configure do |c|
#   c.project_id = ENV['AIRBRAKE_ID']
#   c.project_key = ENV['AIRBRAKE_KEY']
#   c.ignore_environments = [:development, :test]
#   c.logger.level = Logger::DEBUG
# end

class Apps::Relay < Sinatra::Base

  set :method_override, true
  set :logger, $stdout

  get '/' do
    "Hello, Relay!"
  end

  get '/placements/:id/accept' do
    load_placement(params)
    handle_error_cases(@placement)
    if workflow.updatable? # change to @placement
      # @placement.accepted does workflow accepted, 500 should go to error
      @placement.accepted if workflow.accepted
      redirect *DYEERedirect.to(:accept)
    end
  end

  get '/placements/:id/decline' do
    # NO OP
  end

  get '/applicants/:id/opt-out' do
    #NO OP
  end

  error 404 do
    Airbrake.notify('Record Not Found', params: params)
    redirect *DYEERedirect.to(:error)
  end

  error 422 do
    Airbrake.notify('Unprocessable Entity', params: params)
    redirect *DYEERedirect.to(:error)
  end

  error 500 do
    Airbrake.notify('Internal Server Error', params: params)
    redirect *DYEERedirect.to(:error)
  end

  private

  def load_placement(params)
    applicant = Applicant.find_by uuid: params[:applicant_id]
    position  = Position.find_by  uuid: params[:position_id]
    @placement = Placement.find_by(uuid: params[:id],
      applicant: applicant, position: position)
  end

  def handle_error_cases(placement)
    redirect *DYEERedirect.to(:expired) if placement.expired?
    redirect *DYEERedirect.to(:error) if placement.already_decided?
    false
  end
end

