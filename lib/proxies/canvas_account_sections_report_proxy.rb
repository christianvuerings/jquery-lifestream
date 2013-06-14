class CanvasAccountSectionsReportProxy < CanvasProxy
  require 'csv'

  def get_csv(term_id)
    # The "provisioning_csv" report includes all sections, whether they have an SIS ID or not,
    # and so rows for the Canvas-only sections need to be skipped.
    #
    # Given good data, the most efficient sections report is "sis_export_csv", since that returns
    # only the sections which can be refreshed via SIS import.
    #
    # We get the provisioning report instead so we can check for problematic data
    # (particularly SIS-ID-ed sections belonging to a course that's missing its SIS ID),
    # and possibly repair it before importing campus data.
    response = request_uncached(
        "accounts/#{settings.account_id}/reports/provisioning_csv?parameters[enrollment_term]=sis_term_id:#{term_id}&parameters[sections]=1",
        "_start_provisioning_report_sections",
        { method: :post }
    )
    report_status = JSON.parse(response.body)
    report_id = report_status['id']

    tries = 0
    while ['created', 'running'].include?(report_status['status']) && (tries < 5) do
      sleep(2)
      tries += 1
      response = request_uncached(
          "accounts/#{settings.account_id}/reports/provisioning_csv/#{report_id}",
          "_check_provisioning_report"
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
          "_provisioning_report_file"
      )
      file_info = JSON.parse(response.body)
      # Canvas's Files API builds an authorization token into the URL, which allows for redirection
      # to the file storage host but which conflicts with the authorization header we use for other API calls
      # and jams our VCR.
      if @fake
        csv = CSV.read('fixtures/pretty_vcr_recordings/Canvas_provisioning_report_csv.csv', {headers: true})
      else
        conn = Faraday.new(file_info["url"]) do |c|
          c.use FaradayMiddleware::FollowRedirects
          c.use Faraday::Adapter::NetHttp
        end
        csv_response = request_uncached(
            "",
            "_provisioning_report_csv",
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
