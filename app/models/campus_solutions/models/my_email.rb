module CampusSolutions
  module Models
    class MyEmail < UserSpecificModel

      def update(params = {})
        proxy = CampusSolutions::Posts::Email.new({user_id: @uid, params: params})
        proxy.get
      end

    end
  end
end
