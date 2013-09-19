class MyActivities::MyFinAid
  include DatedFeed, ClassLogger

  def self.append!(uid, activities)
    finaid_proxy = MyfinaidProxy.new({user_id: uid})

    return unless finaid_proxy.lookup_student_id.present?
    return unless feed = finaid_proxy.get.try(:[], :body)
    begin
      content = Nokogiri::XML(feed, &:strict)
    rescue Nokogiri::XML::SyntaxError
      return
    end

    append_diagnostics!(content.css("DiagnosticData Diagnostic"), activities)
    append_documents!(content.css("TrackDocs Document"), activities)
  end

  private
  def self.append_documents!(documents, activities)
    documents.each do |document|
      title = document.css("Name").text.strip

      date = DateTime.parse(document.css("Date").text.strip) rescue ""
      date = format_date(date) if date.present?
      summary = document.css("Supplemental Usage Content[Type='TXT']").text.strip
      url = document.css("Supplemental Usage Content[Type='URL']").text.strip

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
        emitter: "Financial Aid",
        color_class: "myfinaid-class"
      }

      if (status.values.none?)
        result[:type] = "alert"
        result[:title].concat " - action required, missing document"
      elsif (status[:received] && !status[:reviewed])
        result[:type] = "financial"
        result[:title].concat " - no action required, document received not yet reviewed"
      elsif(status.values.all?)
        result[:type] = "financial"
        result[:title].concat " -  no action required, document reviewed and processed"
      end

      activities << result
    end
  end

  def self.append_diagnostics!(diagnostics, activities)
    diagnostics.each do |diagnostic|
      next unless diagnostic.css("Categories Category[Name='CAT01']").text.try(:strip) == 'W'

      title = diagnostic.css("Message").text.strip
      url = diagnostic.css("URL").text.strip || ""
      summary = diagnostic.css("Usage Content[Type='TXT']").text.strip || ""

      next unless (title.present? && summary.present?)

      activities <<  {
        id: '',
        title: title,
        summary: summary,
        source: "Financial Aid",
        type: "alert",
        date: "",
        source_url: url,
        emitter: "Financial Aid",
        color_class: "myfinaid-class"
      }
    end
  end

  def self.decode_status(date, status)
    default = {
      received: false,
      reviewed: false,
    }

    if date.blank? && status == 'Q'
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
