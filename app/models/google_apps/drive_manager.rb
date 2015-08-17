module GoogleApps
  class DriveManager

    include ClassLogger

    def initialize(credential_store)
      @credential_store = credential_store
    end

    def create_folder(title, parent_id)
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      metadata = { :title => title, :mimeType => 'application/vnd.google-apps.folder' }
      dir = drive_api.files.insert.request_schema.new metadata
      dir.parents = [{ :id => parent_id }] if parent_id
      result = client.execute(:api_method => drive_api.files.insert, :body_object => dir)
      success = result.status == 200
      logger.error "An error occurred: #{result.data['error']['message']}" unless success
      success ? result.data : nil
    end

    def upload_file(title, description, parent_id, mime_type, file_absolute_path)
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      metadata = { :title => title, :description => description, :mimeType => mime_type }
      file = drive_api.files.insert.request_schema.new metadata
      # Target directory is optional
      file.parents = [{ :id => parent_id }] if parent_id
      media = Google::APIClient::UploadIO.new(file_absolute_path, mime_type)
      result = client.execute(
        :api_method => drive_api.files.insert,
        :body_object => file,
        :media => media,
        :parameters => { :uploadType => 'multipart', :alt => 'json'})
      success = result.status == 200
      logger.error "An error occurred: #{result.data['error']['message']}" unless success
      success ? result.data : nil
    end

    private

    def get_google_api
      client = GoogleApps::Client.client
      client.authorization = GoogleApps::Client.new_auth @credential_store
      client
    end

  end
end
