module GoogleApps
  class Userinfo < Proxy

    def initialize(options = {})
      super options
      @json_filename='google_userinfo.json'
    end

    def mock_request
      super.merge(method: :get,
                  uri_matching: 'https://www.googleapis.com/plus/v1/people/me')
    end

    def self.api
      'userinfo'
    end

    def user_info
      request(:api => 'plus', :resource => 'people', :method => 'get',
              :headers => {'Content-Type' => 'application/json'},
              :params => { 'userId' => 'me'}).first
    end

    def current_scope
      # Make a real API request to ensure an up-to-date access token.
      ensure_access = user_info
      return [] unless ensure_access && ensure_access.response.status == 200
      access_token = authorization.access_token
      request_options = {
        query: {access_token: access_token}
      }
      response = get_response('https://www.googleapis.com/oauth2/v1/tokeninfo', request_options)
      if response['scope'].present?
        response['scope'].split
      else
        []
      end
    end

  end
end
