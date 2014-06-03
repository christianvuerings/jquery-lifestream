# TODO collapse this class into Bearfacts::Regblocks
module MyAcademics
  class Regblocks

    include AcademicsModule
    include DatedFeed

    def merge(data)
      data[:regblocks] = Bearfacts::MyRegBlocks.new(@uid, original_uid: @original_uid).get_feed
    end
  end
end
