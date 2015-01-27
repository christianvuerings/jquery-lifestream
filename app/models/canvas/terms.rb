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
          response = request_uncached("accounts/#{settings.account_id}/terms?#{params}", "_terms")
          break unless (response && response.status == 200 && terms_list = safe_json(response.body))
          all_terms.concat(terms_list['enrollment_terms'])
          params = next_page_params(response)
        end
        all_terms
      end
    end
  end
end
