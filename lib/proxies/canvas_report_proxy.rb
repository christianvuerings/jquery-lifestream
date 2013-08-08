class CanvasReportProxy < CanvasProxy
  require 'csv'

  def get_sis_export_csv(object_type, term_id = nil)
    get_account_csv('sis_export', object_type, term_id)
  end

  def get_provisioning_csv(object_type, term_id = nil)
    get_account_csv('provisioning', object_type, term_id)
  end

  def get_account_csv(report_type, object_type, term_id)
    term_param = term_id.blank? ? '' : "&parameters[enrollment_term]=sis_term_id:#{term_id}"
    response = request_uncached(
        "accounts/#{settings.account_id}/reports/#{report_type}_csv?parameters[#{object_type}]=1#{term_param}",
        "_start_#{report_type}_report_#{object_type}",
        { method: :post }
    )
    report_status = JSON.parse(response.body)
    report_id = report_status['id']

    tries = 0
    while ['created', 'running'].include?(report_status['status']) && (tries < 20) do
      sleep(20)
      tries += 1
      response = request_uncached(
          "accounts/#{settings.account_id}/reports/#{report_type}_csv/#{report_id}",
          "_check_#{report_type}_report_#{object_type}"
      )
      report_status = JSON.parse(response.body)
    end

    if report_status['status'] == 'complete'
      report_url = report_status['file_url']
      # We cannot use the file_url directly. Instead, we need to extract the
      # ID and send it to the Files API.
      file_id = /.+\/files\/(\d+)\/download/.match(report_url)[1]
      response = request_uncached(
          "files/#{file_id}",
          "_#{report_type}_report_file_#{object_type}"
      )
      file_info = JSON.parse(response.body)
      # Canvas's Files API builds an authorization token into the URL, which allows for redirection
      # to the file storage host but which conflicts with the authorization header we use for other API calls
      # and jams our VCR.
      if @fake
        csv = CSV.read("fixtures/pretty_vcr_recordings/Canvas_#{report_type}_report_#{object_type}_csv.csv", {headers: true})
      else
        conn = Faraday.new(file_info["url"]) do |c|
          c.use FaradayMiddleware::FollowRedirects
          c.use Faraday::Adapter::NetHttp
        end
        csv_response = request_uncached(
            "",
            "_#{report_type}_report_#{object_type}_csv",
            {
                uri: file_info["url"],
                non_oauth_connection: conn
            }
        )
        csv = CSV.parse(csv_response.body, {headers: true})
      end
      csv
    else
      Rails.logger.warn("Unexpected status when downloading report ID #{report_id} : #{response.body}")
      nil
    end
  end

end
