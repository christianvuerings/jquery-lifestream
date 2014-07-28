module GoogleApps
  class Userinfo < Proxy

    def self.api
      "userinfo"
    end

    def user_info
      request(:api => 'plus', :resource => 'people', :method => 'get',
              :headers => {'Content-Type' => 'application/json'}, :vcr_id => '_userinfo',
              :params => { 'userId' => 'me'}).first
    end

  end
end
