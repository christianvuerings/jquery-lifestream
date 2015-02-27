module MyActivities
  class RegBlocks

    def self.append!(uid, activities)
      blocks_feed = Bearfacts::Regblocks.new({user_id: uid}).get
      if blocks_feed[:errored] || blocks_feed[:noStudentId]
        return
      end

      %w(activeBlocks inactiveBlocks).each do |block_category|
        if (blocks = blocks_feed[block_category.to_sym])
          blocks.each do |block|
            notification = process_block!(block)
            activities << notification if notification.present?
          end
        end
      end
    end

    private
    def self.process_block!(block)
      blocked_date = block.try(:[], :blockedDate).try(:[], :epoch)
      cleared_date = block.try(:[], :clearedDate).try(:[], :epoch)
      if include_in_feed?(blocked_date, cleared_date)
        block.merge!(
          {
            id: '',
            source: block[:shortDescription],
            sourceUrl: "https://bearfacts.berkeley.edu/bearfacts/",
            url: "https://bearfacts.berkeley.edu/bearfacts/",
            emitter: "Bear Facts"
          })
        if cleared_date
          process_cleared_block!(block)
        else
          process_active_block!(block)
        end

        unless (block[:blockType] == 'Academic' && block[:reason] == 'Academic')
          block[:title] += ": #{block[:reason]}"
        end

        Rails.logger.debug "#{self.class.name} Reg block is in feed, type = #{block[:blockType]}," \
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
          date: block[:clearedDate],
          title: "#{block[:blockType]} Block Cleared",
          summary: "This block, placed on #{block[:blockedDate][:dateString]}, "\
              "was cleared on #{block[:clearedDate][:dateString]}."
        })
    end

    def self.process_active_block!(block)
      block.merge!(
        {
          type: "alert",
          date: block[:blockedDate],
          title: "#{block[:blockType]} Block Placed",
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
end
