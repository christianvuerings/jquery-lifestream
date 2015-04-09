module Canvas
  module BackgroundJob
    include TorqueBox::Messaging::Backgroundable

    def self.unique_job_id
      Time.now.to_f.to_s.gsub('.', '')
    end

    def self.find(cache_key)
      Rails.cache.fetch(cache_key)
    end

  end
end
