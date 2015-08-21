module GoogleApps
  class SheetsManager < DriveManager

    def initialize(credential_store)
      super credential_store
      auth = get_google_api.authorization
      auth.fetch_access_token!
      # See https://github.com/gimite/google-drive-ruby
      @session = GoogleDrive::Session.login_with_oauth auth.access_token
    end

    def spreadsheet_by_id(id)
      @session.spreadsheet_by_key id
    end

    def spreadsheet_by_title(title)
      @session.spreadsheet_by_title title
    end

    def upload_csv_to_spreadsheet(title, description, file_path, parent_id = 'root')
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      media = Google::APIClient::UploadIO.new(file_path, 'text/csv')
      metadata = { :title => title, :description => description }
      file = drive_api.files.insert.request_schema.new metadata
      file.parents = [{ :id => parent_id }]
      api_result = @session.execute!(
        :api_method => drive_api.files.insert,
        :body_object => file,
        :media => media,
        :parameters => { :uploadType => 'multipart', :convert => true })
      @session.wrap_api_file api_result.data
    end

  end
end
