module Bearfacts
  class Regblocks < Proxy
    include DatedFeed

    def get
      student_id = lookup_student_id
      response = request("/student/#{student_id}/reg/regblocks", "regblocks")
      feed = response.delete :feed
      return response if feed.blank?

      active_blocks = []
      inactive_blocks = []

      feed['studentRegistrationBlocks']['studentRegistrationBlock'].as_collection.each do |block|
        blocked_date = block['blockedDate'].to_date
        cleared_date = block['clearedDate'].to_date
        is_active = cleared_date.blank?

        office = block['office'].to_text
        reason_code = block['reasonCode'].to_text
        type = block['blockType'].to_text
        status = block['status'].to_text

        translated_codes = Notifications::RegBlockCodeTranslator.new(student_id).translate_bearfacts_proxy(reason_code, office)

        reg_block = translated_codes.slice(:reason, :message).merge({
          status: status,
          type: type,
          shortDescription: translated_codes[:office],
          blockType: translated_codes[:type],
          blockedDate: format_date(blocked_date, "%-m/%d/%Y"),
          clearedDate: format_date(cleared_date, "%-m/%d/%Y"),
          office: office
        })

        if is_active
          active_blocks << reg_block
        else
          inactive_blocks << reg_block
        end
      end

      # sort by blocked_date descending.
      active_blocks.sort! { |a, b| b[:blockedDate][:epoch] <=> a[:blockedDate][:epoch] }
      inactive_blocks.sort! { |a, b| b[:blockedDate][:epoch] <=> a[:blockedDate][:epoch] }

      response.merge({
                   activeBlocks: active_blocks,
                   inactiveBlocks: inactive_blocks
                 })
    end

  end
end
