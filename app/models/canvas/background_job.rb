module Canvas
  # Provides background job states for background job workers
  #
  # Usage Example:
  #
  #   def MyClass
  #     include Canvas::BackgroundJob
  #
  #     def initialize
  #       background_job_set_total_steps(2)
  #     end
  #
  #     def perform_work
  #       # do step one
  #       if (error)
  #         background_job_add_error('Something went wrong')
  #         return false
  #       end
  #       background_job_complete_step('First step completed')
  #
  #       # do step two
  #       background_job_complete_step('Second step completed')
  #     end
  #
  #     def background_job_report_custom
  #       {:customKey => 'custom value'}
  #     end
  #   end
  #
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

    def background_job_status
      @background_job_status ||= 'New'
    end

    def background_job_errors
      @background_job_errors ||= []
    end

    def background_job_completed_steps
      @background_job_completed_steps ||= []
    end

    def background_job_total_steps
      @background_job_total_steps ||= 1
    end

    # Overridden by class. Provides hash merged into background job report hash
    def background_job_report_custom
      Hash.new
    end

    def background_job_set_total_steps(total_steps)
      @background_job_total_steps = total_steps.to_i
      background_job_save
    end

    def background_job_add_error(error)
      @background_job_errors ||= []
      @background_job_errors << error
      @background_job_status = 'Error'
      background_job_save
    end

    def background_job_report
      json_hash = {
        jobId: background_job_id,
        jobStatus: background_job_status,
        completedSteps: background_job_completed_steps,
        percentComplete: (background_job_completed_steps.count.to_f / background_job_total_steps.to_f).round(2),
      }
      json_hash[:errors] = background_job_errors if background_job_errors.count > 0
      json_hash.reverse_merge!(background_job_report_custom)
      json_hash.to_json
    end

    def background_job_complete_step(step_text)
      @background_job_completed_steps ||= []
      @background_job_completed_steps << step_text

      if @background_job_status != 'Error'
        completed_steps = background_job_completed_steps.count
        @background_job_status = 'Processing' if (completed_steps > 0) || (completed_steps < @background_job_total_steps)
        @background_job_status = 'Completed' if (completed_steps == @background_job_total_steps)
      end

      background_job_save
    end

  end
end
