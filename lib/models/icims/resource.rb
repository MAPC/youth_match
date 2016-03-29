require_relative '../icims'
require 'httparty'

class ICIMS::Resource
  include HTTParty

  base_uri 'https://api.icims.com/customers/6405'

  def self.handle response, &block
    if response.success?
      yield response
    else
      raise StandardError, response.response
    end
  end

  def handle response, &block
    if response.success?
      yield response
    else
      raise StandardError, response.response.inspect
    end
  end

  def attributes
    self.instance_variable_names.inject(Hash.new) do |hash, name|
      key = name.delete '@'
      hash[key] = self.instance_variable_get(name)
      hash
    end
  end

  def self.headers
    {"Authorization" => "Basic #{ENV['ICIMS_API_KEY']}"}
  end

end
