module Canvas
  class Terms < Proxy

    def self.fetch
      self.new.terms[:body]
    end

    def self.current_terms
      terms = []
      terms_from_campus = Berkeley::Terms.fetch
      terms_from_canvas = self.fetch

      # Get current and next term, and optionally future fall term, from campus data
      terms.push terms_from_campus.current
      terms.push terms_from_campus.next if terms_from_campus.next
      if (future_term = terms_from_campus.future) && future_term.name == 'Fall'
        terms.push future_term
      end

      # Return subset of terms that have SIS ids in Canvas, warn on missing SIS ids
      sis_ids_from_canvas = terms_from_canvas.map{|term| term['sis_term_id']}
      terms.reject do |term|
        if !sis_ids_from_canvas.include? term_to_sis_id(term.year, term.code)
          logger.warn("SIS ID #{term_to_sis_id(term.year, term.code)} not found in Canvas")
          true
        else
          false
        end
      end
    end

    def self.current_sis_term_ids
      current_terms.collect do |term|
        term_to_sis_id(term.year, term.code)
      end
    end

    def self.sis_section_id_to_ccn_and_term(sis_term_id)
      if (parsed = /SEC:(?<term_yr>\d+)-(?<term_cd>[[:upper:]])-(?<ccn>\d+).*/.match(sis_term_id))
        {
          term_yr: parsed[:term_yr],
          term_cd: parsed[:term_cd],
          ccn: sprintf('%05d', parsed[:ccn].to_i)
        }
      end
    end

    def self.sis_term_id_to_term(sis_term_id)
      if (parsed = /TERM:(?<term_yr>\d+)-(?<term_cd>[[:upper:]])$/.match(sis_term_id))
        {
          term_yr: parsed[:term_yr],
          term_cd: parsed[:term_cd]
        }
      end
    end

    def self.term_to_sis_id(term_yr, term_cd)
      "TERM:#{term_yr}-#{term_cd}"
    end

    def terms
      self.class.fetch_from_cache do
        paged_get request_path, map_pages: ->(json) { json['enrollment_terms'] }
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'canvas_terms.json')
    end

    def request_path
      "accounts/#{settings.account_id}/terms"
    end
  end
end
