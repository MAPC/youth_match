require_relative '../icims'
require 'httparty'
require 'retries'

class ICIMS::Resource
  include HTTParty

  def self.retry_get(args, options={})
    with_retries { get args, options }
  end

  def self.retry_post(args, options={})
    with_retries { post args, options }
  end

  def self.retry_patch(args, options={})
    with_retries { patch args, options }
  end

  base_uri 'https://api.icims.com/customers/6405'

  def self.handle(response, &block)
    if response.success?
      yield response
    else
      raise ResponseError, response.response
    end
  rescue => e
    $logger.error e.message
    raise
  end

  def handle(response, &block)
    self.class.handle response, &block
  end

  def attributes
    attr_hash = HashWithIndifferentAccess.new
    self.instance_variable_names.inject(attr_hash) do |hash, name|
      key = name.delete '@'
      hash[key] = self.instance_variable_get(name)
      hash
    end
  end

  def self.headers
    {
      'Authorization' => "Basic #{ENV['ICIMS_API_KEY']}",
      'Content-Type'  => 'application/json'
    }
  end

  def self.limit_results(results, limit, offset)
    base_results = Array(results['searchResults'])
    base_results.shift(offset) if offset > 0
    results = if limit
      base_results.first(limit.to_i)
    else
      base_results
    end
  end

  def ==(other)
    self.attributes == other.attributes
  end

end


class ICIMS::Resource::ResponseError < StandardError
  def initialize(msg="An error occurred when parsing the ICIMS response.")
    super
  end
end
