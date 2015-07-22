module Canvas
  module Report
    class Base < Canvas::Proxy
      require 'csv'

      def initialize(options = {})
        super options
        @account_id = options.delete(:account_id) || settings.account_id
        @options = options
      end

      def get_sis_export_csv(object_type, term_id = nil)
        get_account_csv('sis_export', object_type, term_id)
      end

      def get_csv(term_id = nil)
        get_provisioning_csv(object_type, term_id)
      end

      def get_provisioning_csv(object_type, term_id = nil)
        get_account_csv('provisioning', object_type, term_id)
      end

      def get_account_csv(report_type, object_type, term_id)
        term_param = term_id.blank? ? '' : "&parameters[enrollment_term]=sis_term_id:#{term_id}"
        report_status = ActiveSupport::Notifications.instrument('proxy', { class: self.class, method: __method__ }) do
          wrapped_post "accounts/#{@account_id}/reports/#{report_type}_csv?parameters[#{object_type}]=1#{term_param}"
        end
        unless report_status[:body]
          logger.warn "Unable to request #{report_type} report"
          return nil
        end

        check_status = check_report_status(report_type, report_status['id'])
        unless check_status['status'] == 'complete'
          logger.warn "Unexpected status when downloading report ID #{report_status['id']} : #{response.body}"
          return nil
        end

        report_url = check_status['file_url']
        # We cannot use the file_url directly. Instead, we need to extract the
        # ID and send it to the Files API.
        file_id = /.+\/files\/(\d+)\/download/.match(report_url)[1]
        file_response = wrapped_get "files/#{file_id}"
        unless file_response[:body]
          logger.error "Unable to find download URL for report #{report_id}"
          return nil
        end
        # Canvas's Files API builds an authorization token into the URL, which allows for redirection
        # to the file storage host but which conflicts with the authorization header we use for other API calls.
        if @fake
          csv = CSV.read("fixtures/csv/Canvas_#{report_type}_report_#{object_type}_csv.csv", headers: true)
        else
          conn = Faraday.new(file_response[:body]['url'], @options) do |c|
            c.use FaradayMiddleware::FollowRedirects
            c.use Faraday::Adapter::NetHttp
          end
          csv_response = ActiveSupport::Notifications.instrument('proxy', { class: self.class, method: __method__ }) do
            raw_request('', {
              uri: file_info["url"],
              non_oauth_connection: conn
            })
          end
          unless csv_response.status == 200
            logger.error "Unable to download report #{report_id} : #{csv_response}"
            return nil
          end
          csv = CSV.parse(csv_response.body, {headers: true})
        end
        csv
      end

      def check_report_status(report_type, report_id)
        url = "accounts/#{@account_id}/reports/#{report_type}_csv/#{report_id}"
        status = nil
        sleep 5
        tries = report_retrieval_attempts
        begin
          Retriable.retriable(on: Canvas::Report::ReportNotReadyException, tries: tries, interval: 20) do
            status = ActiveSupport::Notifications.instrument('proxy', { url: url, class: self.class, method: __method__ }) do
              wrapped_get(url)[:body]
            end
            if !status
              logger.error "Report ID #{report_id} status missing or errored; will retry later"
              raise Canvas::Report::ReportNotReadyException
            elsif %w(created running).include? status['status']
              logger.info "Report ID #{report_id} exists but is not yet ready; will retry later"
              raise Canvas::Report::ReportNotReadyException
            end
          end
        rescue Canvas::Report::ReportNotReadyException => e
          logger.error "Report ID #{report_id} not available after #{tries} tries, giving up"
        end
        logger.debug "Report ID #{report_id} status = #{status}"
        status
      end

      def report_retrieval_attempts
        # By default, we allow up to an hour for Canvas to rouse itself.
        180
      end

      private

      def mock_interactions
        on_request(uri_matching: "#{api_root}/accounts/#{@account_id}/reports/provisioning_csv", method: :get)
          .respond_with_file('fixtures', 'json', "canvas_check_provisioning_report_#{object_type}.json")

        on_request(uri_matching: "#{api_root}/accounts/#{@account_id}/reports/provisioning_csv", method: :post)
          .respond_with_file('fixtures', 'json', "canvas_start_provisioning_report_#{object_type}.json")

        on_request(uri_matching: "#{api_root}/files/", method: :get)
          .respond_with_file('fixtures', 'json', "canvas_provisioning_report_file_#{object_type}.json")
      end

    end

    class ReportNotReadyException < Exception; end
  end
end
