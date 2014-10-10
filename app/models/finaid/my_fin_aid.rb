# TODO collapse this class into Finaid::Proxy
module Finaid
  class MyFinAid < UserSpecificModel
    include ClassLogger
    include Cache::LiveUpdatesEnabled
    include Cache::JsonCacher

    def get_feed_internal
      feed = {
        :activities => []
      }
      if Settings.features.my_fin_aid
        append!(feed[:activities])
      end
      feed
    end

    def append!(activities)
      begin
        append_activities!(activities)
      rescue => e
        self.class.handle_exception(e, self.class.cache_key(@uid), {
          id: @uid,
          user_message_on_exception: "Remote server unreachable",
          return_nil_on_generic_error: true
        })
      end
    end

    def append_activities!(activities)
      proxies = TimeRange.current_years.collect do |year|
        Finaid::Proxy.new({user_id: @uid, term_year: year})
      end
      return unless proxies.present? && proxies.first.lookup_student_id.present?

      proxies.each do |proxy|
        next unless feed = proxy.get.try(:[], :body)
        begin
          content = Nokogiri::XML(feed, &:strict)
        rescue Nokogiri::XML::SyntaxError
          next
        end

        next unless valid_xml_response?(content)

        academic_year = term_year_to_s(proxy.term_year)

        append_diagnostics!(content.css("DiagnosticData Diagnostic"), academic_year, activities)
        append_documents!(content.css("TrackDocs Document"), academic_year, activities)
      end
    end

    def append_documents!(documents, academic_year, activities)
      cutoff_date = TimeRange.cutoff_date
      documents.each do |document|
        title = document.css("Name").text.strip

        date = parsed_date(document.css("Date").text.strip)
        if date.present? && (date < cutoff_date)
          logger.info "Document is too old to be shown: #{date.inspect} < #{cutoff_date}"
          next
        end
        date = format_date(date) if date.present?

        summary = document.css("Supplemental Usage Content[Type='TXT']").text.strip
        url = document.css("Supplemental Usage Content[Type='URL']").text.strip
        url = "https://myfinaid.berkeley.edu" if url.blank?

        result = {
          id: '',
          source: "Financial Aid",
          title: title,
          date: date,
          summary: summary,
          sourceUrl: url,
          emitter: "Financial Aid",
          termYear: academic_year
        }

        begin
          raw_status = document.css("Status").text.strip
          append_status(date, raw_status, result)
        rescue ArgumentError
          logger.error "Unable to decode finAid status for document: #{document.inspect} date: #{date.inspect}, status: #{raw_status.inspect}"
          next
        end

        activities << result
      end
    end

    def append_diagnostics!(diagnostics, academic_year, activities)
      diagnostics.each do |diagnostic|
        next unless diagnostic.css("Categories Category[Name='CAT01']").text.try(:strip) == 'W'
        title = diagnostic.css("Message").text.strip
        url = diagnostic.css("Supplemental Usage Content[Type='URL']").text.strip
        url = "https://myfinaid.berkeley.edu" if url.blank?
        summary = diagnostic.css("Usage Content[Type='TXT']").text.strip
        category = diagnostic.attribute('Category').try('value')

        next unless (title.present? && summary.present?)

        activities << {
          id: '',
          title: title,
          summary: summary,
          source: "Financial Aid",
          type: diagnostic_type_from_category(category),
          date: "",
          sourceUrl: url,
          emitter: "Financial Aid",
          termYear: academic_year
        }
      end
    end

    def diagnostic_type_from_category(category)
      if category == 'PKG'
        'info'
      elsif category == 'SUM'
        'financial'
      elsif ['MBA', 'DSB', 'SAP'].include? category
        'alert'
      else
        logger.warn("Unexpected diagnostic category: #{category}")
        'alert'
      end
    end

    def append_status(date, status, result)
      if status == 'Q' || (date.blank? && status.blank?)
        result[:type] = 'alert'
        result[:status] = 'Action required, missing document'
        result[:date] = ''
      elsif date.present? && status == 'N'
        result[:type] = 'financial'
        result[:status] = 'No action required, document received not yet reviewed'
      elsif date.present? && (status.blank? || status == 'M' || status == 'P' || status == 'W')
        result[:type] = 'message'
        result[:status] = 'No action required, document reviewed and processed'
      elsif status == 'R'
        result[:type] = 'alert'
        result[:status] = 'Action required, document received and returned'
      elsif status == 'I'
        result[:type] = 'alert'
        result[:status] = 'Action required, document received and incomplete'
      elsif status == 'U'
        result[:type] = 'alert'
        result[:status] = 'Action required, document received and unsigned'
      elsif status == 'X'
        result[:type] = 'alert'
        result[:status] = 'Action required, document received and on hold'
      elsif ['W'].include? status
        logger.info("Ignore documents with \"#{status}\" status")
        nil
      else
        raise ArgumentError, "Cannot decode status: #{date} status: #{status}"
      end
    end

    def parsed_date(date_string='')
      Date.parse(date_string).in_time_zone.to_datetime rescue ""
    end

    def term_year_to_s(term_year)
      "#{term_year.to_i-1}-#{term_year}"
    end

    def valid_xml_response?(xmldoc)
      code = xmldoc.css('Response Code').text.strip
      message = xmldoc.css('Response Message').text.strip
      return true if code == '0000'
      logger.warn("Feed not available for UID (#{@uid}). Code: #{code}, Message: #{message}")
      false
    end

  end
end
