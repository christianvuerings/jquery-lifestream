# TODO collapse this class into Finaid::Proxy
module Finaid
  class MyFinAid < UserSpecificModel
    include DatedFeed, ClassLogger
    extend Cache::Cacheable

    def get_feed_internal
      feed = {
        :activities => []
      }
      if Settings.features.my_fin_aid
        self.class.append!(@uid, feed[:activities])
      end
      feed
    end

    def self.append!(uid, activities)
      begin
        append_activities!(uid, activities)
      rescue => e
        self.handle_exception(e, @uid, "Remote server unreachable", true)
      end
    end

    private

    def self.append_activities!(uid, activities)
      proxies = TimeRange.current_years.collect do |year|
        Finaid::Proxy.new({user_id: uid, term_year: year})
      end
      return unless proxies.present? && proxies.first.lookup_student_id.present?

      proxies.each do |proxy|
        next unless feed = proxy.get.try(:[], :body)
        begin
          content = Nokogiri::XML(feed, &:strict)
        rescue Nokogiri::XML::SyntaxError
          next
        end

        next unless valid_xml_response?(uid, content)

        academic_year = term_year_to_s(proxy.term_year)

        append_diagnostics!(content.css("DiagnosticData Diagnostic"), academic_year, activities)
        append_documents!(content.css("TrackDocs Document"), academic_year, activities)
      end
    end

    def self.append_documents!(documents, academic_year, activities)
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

        begin
          status = decode_status(date, document.css("Status").text.strip)
          next if status.nil?
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
          term_year: academic_year
        }

        if (status.values.none?)
          result[:type] = "alert"
          result[:status] = "Action required, missing document"
        elsif (status[:received] && !status[:reviewed])
          result[:type] = "financial"
          result[:status] = "No action required, document received not yet reviewed"
        elsif (status.values.all?)
          result[:type] = "message"
          result[:status] = "No action required, document reviewed and processed"
        end

        activities << result
      end
    end

    def self.append_diagnostics!(diagnostics, academic_year, activities)
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
          source_url: url,
          emitter: "Financial Aid",
          term_year: academic_year
        }
      end
    end

    def self.diagnostic_type_from_category(category)
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

    def self.decode_status(date, status)
      if date.blank? && (status.blank? || status == 'Q')
        {
          received: false,
          reviewed: false,
        }
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
      elsif ['W'].include? status
        logger.info("Ignore documents with \"#{status}\" status")
        nil
      else
        raise ArgumentError, "Cannot decode date: #{date} status: #{status}"
      end
    end

    def self.parsed_date(date_string='')
      Date.parse(date_string).in_time_zone.to_datetime rescue ""
    end

    def self.term_year_to_s(term_year)
      "#{term_year.to_i-1}-#{term_year}"
    end

    def self.valid_xml_response?(uid, xmldoc)
      code = xmldoc.css('Response Code').text.strip
      message = xmldoc.css('Response Message').text.strip
      return true if code == '0000'
      logger.warn("Feed not available for UID (#{uid}). Code: #{code}, Message: #{message}")
      false
    end

  end
end
