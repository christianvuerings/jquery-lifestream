module MyTasks::ParamValidator
  # Validate params does two different type of validations. 1) Required - existance of key validation. A key specified in
  # filter_keys must exist in initial_hash, or else the Missing parameter argumentError is thrown. 2) Optional - Proc function
  # validation on initial_hash values. If a Proc is provided as a value for a filter_key, the proc will be executed and expect
  # a boolean result of whether or not validation passed. Anything other than a Proc is treated as noop.
  def validate_params(initial_hash={}, filters={})
    filter_keys = filters.keys
    params_to_check = initial_hash.select { |key, value| filter_keys.include? key }
    raise ArgumentError, "Missing parameter(s). Required: #{filter_keys}" if params_to_check.length != filter_keys.length
    filters.keep_if { |key, value| value.is_a?(Proc) }
    filters.each do |filter_key, filter_proc|
      logger.debug "Validating params for #{filter_key}"
      if !(filter_proc.call(params_to_check[filter_key]))
        raise ArgumentError, "Invalid parameter for: #{filter_key}"
      end
    end
  end
end