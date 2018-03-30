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

class BceHttpException < RuntimeError
    attr_accessor :http_code
    attr_accessor :http_body
    attr_writer :message

    def initialize(http_code, http_body, message)
        @http_code = http_code
        @http_body = http_body
        @message = message
    end

end
