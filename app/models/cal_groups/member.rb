module CalGroups
  class Member < Proxy
    include ClassLogger
    include ResponseWrapper

    def initialize(options = {})
      @group_name = options[:group_name]
      @member_id = options[:member_id]
      super(options)
    end

    private

    def request_path
      "groups/#{URI.escape(qualify @group_name)}/members/#{@member_id}"
    end

  end
end
