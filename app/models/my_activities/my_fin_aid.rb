class MyActivities::MyFinAid
  include DatedFeed, ClassLogger

  def self.append!(uid, activities)
    finaid_proxy = MyfinaidProxy.new({ user_id: uid })

    return unless finaid_proxy.lookup_student_id.present?
    return unless feed = finaid_proxy.get.try(:[], :body)
    begin
      content = Nokogiri::XML(feed, &:strict)
    rescue Nokogiri::XML::SyntaxError
      return
    end

    aid_year = content.at_css("AidYears AidYear[Default='X']")
    begin
      cutoff_date = DateTime.new(Integer(aid_year.text, 10)).prev_year
    rescue
      logger.error "Unable to parse AidYear from feed: #{aid_year.inspect}"
      cutoff_date = nil
    end

    append_diagnostics!(content.css("DiagnosticData Diagnostic"), activities)
    append_documents!(content.css("TrackDocs Document"), cutoff_date, activities)
  end

  private
  def self.append_documents!(documents, cutoff_date, activities)
    documents.each do |document|
      title = document.css("Name").text.strip

      date = DateTime.parse(document.css("Date").text.strip) rescue ""
      if (date.present? && cutoff_date.present? && date < cutoff_date)
        logger.info "Document is too old to be shown: #{date.inspect} < #{cutoff_date}"
        next
      end
      date = format_date(date) if date.present?
      summary = document.css("Supplemental Usage Content[Type='TXT']").text.strip
      url = document.css("Supplemental Usage Content[Type='URL']").text.strip
      url = "https://myfinaid.berkeley.edu" if url.blank?

      begin
        status = decode_status(date, document.css("Status").text.strip)
      rescue ArgumentError
        logger.error "Unable to decode finAid status for document: #{document.inspect} date: #{date.inspect}, status: #{status.inspect}"
        next
      end

      result = {
        id: '',
        source: "Financial Aid",
        title: title,
        date: date,
        summary: summary,
        source_url: url,
        emitter: "Financial Aid"
      }

      if (status.values.none?)
        result[:type] = "alert"
        result[:title].concat " - action required, missing document"
      elsif (status[:received] && !status[:reviewed])
        result[:type] = "financial"
        result[:title].concat " - no action required, document received not yet reviewed"
      elsif(status.values.all?)
        result[:type] = "message"
        result[:title].concat " -  no action required, document reviewed and processed"
      end

      activities << result
    end
  end

  def self.append_diagnostics!(diagnostics, activities)
    diagnostics.each do |diagnostic|
      next unless diagnostic.css("Categories Category[Name='CAT01']").text.try(:strip) == 'W'

      title = diagnostic.css("Message").text.strip
      url = diagnostic.css("URL").text.strip
      url = "https://myfinaid.berkeley.edu" if url.blank?
      summary = diagnostic.css("Usage Content[Type='TXT']").text.strip

      next unless (title.present? && summary.present?)

      activities <<  {
        id: '',
        title: title,
        summary: summary,
        source: "Financial Aid",
        type: "alert",
        date: "",
        source_url: url,
        emitter: "Financial Aid"
      }
    end
  end

  def self.decode_status(date, status)
    default = {
      received: false,
      reviewed: false,
    }

    if date.blank? && (status.blank? || status == 'Q')
      default
    elsif date.present? && status == 'N'
      {
        received: true,
        reviewed: false,
      }
    elsif date.present? && (status.blank? || status == "P")
      {
        received: true,
        reviewed: true,
      }
    else
      raise ArgumentError, "Cannot decode date: #{date} status: #{status}"
    end
  end
end
