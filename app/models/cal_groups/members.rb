module CalGroups
  class Members < Proxy
    include ClassLogger
    include ResponseWrapper

    def initialize(options = {})
      @group_name = options[:group_name]
      super(options)
    end

    private

    def request_path
      "groups/#{URI.escape(qualify @group_name)}/members"
    end

  end
end
