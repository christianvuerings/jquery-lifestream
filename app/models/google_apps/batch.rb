module GoogleApps
  class Batch < Proxy

    include ClassLogger

    def add(request_params)
      @requests ||= []
      @requests << request_params
    end

    def run_batch
      results = []
      batch = Google::APIClient::BatchRequest.new

      @requests.each do |request_params|
        page_params = setup_page_params request_params
        request_hash = GoogleApps::Client.generate_request_hash page_params
        batch.add request_hash do |result|
          logger.debug "Batch response status: #{result.response.status}"
          results << result
          if request_params[:callback].present?
            request_params[:callback].call result
          end
        end
      end

      client = GoogleApps::Client.client
      client.authorization = @authorization

      # before running the batch, refresh the token because it may have expired.
      # make sure the batch doesn't take more than an hour to process or the token
      # will expire again during the run.
      # see https://github.com/google/google-api-ruby-client/issues/167
      client.authorization.fetch_access_token!
      update_access_tokens!

      @requests = []

      client.execute batch
      results
    end
  end
end
