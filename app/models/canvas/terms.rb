module Canvas
  class Terms < Proxy

    def self.fetch
      self.new.terms
    end

    def terms
      self.class.fetch_from_cache do
        all_terms = []
        params = 'per_page=100'
        while params do
          response = request_uncached "#{request_path}?#{params}"
          break unless (response && response.status == 200 && terms_list = safe_json(response.body))
          all_terms.concat(terms_list['enrollment_terms'])
          params = next_page_params(response)
        end
        all_terms
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
