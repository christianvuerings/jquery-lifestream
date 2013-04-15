class MyRegBlocks < MyMergedModel
  include DatedFeed

  def get_feed_internal
    proxy = BearfactsRegblocksProxy.new({:user_id => @uid})
    blocks_feed = proxy.get_blocks

    #Bearfacts proxy will return nil on >= 400 errors.
    return {} if blocks_feed.nil?
    active_blocks = []
    inactive_blocks = []

    doc = Nokogiri::XML blocks_feed[:body]
    doc.css("studentRegistrationBlock").each do |block|
      blocked_date = cleared_date = nil
      begin
        blocked_date = DateTime.parse(block.css("blockedDate").text)
      rescue ArgumentError # no date
      end
      begin
        cleared_date = DateTime.parse(block.css("clearedDate").text)
      rescue ArgumentError # no date
      end

      is_active = cleared_date.nil?
      type = block.css("blockType").text.strip
      status = block.css("status").text.strip

      reason = block.css("reason")
      if reason.empty?
        reason = ""
      else
        reason = reason.text.strip
      end

      office = block.css("office")
      if office.empty?
        office = ""
      else
        office = office.text.strip
      end

      reg_block = {
        status: status,
        type: type,
        blocked_date: format_date(blocked_date, "%-m/%d/%Y"),
        cleared_date: format_date(cleared_date, "%-m/%d/%Y"),
        reason: reason,
        office: office
      }
      if is_active
        active_blocks << reg_block
      else
        inactive_blocks << reg_block
      end
    end

    # sort by blocked_date descending.
    active_blocks.sort! { |a, b| b[:blocked_date][:epoch] <=> a[:blocked_date][:epoch] }
    inactive_blocks.sort! { |a, b| b[:blocked_date][:epoch] <=> a[:blocked_date][:epoch] }

    {
      :active_blocks => active_blocks,
      :inactive_blocks => inactive_blocks
    }

  end

end
