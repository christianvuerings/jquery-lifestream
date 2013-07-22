class CanvasSisImportProxy < CanvasProxy
  require 'csv'

  def initialize(options = {})
    super(options)
    @multipart_conn = multipart_conn
  end

  def multipart_conn
    conn = Faraday.new do |c|
      c.request :multipart
      c.request :url_encoded
      c.adapter :net_http
    end
  end

  def post_enrollments(term_id, csv_file_path)
    upload_body = { attachment: Faraday::UploadIO.new(csv_file_path, 'text/csv') }
    url = "accounts/#{settings.account_id}/sis_imports.json?import_type=instructure_csv&extension=csv&batch_mode=1&batch_mode_term_id=sis_term_id:#{term_id}"
    request_uncached(url, '_sis_import_enrollments', {
        method: :post,
        connection: @multipart_conn,
        body: upload_body
    })
  end

  def post_users(csv_file_path)
    upload_body = { attachment: Faraday::UploadIO.new(csv_file_path, 'text/csv') }
    url = "accounts/#{settings.account_id}/sis_imports.json?import_type=instructure_csv&extension=csv"
    request_uncached(url, '_sis_import_users', {
        method: :post,
        connection: @multipart_conn,
        body: upload_body
    })
  end

  def generate_course_sis_id(canvas_course_id)
    sis_course_id = "C:#{canvas_course_id}"
    url = "courses/#{canvas_course_id}?course[sis_course_id]=#{sis_course_id}"
    request_uncached(url, '_put_sis_course_id', {
        method: :put
    })
  end

  def import_status(import_id)
    url = "accounts/#{settings.account_id}/sis_imports/#{import_id}"
    status = nil
    sleep 2
    retriable(:on => ReportNotReadyException, :tries => 5, :interval => 2) do
      response = request_uncached(url, '_sis_import_status', {
        method: :get
      })
      if response.nil?
        Rails.logger.warn "#{self.class.name} SIS Import Status Report missing or errored; will retry in 2s"
        raise ReportNotReadyException
      end
      json = JSON.parse response.body
      if json["workflow_state"] == "initializing" || json["workflow_state"] == "created"
        Rails.logger.warn "#{self.class.name} SIS Import Status Report exists but is not yet ready; will retry in 2s"
        raise ReportNotReadyException
      else
        status = json
      end
    end
    if status.nil?
      Rails.logger.error "#{self.class.name} SIS Import Status Report not available after 5 tries, giving up"
    end
    Rails.logger.warn "#{self.class.name} Import status = #{status}"
    status
  end

  def import_was_successful?(json)
    json.present? && json["progress"] == 100 && (json["workflow_state"] == "imported" || json ["workflow_state"] == "imported_with_messages")
  end

  class ReportNotReadyException < Exception

  end

end
