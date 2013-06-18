module FakeableProxy
  extend self

  VCR.configure do |c|
    c.cassette_library_dir = 'fixtures/vcr_cassettes'
    c.hook_into :webmock, :faraday
    c.allow_http_connections_when_no_cassette = true
    c.debug_logger = File.open("#{CalcentralLogging.log_root}/vcr-debug.log", 'w')
    c.after_http_request do |request, response|
      # so we don't record sensitive auth headers
      if !response.blank?
        response.headers['Authorization'], response.headers['x-sakai-token'] = ''
      end
      if !request.blank?
        request.headers['Authorization'], request.headers['x-sakai-token'] = ''
      end
    end
    c.ignore_request do |request|
      ["https://accounts.google.com/o/oauth2/token",
       "https://www.googleapis.com/discovery/v1/apis",
       "https://www.googleapis.com/discovery/v1/apis/tasks/v1/rest"].include?(request.uri)
    end
  end

  def wrap_request(proxy_id, force_fake = nil, extra_cassette_options = {}, &proc_block)
    #Bypass on normal requests
    return yield unless force_fake || Settings.freshen_vcr

    if Settings.freshen_vcr
      return record_new_responses(proxy_id, extra_cassette_options, proc_block)
    end
    replay_fake_responses(proxy_id, extra_cassette_options, proc_block)
  end

  private

  def record_new_responses(proxy_id, extra_cassette_options, proc_block)
    Rails.logger.warn "#{self.class.name}  Recording new response for #{proxy_id}"
    VCR.configure do |c|
      c.cassette_library_dir = 'fixtures/pretty_vcr_recordings'
    end
    VCR.use_cassette(proxy_id, options=default_cassette_options({:record => :new_episodes}.merge(extra_cassette_options)), &block=proc_block)
  end

  def replay_fake_responses(proxy_id, extra_cassette_options, proc_block)
    begin
      VCR.use_cassette(proxy_id, options=default_cassette_options({:record => :none}.merge(extra_cassette_options)), &block=proc_block)
    rescue VCR::Errors::UnhandledHTTPRequestError => e
      logger_hash = {:method => e.request.method,
                     :uri => e.request.uri,
                     :body => e.request.body
      }
      Rails.logger.warn "#{self.class.name} Unrecorded VCR response for: #{logger_hash}"
      proc_block.call
    end
  end

  def query_string_matcher
    Proc.new do |a, b|
      a_uri = URI(a.uri).query
      b_uri = URI(b.uri).query
      if !a_uri.blank? && !b_uri.blank?
        a_param_hash = CGI::parse(a_uri)
        b_param_hash = CGI::parse(b_uri)
        a_param_hash == b_param_hash
      else
        a_uri == b_uri
      end
    end
  end

  def default_cassette_options(options = {})
    options.reverse_merge(
      {
        :allow_playback_repeats => true,
        :match_requests_on => [:method, :path, query_string_matcher, :body],
        :serialize_with => :json,
        :preserve_exact_body_bytes => false
      })
  end

end
