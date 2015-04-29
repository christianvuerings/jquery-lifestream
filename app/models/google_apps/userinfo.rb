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

  end
end
