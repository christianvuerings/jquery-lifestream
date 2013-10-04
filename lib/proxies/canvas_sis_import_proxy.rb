class CanvasSisImportProxy < CanvasProxy
  require 'csv'
  include ClassLogger

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

  def import_all_term_enrollments(term_id, csv_file_path)
    import_with_check(csv_file_path, '_sis_import_enrollments', "&batch_mode=1&batch_mode_term_id=sis_term_id:#{term_id}")
  end

  def import_courses(csv_file_path)
    import_with_check(csv_file_path, '_sis_import_courses')
  end

  def import_enrollments(csv_file_path)
    import_with_check(csv_file_path, '_sis_import_enrollments')
  end

  def import_sections(csv_file_path)
    import_with_check(csv_file_path, '_sis_import_sections')
  end

  def import_users(csv_file_path)
    import_with_check(csv_file_path, '_sis_import_users')
  end

  def import_with_check(csv_file_path, vcr_id, extra_params = '')
    response = post_sis_import(csv_file_path, vcr_id, extra_params)
    import_successful?(response)
  end

  def post_sis_import(csv_file_path, vcr_id, extra_params)
    upload_body = { attachment: Faraday::UploadIO.new(csv_file_path, 'text/csv') }
    url = "accounts/#{settings.account_id}/sis_imports.json?import_type=instructure_csv&extension=csv#{extra_params}"
    request_uncached(url, vcr_id, {
        method: :post,
        connection: @multipart_conn,
        body: upload_body
    })
  end

  def import_successful?(response)
    if response && response.status == 200
      json = JSON.parse(response.body)
      import_status = import_status(json["id"])
      if import_was_successful?(import_status)
        logger.debug("SIS import succeeded; status: #{import_status}")
        true
      else
        logger.error("SIS import failed or incompletely processed; status: #{import_status}")
        false
      end
    else
      false
    end
  end

  def generate_course_sis_id(canvas_course_id)
    sis_course_id = "C:#{canvas_course_id}"
    url = "courses/#{canvas_course_id}?course[sis_course_id]=#{sis_course_id}"
    request_uncached(url, '_put_sis_course_id', {
        method: :put
    })
  end

  # import may not be completed the first time we ask for it, so loop until it is ready.
  def import_status(import_id)
    url = "accounts/#{settings.account_id}/sis_imports/#{import_id}"
    status = nil
    sleep 2
    # Large batch user and enrollment imports can be slow.
    retriable(:on => CanvasSisImportProxy::ReportNotReadyException, :tries => 100, :interval => 20) do
      response = request_uncached(url, '_sis_import_status', {
        method: :get
      })
      unless response.present? && response.body.present?
        logger.error "Import ID #{import_id} Status Report missing or errored; will retry later"
        raise CanvasSisImportProxy::ReportNotReadyException
      end
      json = JSON.parse response.body
      if ["initializing", "created", "importing"].include?(json["workflow_state"])
        logger.info "Import ID #{import_id} Status Report exists but is not yet ready; will retry later"
        raise CanvasSisImportProxy::ReportNotReadyException
      else
        status = json
      end
    end
    if status.nil?
      logger.error "Import ID #{import_id} Status Report not available after 5 tries, giving up"
    end
    logger.debug "Import ID #{import_id} Status Report = #{status}"
    status
  end

  def import_was_successful?(json)
    json.present? && json["progress"] == 100 && (json["workflow_state"] == "imported" || json ["workflow_state"] == "imported_with_messages")
  end

  class ReportNotReadyException < Exception

  end

end
