require_relative '../icims'
require 'typhoeus'
require 'retries'

class ICIMS::Resource

  BASE_URI  = "https://api.icims.com/customers/#{ENV.fetch('ICIMS_CUSTOMER_ID')}"
  PROXY_URI = URI.parse ENV.fetch('PROXY_URL')

  def self.retry_method(method, path, options={})
    with_retries do
      Typhoeus.send method, url_for(path), default_options.merge(options)
    end
  end

  def self.retry_get(path, options={})
    retry_method :get,   path, options
  end

  def self.retry_post(path, options={})
    retry_method :post,  path, options
  end

  def self.retry_patch(path, options={})
    retry_method :patch, path, options
  end

  def self.url_for(path='/')
    path = "/#{}" if path.first != '/' # Add a leading slash
    "#{BASE_URI}#{path}"
  end

  def self.handle(response, &block)
    if response.success?
      body = response.body.present? ? response.body : '{}'
      yield JSON.parse(body)
    else
      raise ResponseError, response.inspect
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
      key = name.delete('@')
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

  def self.default_options
    { proxy: proxy_url, proxyuserpwd: proxy_auth, headers: headers }
  end

  def self.proxy_url
    "#{PROXY_URI.scheme}://#{PROXY_URI.host}:#{PROXY_URI.port || 80}"
  end

  def self.proxy_auth
    "#{PROXY_URI.user}:#{PROXY_URI.password}"
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
