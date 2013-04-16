class MyAcademics < MyMergedModel
  include DatedFeed

  def get_feed_internal
    feed = {}
    feed[:regblocks] = get_regblocks
    feed[:college_and_level] = get_college_and_level
    feed
  end

  private

  def get_college_and_level
    proxy = BearfactsProfileProxy.new({:user_id => @uid})
    feed = proxy.get_profile

    return {} if feed.nil?

    doc = Nokogiri::XML feed[:body]
    general_profile = doc.css("studentGeneralProfile")
    ug_grad_flag = to_text doc.css("ugGradFlag")
    standing = ug_grad_flag.upcase == "U" ? "Undergraduate" : "Graduate"
    level = to_text general_profile.css("nonAPLevel")
    college = to_text general_profile.css("collegePrimary")
    major = to_text general_profile.css("majorPrimary")
    {
      standing: standing,
      level: level,
      college: college,
      major: major
    }
  end

  def get_regblocks
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
      type = to_text block.css("blockType")
      status = to_text block.css("status")
      reason = to_text block.css("reason")
      office = to_text block.css("office")

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

  def to_text(element)
    if element.nil? || element.empty?
      return ""
    else
      return element.text.strip
    end
  end

end
