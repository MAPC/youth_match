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

  # First, add resource test with chained timeouts
  # Then, add default tries: keyword.
  # Try rescuing at method level first, but may need something else
  # if the StandardError is raised instead.
  def self.handle response, &block
    if response.success?
      yield response
    else
      raise StandardError, response.response
    end
  rescue
  end

  def handle response, &block
    if response.success?
      yield response
    else
      raise StandardError, response.response.inspect
    end
  rescue
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

  def self.limit_results(results, limit)
    base_results = Array(results['searchResults'])
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
