require 'sinatra/base'
require 'sinatra/activerecord'
require './environment'
require 'airbrake'

class Apps::Relay < Sinatra::Base

  if ENV['AIRBRAKE_PROJECT_ID']
    Airbrake.configure do |c|
      c.project_id  = ENV['AIRBRAKE_PROJECT_ID']
      c.project_key = ENV['AIRBRAKE_KEY']
      c.environment = DATABASE_ENV.to_sym
      c.ignore_environments = [:development, :test]
      c.logger.level = Logger::DEBUG
    end
  end

  set :method_override, true
  set :logger, $stdout

  get '/' do
    "Hello, Relay!"
  end


  get '/placements/:id/accept/?' do
    load_placement
    @placement.accepted
    redirect *DYEERedirect.to(:accept)
  end

  get '/placements/:id/decline/?' do
    load_placement
    @placement.declined
    redirect *DYEERedirect.to(:decline)
  end

  get '/placements/:id/opt-out/?' do
    load_placement
    @placement.opted_out
    redirect *DYEERedirect.to(:opt_out)
  end


  error ActiveRecord::RecordNotFound do
    Airbrake.notify('Active Record | Record Not Found', params: error_payload)
    redirect *DYEERedirect.to(:error)
  end

  error 404 do
    Airbrake.notify('404 | Record Not Found', params: error_payload)
    redirect *DYEERedirect.to(:error)
  end

  error 422 do
    Airbrake.notify('422 | Unprocessable Entity', params: error_payload)
    redirect *DYEERedirect.to(:error)
  end

  error 500 do
    Airbrake.notify('Internal Server Error', params: {
      error: env['sinatra.error'],
      message: env['sinatra.error'].message
    })
    redirect *DYEERedirect.to(:error)
  end

  private

  def load_placement
    @placement = Placement.find_by!(
      uuid:      params[:id],
      applicant: Applicant.find_by!(uuid: params[:applicant_uuid]),
      position:  Position.find_by!(uuid: params[:position_uuid])
    )
    decidable? @placement
  end

  def decidable?(placement)
    redirect *DYEERedirect.to(:expired) if placement.expired?
    unless placement.updatable?
      Airbrake.notify('Not Updatable', params: airbrake_payload(placement))
      redirect *DYEERedirect.to("already_#{placement.status}")
    end
  end

  def airbrake_payload(placement)
    stats = {
      placement_id: placement.id,
      applicant_id: placement.applicant_id,
      position_id:  placement.position_id,
      workflow_id:  placement.workflow_id,
      placement_status: placement.status,
      applicant_status: placement.applicant.status,
      path: request.path_info,
      message: """
        It looks like applicant #{placement.applicant_id} was trying to
        #{request.path_info.to_s.split('/')[3]} while already #{placement.status}.
      """
    }.merge(params)
    unless [0, nil].include? placement.workflow_id
      stats.merge({ workflow_status: placement.workflow.status })
    end
    stats
  end

  def error_payload
    {
      path:   request.path_info,
      params: params,
      error: {
        object:  env['sinatra.error'],
        message: env['sinatra.error'].message
      }
    }
  end
end
