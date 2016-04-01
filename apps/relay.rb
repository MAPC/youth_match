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

  get '/' do
    "Hello, Relay!"
  end

  get '/placements/:id/accept' do
    "#{params[:id]} Accepted!"
  end

  get '/placements/:id/decline' do
    # NO OP
  end

  get '/applicants/:id/opt-out' do
    #NO OP
  end

  error 404 do
    Airbrake.notify('Record not found', params: params)
    redirect *DYEERedirect.to(:error)
  end

  error 422 do
    Airbrake.notify('Unprocessable entity', params: params)
    redirect *DYEERedirect.to(:error)
  end

  private

  def load_placement
    applicant = Applicant.find_by uuid: params[:applicant_id]
    position  = Position.find_by  uuid: params[:position_id]
    @placement = Placement.find_by(
      id: params[:id], applicant: applicant, position: position
    )
  end
end
