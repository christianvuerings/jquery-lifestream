module Oec
  module Administrator

    def self.is_admin?(uid)
      uid.to_s == Settings.oec.administrator_uid
    end

  end
end
