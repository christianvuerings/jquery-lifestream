class MyRegBlocks < MyMergedModel
  include DatedFeed

  def get_feed_internal
    proxy = BearfactsRegblocksProxy.new({:user_id => @uid})
    blocks_feed = proxy.get

    #Bearfacts proxy will return nil on >= 400 errors.
    if blocks_feed.nil?
      return {
        available: false,
      }
    end
    active_blocks = []
    inactive_blocks = []

    begin
      doc = Nokogiri::XML(blocks_feed[:body], &:strict)
    rescue Nokogiri::XML::SyntaxError
      #Will only get here on >400 errors, which are already logged
      return {
        available: false,
      }
    end

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
      type = to_text block.css("blockType")
      status = to_text block.css("status")
      office = to_text block.css("office")
      translated_codes = RegBlockCodeTranslator.new().translate_bearfacts_proxy(block.css('reasonCode').text, block.css('office').text)
      reason = translated_codes[:reason]
      message = translated_codes[:message]
      block_type = translated_codes[:type]
      short_desc = translated_codes[:office]

      reg_block = {
        status: status,
        type: type,
        short_description: short_desc,
        block_type: block_type,
        blocked_date: format_date(blocked_date, "%-m/%d/%Y"),
        cleared_date: format_date(cleared_date, "%-m/%d/%Y"),
        reason: reason,
        office: office,
        message: message,
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
      available: true,
      active_blocks: active_blocks,
      inactive_blocks: inactive_blocks
    }
  end

  private
  def to_text(css_element)
    css_element.try(:text).to_s.strip
  end
end
