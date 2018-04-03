class BceClientException < RuntimeError
   attr_accessor :message

   def initialize(message)
      @message = message
   end

end

class BceServerException < RuntimeError
   attr_accessor :status_code
   attr_accessor :message

   def initialize(status_code, message)
      @status_code = status_code
      @message = message
   end

end

class BceHttpException < RuntimeError
    attr_accessor :http_code
    attr_accessor :http_body
    attr_accessor :message

    def initialize(http_code, http_body, message)
        @http_code = http_code
        @http_body = http_body
        @message = message
    end

end
