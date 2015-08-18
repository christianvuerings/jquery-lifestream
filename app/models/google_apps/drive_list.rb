module GoogleApps
  class DriveList < Drive

    def initialize(options = {})
      super options
      @json_filename = 'google_drive_list.json'
    end

    def drive_list(optional_params = {}, page_limiter = nil)
      request :api => 'drive', :resource => 'files', :method => 'list', :params => optional_params,
              :page_limiter => page_limiter
    end

    def mock_request
      super.merge(uri_matching: 'https://www.googleapis.com/drive/v2/files')
    end

  end
end
