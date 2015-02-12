module Financials
  # This model class caches a JSON translation of CFV data fetched by Financials::Proxy.
  # Including LiveUpdatesEnabled means it participates in the live-updates cache invalidation and warmup cycle.
  # Including FeedExceptionsHandled makes it use a shorter-lived cache to deal with temporary CFV server problems.
  # Including JsonifiedFeed indicates that it should only cache a JSON-ified version of the feed, since calling to_json
  # on a large finances history can take a surprisingly long time and caching a raw version of the data structure
  # is unnecessary.
  class MyFinancials < UserSpecificModel
    include Cache::LiveUpdatesEnabled
    include Cache::FeedExceptionsHandled
    include Cache::JsonifiedFeed
    include SafeJsonParser
    include User::Student

    def get_feed_internal
      student_id = lookup_student_id
      if student_id.blank?
        # don't continue if student id can't be found.
        logger.info "Lookup of student_id for uid #@uid failed, cannot call CFV API"
        no_billing_data_response
      else
        response = Financials::Proxy.new(user_id: @uid, student_id: student_id).get
        parse_response(response)
      end
    end

    def parse_response(response)
      if response.code == 404
        no_billing_data_response
      else
        body = safe_json(response.body)
        if body && (student = body['student'])
          feed = {
            apiVersion: api_version(response),
            currentTerm: Berkeley::Terms.fetch.current.to_english,
            statusCode: response.code
          }
          feed.merge!(student)
        else
          logger.debug("Response missing student data for UID #{@uid}: status = #{response.code}, body = #{response.body}")
          {
            body: body,
            statusCode: response.code
          }
        end
      end
    end

    def api_version(response)
      # CFV API sends its version number in an HTTP header. We can use this on the front end to deal with
      # version differences between deployment environments.
      # CFV chose to use underscores in the HTTP header name, but VCR (and some other projects) automatically
      # convert underscores in a header name to hyphens. We therefore need to check using both.
      if response.headers && ((version = response.headers['x_cfv_api_version']) || (version = response.headers['x-cfv-api-version']))
        version.is_a?(Array) ? version[0] : version
      else
        nil
      end
    end

    def no_billing_data_response
      {
        body: "You are seeing this message because CalCentral does not have CARS billing data for your account. If you are a new student, your account may not have been assessed charges yet. Please try again later. Current or former students should contact us for further assistance using the Feedback link below.",
        statusCode: 404
      }
    end

    def default_message_on_exception
      'My Finances is currently unavailable. Please try again later.'
    end

  end
end
