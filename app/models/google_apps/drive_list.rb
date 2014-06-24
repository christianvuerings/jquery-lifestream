module GoogleApps
  class DriveList < Drive

    def initialize(options = {})
      super(options.reverse_merge(fake_options: {match_requests_on: [:method, :path]}))
    end

    def drive_list(optional_params={}, page_limiter=nil)
      request :api => "drive", :resource => "files", :method => "list", :params => optional_params, :vcr_id => "_drive_list",
              :page_limiter => page_limiter
    end

  end
end
