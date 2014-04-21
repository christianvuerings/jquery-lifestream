module Errors
  # Use to raise errors caused by invalid client interactions.
  # Examples include requests with invalid parameters, or requests that are unauthenticated or unauthorized.
  class ClientError < StandardError
  end
end
