module GoogleApps
  class SheetsManager < DriveManager

    def initialize(uid, options = {})
      super uid, options
      auth = get_google_api.authorization
      # See https://github.com/gimite/google-drive-ruby
      @session = GoogleDrive::Session.login_with_oauth auth.access_token
    end

    def export_csv(file)
      csv_export_uri = if file.respond_to? :csv_export_url
                     file.csv_export_url
                   elsif file.exportLinks && file.exportLinks['text/csv']
                     file.exportLinks['text/csv']
                   end
      raise Errors::ProxyError, "No CSV export path found for file ID: #{file.id}" unless csv_export_uri
      result = @session.execute!(uri: csv_export_uri)
      log_response result
      raise Errors::ProxyError, "export_csv failed with file.id=#{file.id}. Error: #{result.data['error']}" if result.error?
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
          raise Errors::ProxyError, "spreadsheet_by_id failed with id=#{id}. Error: #{result.data['error']}"
      end
      file
    rescue Google::APIClient::TransmissionError => e
      log_transmission_error(e, "spreadsheet_by_id failed with id=#{id}")
      nil
    end

    def spreadsheets_by_title(title, opts={})
      query = "title='#{escape title}' and trashed=false"
      query.concat " and '#{opts[:parent_id]}' in parents" if opts.has_key? :parent_id
      spreadsheets = @session.spreadsheets(:q => query)
      logger.debug "No spreadsheets found. Query: #{query}" if spreadsheets.nil? || spreadsheets.none?
      spreadsheets
    rescue Google::APIClient::TransmissionError => e
      log_transmission_error(e, "spreadsheets_by_title failed with query: #{query}")
      nil
    end

    # An alternative implementation of GoogleDrive::Spreadsheet#save without the expensive XML parsing.
    def update_worksheet(worksheet, updates)
      raise Errors::ProxyError, "File #{worksheet.id} is not a Google Sheets worksheet" unless worksheet.is_a? GoogleDrive::Worksheet

      cells_feed_url = CGI.escapeHTML worksheet.cells_feed_url.to_s
      cells_feed_url_base = cells_feed_url.gsub(/\/private\/full\Z/, '')
      xml = <<-EOS
            <feed xmlns="http://www.w3.org/2005/Atom"
                  xmlns:batch="http://schemas.google.com/gdata/batch"
                  xmlns:gs="http://schemas.google.com/spreadsheets/2006">
              <id>#{cells_feed_url}</id>
      EOS

      updates.each do |coordinates, value|
        row, col = coordinates
        safe_value = value ? CGI.escapeHTML(value).gsub("\n", '&#x0a;') : nil
        xml << <<-EOS
              <entry>
                <batch:id>#{row},#{col}</batch:id>
                <batch:operation type="update"/>
                <id>#{cells_feed_url_base}/R#{row}C#{col}</id>
                <link rel="edit" type="application/atom+xml" href="#{cells_feed_url}/R#{row}C#{col}"/>
                <gs:cell row="#{row}" col="#{col}" inputValue="#{safe_value}"/>
              </entry>
        EOS
      end

      xml << <<-EOS
            </feed>
      EOS

      result = @session.execute!(
        http_method: :post,
        uri: "#{cells_feed_url}/batch",
        body: xml,
        headers: {
          'Content-Type' => 'application/atom+xml;charset=utf-8',
          'If-Match' => '*'
        }
      )
      log_response result
      raise Errors::ProxyError, "update_worksheet failed with file.id=#{file.id}. Error: #{result.data['error']}" if result.error?
      raise Errors::ProxyError, "update_worksheet failed with file.id=#{file.id}. Error: interrupted" if result.body.include? 'batch:interrupted'
      result.body
    end

    def upload_worksheet(title, description, worksheet, parent_id = 'root', opts={})
      content = CSV.generate do |csv|
        headers = worksheet.headers
        csv << headers
        worksheet.each do |row|
          if opts[:format_numbers] == :text
            csv_row = headers.map do |header|
              # A trick to force plaintext formatting in Google Sheets.
              row[header] =~ /\A\d+\Z/ ? "'#{row[header]}" : row[header]
            end
            csv << csv_row
          else
            csv << row.values_at(*headers)
          end
        end
      end
      upload_to_spreadsheet(title, description, StringIO.new(content), parent_id)
    end

    def upload_to_spreadsheet(title, description, path_or_io, parent_id)
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      media = Google::APIClient::UploadIO.new(path_or_io, 'text/csv')
      metadata = { :title => title, :description => description }
      file = drive_api.files.insert.request_schema.new metadata
      file.parents = [{ :id => parent_id }]
      result = @session.execute!(
        :api_method => drive_api.files.insert,
        :body_object => file,
        :media => media,
        :parameters => { :uploadType => 'multipart', :convert => true })
      log_response result
      raise Errors::ProxyError, "upload failed with title=#{title}. Error: #{result.data['error']}" if result.error?
      @session.wrap_api_file result.data
    rescue Google::APIClient::TransmissionError => e
      log_transmission_error(e, "upload_to_spreadsheet failed with: #{[title, description, path_or_io, parent_id].to_s}")
      raise e
    end

    private

    def log_transmission_error(e, message_prefix)
      # Log error message and Google::APIClient::Result body
      logger.error "#{message_prefix}\n  Exception: #{e}\n  Google error_message: #{e.result.error_message}\n  Google response.data: #{e.result.body}\n"
    end

  end
end
