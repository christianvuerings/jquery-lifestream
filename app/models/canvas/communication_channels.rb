module Canvas
  class CommunicationChannels < Proxy
    include ClassLogger

    def initialize(options = {})
      super(options)
      @canvas_user_id = options[:canvas_user_id]
    end

    def list
      wrapped_get request_path
    end

    def delete(channel_id)
      wrapped_delete "#{request_path}/#{channel_id}"
    end

    private

    def request_path
      "users/#{@canvas_user_id}/communication_channels"
    end

    def mock_interactions
      on_request(uri_matching: "#{api_root}/#{request_path}", method: :get)
        .respond_with_file('fixtures', 'json', 'canvas_communication_channels.json')

      on_request(uri_matching: "#{api_root}/#{request_path}/", method: :delete)
        .respond_with_file('fixtures', 'json', 'canvas_communication_channels_delete.json')
    end

  end
end
