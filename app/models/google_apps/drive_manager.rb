module GoogleApps
  class DriveManager

    include ClassLogger

    def initialize(uid, options = {})
      @uid = uid
      @options = options
    end

    def get_items_in_folder(parent_id, mime_type = nil)
      options = {:parent_id => parent_id}
      options.merge!({ :mime_type => mime_type }) unless mime_type.nil?
      find_items(options)
    end

    def find_folders_by_title(title, parent_id = 'root')
      find_items_by_title(title, mime_type: 'application/vnd.google-apps.folder', parent_id: parent_id)
    end

    def find_folders(parent_id = 'root')
      find_items(mime_type: 'application/vnd.google-apps.folder', parent_id: parent_id)
    end

    def find_items_by_title(title, options = {})
      find_items options.merge({ :title => title })
    end

    def find_items(options = {})
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      items = []
      parent_id = options[:parent_id] || 'root'
      query = "'#{parent_id}' in parents and trashed=false"
      query.concat " and title='#{options[:title]}'" if options.has_key? :title
      query.concat " and mimeType='#{options[:mime_type]}'" if options.has_key? :mime_type
      page_token = nil
      begin
        parameters = { :q => query }
        parameters[:pageToken] = page_token unless page_token.nil?
        api_response = client.execute(:api_method => drive_api.files.list, :parameters => parameters)
        log_response api_response
        case api_response.status
          when 200
            files = api_response.data
            items.concat files.items
            page_token = files.next_page_token
          when 404
            logger.debug 'No items found, returning empty array'
            page_token = nil
          else
            raise Errors::ProxyError, "Error in find_items(#{options}): #{api_response.data['error']['message']}"
            page_token = nil
        end
      end while page_token.to_s != ''
      items
    end

    def create_folder(title, parent_id = 'root')
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      metadata = { :title => title, :mimeType => 'application/vnd.google-apps.folder' }
      dir = drive_api.files.insert.request_schema.new metadata
      dir.parents = [{ :id => parent_id }] if parent_id
      result = client.execute(:api_method => drive_api.files.insert, :body_object => dir)
      log_response result
      success = result.status == 200
      raise Errors::ProxyError, "Error in create_folder(#{title}, ...): #{result.data['error']['message']}" unless success
      success ? result.data : nil
    end

    def upload_file(title, description, parent_id, mime_type, file_path)
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      metadata = { :title => title, :description => description, :mimeType => mime_type }
      file = drive_api.files.insert.request_schema.new metadata
      # Target directory is optional
      file.parents = [{ :id => parent_id }] if parent_id
      media = Google::APIClient::UploadIO.new(file_path, mime_type)
      result = client.execute(
        :api_method => drive_api.files.insert,
        :body_object => file,
        :media => media,
        :parameters => { :uploadType => 'multipart', :alt => 'json'})
      log_response result
      success = result.status == 200
      raise Errors::ProxyError, "Error in upload_file(#{title}): #{result.data['error']['message']}" unless success
      success ? result.data : nil
    end

    def trash_item(id)
      client = get_google_api
      drive = client.discovered_api('drive', 'v2')
      result = client.execute(
        :api_method => drive.files.trash,
        :parameters => { :fileId => id })
      log_response result
      success = result.status == 200
      raise Errors::ProxyError, "Error in trash_item(#{id}): #{result.data['error']['message']}" unless success
      success ? result.data : nil
    end

    def copy_item_to_folder(item, folder_id, copy_title=nil)
      copy_title ||= item.title
      if (copy = copy_item(item.id, copy_title))
        old_parent_id = copy.parents.first.id
        add_parent(copy.id, folder_id) && remove_parent(copy.id, old_parent_id)
      end
      copy
    end

    def copy_item(id, copy_title)
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      copy_schema = drive_api.files.copy.request_schema.new({'title' => copy_title})
      result = client.execute(
        :api_method => drive_api.files.copy,
        :body_object => copy_schema,
        :parameters => { :fileId => id }
      )
      log_response result
      success = result.status == 200
      raise Errors::ProxyError, "Error in copy_item(#{id}): #{result.data['error']['message']}" unless success
      success ? result.data : nil
    end

    def add_parent(id, parent_id)
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      new_parent = drive_api.parents.insert.request_schema.new({'id' => parent_id})
      result = client.execute(
        :api_method => drive_api.parents.insert,
        :body_object => new_parent,
        :parameters => { :fileId => id }
      )
      log_response result
      success = result.status == 200
      raise Errors::ProxyError, "Error in add_parent(#{id}, #{parent_id}): #{result.data['error']['message']}" unless success
      success ? result.data : nil
    end

    def remove_parent(id, parent_id)
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      result = client.execute(
        :api_method => drive_api.parents.delete,
        :parameters => {
          'fileId' => id,
          'parentId' => parent_id
        }
      )
      log_response result
      # This call may return an empty 204 on success.
      success = result.status <= 204
      raise Errors::ProxyError, "Error in remove_parent(#{id}, #{parent_id}): #{result.data['error']['message']}" unless success
      success ? result.data : nil
    end

    def folder_id(folder)
      folder ? folder.id : 'root'
    end

    def folder_title(folder)
      folder ? folder.title : 'root'
    end

    protected

    def get_google_api
      if @client.nil?
        credential_store = GoogleApps::CredentialStore.new(@uid, @options)
        @client = GoogleApps::Client.client
        storage = Google::APIClient::Storage.new credential_store
        auth = storage.authorize
        credentials = credential_store.load_credentials
        if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
          logger.warn "OAuth2 object #{auth.nil? ? 'is nil' : 'is expired'}"
          flow = Google::APIClient::InstalledAppFlow.new({ :client_id => credentials[:client_id],
                                                           :client_secret => credentials[:client_secret],
                                                           :scope => credentials[:scope] })
          auth = flow.authorize storage
        end
        @client.authorization = auth
        token_hash = @client.authorization.fetch_access_token!
        credential_store.write_credentials(credentials.merge token_hash)
      end
      @client
    end

    def log_response(api_response)
      logger.debug "Google Drive API request #{api_response.request.api_method.id} #{api_response.request.parameters} returned status #{api_response.status}"
    end

  end
end
