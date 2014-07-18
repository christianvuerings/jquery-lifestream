module Financials
  # This model class caches a JSON translation of CFV data fetched by Financials::Proxy.
  # Inheriting from UserSpecificModel means it participates in the live-updates cache
  # invalidation and warmup cycle.
  class MyFinancials < UserSpecificModel
    include Cache::LiveUpdatesEnabled, Cache::UserCacheExpiry, SafeJsonParser
    include User::Student

    # Due to the potential size of finance data, the JSON version of the feed is not cached separately.
    def self.caches_separate_json?
      false
    end

    def warm_cache
      get_feed(false)
    end

    # Calling to_json on a large finances structure can take a very long time, and so
    # a JSON-fied version of the feed is cached and returned instead.
    def get_feed(force_cache_write=false)
      # smart_fetch_from_cache provides helpful services like special cache handling for exceptions.
      self.class.smart_fetch_from_cache({
        force_write: force_cache_write,
        id: @uid,
        user_message_on_exception: user_message_on_exception
      }) do
        feed = get_feed_internal
        status_code = feed[:statusCode]
        feed_json = feed.to_json
        if (status_code >= 400) && (status_code != 404)
          raise Errors::ProxyError.new("Connection failed for UID #{@uid}: #{status_code} #{feed[:body]}", feed_json)
        end
        feed_json
      end
    end

    def get_feed_internal
      student_id = lookup_student_id
      if student_id.blank?
        # don't continue if student id can't be found.
        logger.info "Lookup of student_id for uid #@uid failed, cannot call CFV API"
        feed = no_billing_data_response
      else
        response = Financials::Proxy.new(user_id: @uid, student_id: student_id).get
        feed = parse_response(response)
      end
      feed.merge(feed_metadata(feed, instance_key))
    end

    def parse_response(response)
      if response.code < 400
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
      elsif response.code == 404
        no_billing_data_response
      else
        {
          body: user_message_on_exception,
          statusCode: response.code
        }
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

    def user_message_on_exception
      'My Finances is currently unavailable. Please try again later.'
    end

  end
end
