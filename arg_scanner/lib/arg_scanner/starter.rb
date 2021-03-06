unless ENV["ARG_SCANNER_ENABLE_STATE_TRACKER"].nil?
  require_relative 'state_tracker'
  ArgScanner::StateTracker.new
end

unless ENV["ARG_SCANNER_ENABLE_RETURN_TYPE_TRACKER"].nil?
  require_relative 'return_type_tracker'
  ArgScanner::ReturnTypeTracker.new
end


unless ENV["ARG_SCANNER_ENABLE_TYPE_TRACKER"].nil?
  require_relative 'arg_scanner'
  require_relative 'type_tracker'

  # instantiating type tracker will enable calls tracing and sending the data
  ArgScanner::TypeTracker.instance
end



