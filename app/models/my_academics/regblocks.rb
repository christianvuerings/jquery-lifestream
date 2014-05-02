# TODO collapse this class into Bearfacts::Regblocks
module MyAcademics
  class Regblocks

    include MyAcademicsModule
    include DatedFeed

    def merge(data)
      blocks = Bearfacts::MyRegBlocks.new(@uid, original_uid: @original_uid).get_feed

      data[:regblocks] = {
        available: blocks[:available],
        active_blocks: blocks[:active_blocks] || [],
        inactive_blocks: blocks[:inactive_blocks] || []
      }

    end
  end
end
