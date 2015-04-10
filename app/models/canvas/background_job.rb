module Canvas
  module BackgroundJob
    include TorqueBox::Messaging::Backgroundable

    def self.unique_job_id
      15.times do
        cache_key_candidate = "#{self.name.to_sym}.#{Time.now.to_f.to_s.gsub('.', '')}-#{SecureRandom.hex(8)}"
        return cache_key_candidate if Rails.cache.read(cache_key_candidate).nil?
      end
      raise RuntimeError, 'Unable to find unique Canvas Background Job ID'
    end

    def self.find(cache_key)
      Rails.cache.fetch(cache_key)
    end

    def background_job_save
      Rails.cache.write(background_job_id, self, expires_in: Settings.cache.expiration.CanvasBackgroundJobs)
    end

    def background_job_id
      @background_job_id ||= Canvas::BackgroundJob.unique_job_id
    end
  end
end
