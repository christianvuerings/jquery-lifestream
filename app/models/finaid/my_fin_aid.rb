# TODO collapse this class into Finaid::Proxy
module Finaid
  class MyFinAid < UserSpecificModel
    include ClassLogger
    include Cache::LiveUpdatesEnabled
    include Cache::JsonAddedCacher

    def get_feed_internal
      feed = {
        :activities => []
      }
      if Settings.features.my_fin_aid
        append!(feed[:activities])
      end
      if Settings.features.cs_fin_aid
        append_cs_fin_aid!(feed)
      end
      feed
    end

    def append_cs_fin_aid!(feed)
      begin
        proxy = CampusSolutions::Awards.new({user_id: @uid})
        feed[:awards] = proxy.get[:feed]
      rescue => e
        self.class.handle_exception(e, self.class.cache_key(@uid), {
                                       id: @uid,
                                       user_message_on_exception: "Remote server unreachable",
                                       return_nil_on_generic_error: true
                                     })
      end
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
        next unless feed = proxy.get
        next unless feed_available?(feed)

        academic_year = term_year_to_s(proxy.term_year)
        diagnostics = feed['SSIDOC']['FALifecycle']['DiagnosticData']['Diagnostic'].as_collection
        documents = feed['SSIDOC']['FALifecycle']['TrackData']['TrackDocs']['Document'].as_collection

        append_diagnostics!(diagnostics, academic_year, activities)
        append_documents!(documents, academic_year, activities)
      end
    end

    def append_documents!(documents, academic_year, activities)
      cutoff_date = TimeRange.cutoff_date
      documents.each do |document|
        title = document['Name'].to_text
        date = document['Date'].to_date
        if date.present? && (date < cutoff_date)
          logger.info "Document is too old to be shown: #{date.inspect} < #{cutoff_date}"
          next
        end
        date = format_date(date) if date.present?
        summary, url = get_supplemental_usage(document)

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
          raw_status = document['Status'].to_text
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
        categories = diagnostic['Categories']['Category'].as_collection
        next unless categories.find_by('Name', 'CAT01').content == 'W'

        title = diagnostic['Message'].to_text
        category = diagnostic['Category'].to_text
        summary, url = get_supplemental_usage(diagnostic)
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

    def get_supplemental_usage(element)
      usage_contents = element['Supplemental']['Usage']['Content'].as_collection
      summary = usage_contents.find_by('Type', 'TXT').content
      url = usage_contents.find_by('Type', 'URL').content("https://myfinaid.berkeley.edu")
      [summary, url]
    end

    def term_year_to_s(term_year)
      "#{term_year.to_i-1}-#{term_year}"
    end

    def feed_available?(feed)
      response_data = feed['SSIDOC']['Response']
      code = response_data['Code'].to_text('[No Code]')
      message = response_data['Message'].to_text('[No Message]')
      if code == '0000'
        true
      else
        logger.warn("Feed not available for UID (#{@uid}). Code: #{code}, Message: #{message}")
        false
      end
    end

  end
end
