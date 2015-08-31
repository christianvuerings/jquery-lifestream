module Canvas
  class AccountRoles < Proxy
    include PagedProxy

    def initialize(options = {})
      super(options)
      account_id = options[:account_id] || settings.account_id
      raise ArgumentError, 'Account ID option must be a String or Fixnum' unless [String,Fixnum].include? account_id.class
      @account_id = account_id
    end

    def defined_course_roles(options = {})
      raw_list = roles_list options
      raw_list.select {|r| r['base_role_type'].end_with? 'Enrollment'}
    end

    def roles_list(options = {})
      response = optional_cache(options, key: @account_id, default: true) { paged_get request_path, show_inherited: true }
      response[:body] || []
    end

    def request_path
      "accounts/#{@account_id}/roles"
    end

    def mock_interactions
      mock_paged_interaction("canvas_account_roles_#{@account_id}", uri_matching: request_path, method: :get)
    end

  end
end
