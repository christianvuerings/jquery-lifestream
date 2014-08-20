# TODO collapse this class into Bearfacts::Regblocks
module MyAcademics
  class Regblocks

    include AcademicsModule
    include DatedFeed

    def merge(data)
      data[:regblocks] = Bearfacts::Regblocks.new({user_id: @uid}).get
    end
  end
end
