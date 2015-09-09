module GoogleApps
  class SheetsManager < DriveManager

    def initialize(uid, options = {})
      super uid, options
      auth = get_google_api.authorization
      # See https://github.com/gimite/google-drive-ruby
      @session = GoogleDrive::Session.login_with_oauth auth.access_token
    end

    def export_csv(file)
      unless file.exportLinks && (csv_export_uri = file.exportLinks['text/csv'])
        raise Errors::ProxyError, "No CSV export path found for file ID: #{file.id}"
      end
      result = @session.execute!(uri: csv_export_uri)
      log_response result
      raise Errors::ProxyError, "Error in export_csv, file ID (#{file.id}): #{result.data['error']['message']}" if result.error?
      result.body
    end

    def spreadsheet_by_id(id)
      result = @session.execute!(:api_method => @session.drive.files.get, :parameters => { :fileId => id })
      log_response result
      case result.status
        when 200
          file = @session.wrap_api_file result.data
          raise Errors::ProxyError, "File is not a Google spreadsheet. Id: #{id}" unless file.is_a? GoogleDrive::Spreadsheet
        when 404
          logger.debug "No Google spreadsheet found with id = #{id}"
          file = nil
        else
          raise Errors::ProxyError, "Error in spreadsheet_by_id(#{id}): #{result.data['error']['message']}"
      end
      file
    rescue Google::APIClient::ClientError => e
      Rails.logger.error "Google API code is unhappy with spreadsheet_by_id(#{id}) call. Exception: #{e}"
      nil
    end

    def spreadsheets_by_title(title)
      spreadsheets = @session.spreadsheets(:q => "title = '#{escape title}'")
      logger.debug "No Google spreadsheets found with title = #{title}" if spreadsheets.nil? || spreadsheets.none?
      spreadsheets
    end

    def upload_worksheet(title, description, worksheet, parent_id = 'root')
      content = CSV.generate do |csv|
        headers = worksheet.headers
        csv << headers
        worksheet.each { |row| csv << row.values_at(*headers) }
      end
      upload_to_spreadsheet(title, description, StringIO.new(content), parent_id)
    end

    def upload_to_spreadsheet(title, description, path_or_io, parent_id)
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      media = Google::APIClient::UploadIO.new(path_or_io, 'text/csv')
      metadata = { :title => escape(title), :description => escape(description) }
      file = drive_api.files.insert.request_schema.new metadata
      file.parents = [{ :id => parent_id }]
      result = @session.execute!(
        :api_method => drive_api.files.insert,
        :body_object => file,
        :media => media,
        :parameters => { :uploadType => 'multipart', :convert => true })
      log_response result
      raise Errors::ProxyError, "Error in upload(#{title}, ...): #{result.data['error']['message']}" if result.error?
      @session.wrap_api_file result.data
    end

  end
end
