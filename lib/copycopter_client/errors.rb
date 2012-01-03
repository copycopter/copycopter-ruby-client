module CopycopterClient
  # Raised when an error occurs while contacting the Copycopter server. This is
  # raised by {Client} and generally rescued by {Cache}. The application will
  # not encounter this error. Polling will continue even if this error is raised.
  class ConnectionError < StandardError
  end
end
