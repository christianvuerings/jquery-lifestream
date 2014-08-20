module Bearfacts
  class Regblocks < Proxy

    include DatedFeed

    def get
      blocks_feed = request("/student/#{lookup_student_id}/reg/regblocks", "regblocks")

      feed = blocks_feed.except(:xml_doc)
      doc = blocks_feed[:xml_doc]
      unless doc.present?
        return feed
      end
      active_blocks = []
      inactive_blocks = []

      doc.css("studentRegistrationBlock").each do |block|
        blocked_date = cleared_date = nil
        begin
          blocked_date = Date.parse(block.css("blockedDate").text).in_time_zone.to_datetime
        rescue ArgumentError # no date
        end
        begin
          cleared_date = Date.parse(block.css("clearedDate").text).in_time_zone.to_datetime
        rescue ArgumentError # no date
        end

        is_active = cleared_date.nil?
        type = to_text block.css("blockType")
        status = to_text block.css("status")
        office = to_text block.css("office")
        translated_codes = Notifications::RegBlockCodeTranslator.new().translate_bearfacts_proxy(block.css('reasonCode').text, block.css('office').text)
        reason = translated_codes[:reason]
        message = translated_codes[:message]
        block_type = translated_codes[:type]
        short_desc = translated_codes[:office]

        reg_block = {
          status: status,
          type: type,
          shortDescription: short_desc,
          blockType: block_type,
          blockedDate: format_date(blocked_date, "%-m/%d/%Y"),
          clearedDate: format_date(cleared_date, "%-m/%d/%Y"),
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
      active_blocks.sort! { |a, b| b[:blockedDate][:epoch] <=> a[:blockedDate][:epoch] }
      inactive_blocks.sort! { |a, b| b[:blockedDate][:epoch] <=> a[:blockedDate][:epoch] }

      feed.merge({
                   activeBlocks: active_blocks,
                   inactiveBlocks: inactive_blocks
                 })

    end

    private

    def to_text(css_element)
      css_element.try(:text).to_s.strip
    end

  end
end
