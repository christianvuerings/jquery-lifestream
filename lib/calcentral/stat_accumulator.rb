module Calcentral

  module StatAccumulator

    def stats_cache_key(stat_id)
      "global/StatAccumulator/#{stat_id}"
    end

    def zero(stat_id)
      Rails.cache.write(stats_cache_key(stat_id), 0, :expires_in => 0, :raw => true)
    end

    def write(stat_id, value)
      Rails.cache.write(stats_cache_key(stat_id), value, :raw => true)
    end

    def increment(stat_id, value)
      unless Rails.cache.exist?(stats_cache_key(stat_id))
        zero(stat_id)
      end
      Rails.cache.increment(stats_cache_key(stat_id), value, :raw => true)
    end

    def report(stat_id)
      value = Rails.cache.read(stats_cache_key(stat_id))
      "#{stat_id} = #{value}"
    end

  end

end
