module GoogleApps
  class EventsBatch < Events

    include ClassLogger

    def batch_request(request_params_array=[])
      results = []
      batch = Google::APIClient::BatchRequest.new do |result|
        logger.debug "Batch response status: #{result.response.status}"
        results << result
      end

      request_params_array.each do |request_params|
        page_params = setup_page_params request_params
        request_hash = GoogleApps::Client.generate_request_hash page_params
        batch.add request_hash
      end

      client = GoogleApps::Client.client
      client.authorization = @authorization

      # before running the batch, refresh the token because it may have expired.
      # make sure the batch doesn't take more than an hour to process or the token
      # will expire again during the run.
      # see https://github.com/google/google-api-ruby-client/issues/167
      client.authorization.fetch_access_token!
      update_access_tokens!

      client.execute batch
      results
    end
  end
end
