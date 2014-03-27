module GoogleApps
  class Userinfo < Proxy

    def self.api
      "userinfo"
    end

    def user_info
      request(:api => "oauth2", :resource => "userinfo", :method => "get",
              :headers => {"Content-Type" => "application/json"}, :vcr_id => "_userinfo").first
    end

  end
end
