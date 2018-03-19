class BceClientException < RuntimeError
   attr_reader :message

   def initialize(message)
      @message = message
   end

end

class BceServerException < RuntimeError
   attr_reader :status_code
   attr_reader :message

   def initialize(status_code, message)
      @status_code = status_code
      @message = message
   end

end

