module GoogleApps
  class SheetsManager < DriveManager

    def initialize(uid, options = {})
      super uid, options
      auth = get_google_api.authorization
      # See https://github.com/gimite/google-drive-ruby
      @session = GoogleDrive::Session.login_with_oauth auth.access_token
    end

    def spreadsheet_by_id(id)
      api_response = @session.execute!(:api_method => @session.drive.files.get, :parameters => { :fileId => id })
      log_response api_response
      case api_response.status
        when 200
          file = @session.wrap_api_file api_response.data
          raise Errors::ProxyError, "File is not a Google spreadsheet. Id: #{id}" unless file.is_a? GoogleDrive::Spreadsheet
        when 404
          logger.debug "No Google spreadsheet found with id = #{id}"
          file = nil
        else
          raise Errors::ProxyError, "Error in spreadsheet_by_id(#{id}): #{api_response.data['error']['message']}"
      end
      file
    rescue Google::APIClient::ClientError => e
      Rails.logger.error "Google API code is unhappy with spreadsheet_by_id(#{id}) call. Exception: #{e}"
      nil
    end

    def spreadsheets_by_title(title)
      spreadsheets = @session.spreadsheets(:q => "title = '#{title}'")
      logger.debug "No Google spreadsheets found with title = #{title}" if spreadsheets.nil? || spreadsheets.none?
      spreadsheets
    end

    def upload_csv_to_spreadsheet(title, description, file_path, parent_id = 'root')
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      media = Google::APIClient::UploadIO.new(file_path, 'text/csv')
      metadata = { :title => title, :description => description }
      file = drive_api.files.insert.request_schema.new metadata
      file.parents = [{ :id => parent_id }]
      api_response = @session.execute!(
        :api_method => drive_api.files.insert,
        :body_object => file,
        :media => media,
        :parameters => { :uploadType => 'multipart', :convert => true })
      log_response api_response
      success = api_response.status == 200
      raise Errors::ProxyError, "Error in upload_csv_to_spreadsheet(#{title}, ...): #{api_response.data['error']['message']}" unless success
      @session.wrap_api_file api_response.data
    end

  end
end
