class MyActivities::RegBlocks

  def self.append!(uid, activities)
    blocks_feed = MyRegBlocks.new(uid).get_feed
    if blocks_feed.empty? || blocks_feed[:available] == false
      return activities
    end

    %w(active_blocks inactive_blocks).each do |block_category|
      blocks_feed[block_category.to_sym].each do |block|
        notification = process_block!(block)
        activities << notification if notification.present?
      end
    end
  end

  private
  def self.process_block!(block)
    blocked_date = block.try(:[], :blocked_date).try(:[], :epoch)
    cleared_date = block.try(:[], :cleared_date).try(:[], :epoch)
    if include_in_feed?(blocked_date, cleared_date)
      block.merge!(
        {
          id: '',
          source: block[:short_description] || '',
          source_url: "https://bearfacts.berkeley.edu/bearfacts/",
          url: "https://bearfacts.berkeley.edu/bearfacts/",
          emitter: "BearFacts"
        })
      if cleared_date
        process_cleared_block!(block)
      else
        process_active_block!(block)
      end

      unless (block[:block_type] == 'Academic' && block[:reason] == 'Academic')
        block[:title] += ": #{block[:reason]}"
      end

      Rails.logger.debug "#{self.class.name} Reg block is in feed, type = #{block[:block_type]}," \
          "blocked_date = #{blocked_date}; cleared_date = #{cleared_date}"
      block
    else
      Rails.logger.debug "#{self.class.name} Reg block too old to include in feed, skipping. " \
          "blocked_date = #{blocked_date}; cleared_date = #{cleared_date}"
      nil
    end
  end

  def self.process_cleared_block!(block)
    block.merge!(
      {
        type: "message",
        date: block[:cleared_date],
        title: "#{block[:block_type]} Block Cleared",
        summary: "This block, placed on #{block[:blocked_date][:date_string]}, "\
            "was cleared on #{block[:cleared_date][:date_string]}."
      })
  end

  def self.process_active_block!(block)
    block.merge!(
      {
        type: "alert",
        date: block[:blocked_date],
        title: "#{block[:block_type]} Block Placed",
        summary: block[:message],
      }
    )
  end

  def self.include_in_feed?(blocked_date, cleared_date)
    if blocked_date && blocked_date.to_i >= MyActivities::Merged.cutoff_date
      return true
    end
    if cleared_date && cleared_date.to_i >= MyActivities::Merged.cutoff_date
      return true
    end
    false
  end
end
