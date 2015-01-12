module Canvas
  class Terms < Proxy
    def self.fetch
      self.new.terms
    end

    def terms
      response = self.class.fetch_from_cache do
         request_uncached("accounts/#{settings.account_id}/terms", "_terms")
      end
      if response && response.status == 200 && terms_object = safe_json(response.body)
        terms_object['enrollment_terms']
      else
        []
      end
    end
  end
end
