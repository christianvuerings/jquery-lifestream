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
    response = request_uncached(url, '_sis_import_enrollments', {
        method: :post,
        connection: @multipart_conn,
        body: upload_body
    })
  end

  def post_users(csv_file_path)
    upload_body = { attachment: Faraday::UploadIO.new(csv_file_path, 'text/csv') }
    url = "accounts/#{settings.account_id}/sis_imports.json?import_type=instructure_csv&extension=csv"
    response = request_uncached(url, '_sis_import_users', {
        method: :post,
        connection: @multipart_conn,
        body: upload_body
    })
  end

  def generate_course_sis_id(canvas_course_id)
    sis_course_id = "C:#{canvas_course_id}"
    url = "courses/#{canvas_course_id}?course[sis_course_id]=#{sis_course_id}"
    response = request_uncached(url, '_put_sis_course_id', {
        method: :put
    })
  end

end