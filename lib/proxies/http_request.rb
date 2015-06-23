module Proxies
  class HttpRequest
    include ClassLogger, HTTParty

    def self.verify_ssl?
      Settings.application.layer == 'production'
    end

    default_options[:verify] = verify_ssl?
    default_timeout Settings.application.outgoing_http_timeout
    headers 'Accept' => '*/*', 'User-Agent' => 'Ruby'

    def self.request_with_method(method)
      if [:delete, :get, :post, :put].include? method
        self.new(method)
      end
    end

    def initialize(method)
      @method = method
    end

    def perform(url, options={}, error_options={})
      response = HttpRequest.send(@method, url, options)
      handle_response_errors(response, error_options)
      response
    rescue Timeout::Error
      raise Errors::ProxyError.new('Timeout error', url: url)
    end

    private

    def handle_response_errors(response, error_options)
      return if error_options[:rescue_status] == response.code || error_options[:rescue_status] == :all
      error_options[:response] = response
      raise Errors::ProxyError.new('Connection failed', error_options) if response.code >= 400
      begin
        parse_response(response, error_options[:url])
      rescue MultiXml::ParseError => e
        raise Errors::ProxyError.new("Error parsing XML: #{e.message}", error_options)
      rescue JSON::ParserError => e
        raise Errors::ProxyError.new("Error parsing JSON: #{e.message}", error_options)
      end
    end

    def parse_response(response, url)
      if response.parsed_response.nil?
        logger.error "Unable to parse response from URL (#{url}), remote server status: #{response.code}, body: #{response.body}"
      end
    end

  end
end
