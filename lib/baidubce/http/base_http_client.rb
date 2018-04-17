# Copyright 2017 Baidu, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
# except in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the
# License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific language governing permissions
# and limitations under the License.

# This module provide http request function for bce services.

require 'rest-client'
require 'time'
require 'objspace'
require 'fiber'

require_relative '../version'
require_relative '../exception'
require_relative '../retry_policy'
require_relative '../utils/utils'
require_relative '../utils/log'
require_relative '../bce_constants'
require_relative 'http_constants'

module Baidubce
    module Http

        class BaseHttpClient

            include Log
            # Send request to BCE services.
            def send_request(config, signer, http_method, path, params, headers, body, save_path=nil, &block)
                headers[USER_AGENT] = sprintf(
                    'bce-sdk-ruby/%s/%s/%s',
                    VERSION,
                    RUBY_VERSION,
                    RUBY_PLATFORM
                )

                should_get_new_date = headers.has_key?(BCE_DATE) ? false : true

                url, headers[HOST] = Utils.parse_url_host(config)
                url += Utils.url_encode_except_slash(path)
                query_str = Utils.get_canonical_querystring(params, false)
                url += "?#{query_str}" unless query_str.to_s.empty?

                logger.info("url: #{url}, params: #{params}")
                set_content_length_header(headers, body, &block)
                headers[STS_SECURITY_TOKEN] = config.credentials.security_token unless config.credentials.security_token.to_s.empty?

                retries_attempted = 0
                while true
                    headers[BCE_DATE] = Time.now.utc.iso8601 if should_get_new_date
                    headers[AUTHORIZATION] = signer.sign(config.credentials, http_method,
                                                         path, headers, params)

                    logger.debug("Request headers: #{headers}")
                    args = { method: http_method,
                            url: url,
                            headers: headers,
                            payload: body,
                            open_timeout: config.open_timeout_in_millis / 1000.0,
                            read_timeout: config.read_timeout_in_millis / 1000.0
                    }
                    args[:payload] = BufWriter.new(&block) if block_given?

                    begin
                        if save_path
                            logger.debug("Response save file path: #{save_path}")
                            resp_headers = {}
                            File.open(save_path, 'w+') { |f|
                                block = proc { |response|
                                    response.read_body { |chunk| f << chunk }
                                    resp_headers = response.to_hash
                                    resp_headers.each { |k, v| resp_headers[k]=v[0] }
                                    raise BceHttpException.new(response.code.to_i,
                                        resp_headers, '', 'get_object_to_file exception') if response.code.to_i > 300
                                }
                                block_arg = { block_response: block }
                                args.merge! block_arg
                                RestClient::Request.new(args).execute
                                return '', resp_headers
                            }
                        else
                            resp = RestClient::Request.new(args).execute
                            logger.debug("Response code: #{resp.code}")
                            logger.debug("Response headers: #{resp.headers.to_s}")
                            return resp.body, resp.headers
                        end
                    rescue BceHttpException, RestClient::ExceptionWithResponse => err
                        logger.debug("ExceptionWithResponse: #{err.http_code}, #{err.http_body}, #{err.http_headers}, #{err.message}")
                        if config.retry_policy.should_retry(err.http_code, retries_attempted)
                            delay_in_millis = config.retry_policy.get_delay_before_next_retry_in_millis(retries_attempted)
                            sleep(delay_in_millis / 1000.0)
                        else
                            request_id = err.http_headers[:x_bce_request_id]
                            if err.is_a?(BceHttpException)
                                err.http_body = File.read(save_path)
                                request_id = err.http_headers['x-bce-request-id']
                            end
                            msg = err.http_body
                            if err.http_body.empty?
                                msg = "{\"code\":\"#{err.http_code}\",\"message\":\"#{err.message}\",\"requestId\":\"#{request_id}\"}"
                            end
                            raise BceServerException.new(err.http_code, msg)
                        end
                    end

                    retries_attempted += 1
                end

            end

            def set_content_length_header(headers, body, &block)
                unless block_given?
                    if body.to_s.empty?
                        headers[CONTENT_LENGTH] = 0
                    elsif body.instance_of?(String)
                        body = body.encode('UTF-8') if body.encoding.name != 'UTF-8'
                        headers[CONTENT_LENGTH] = body.bytesize
                    elsif body.instance_of?(File)
                        headers[CONTENT_LENGTH] = body.size()
                    else
                        headers[CONTENT_LENGTH] = ObjectSpace.memsize_of(body)
                    end
                end
            end

            class BufWriter

                def initialize()
                    @buffer = ""
                    @producer = Fiber.new { yield self if block_given? }
                    @producer.resume
                end

                def read(bytes = nil, outbuf = nil)
                    ret = ""
                    while true
                        if bytes
                            fail if bytes < 0
                            piece = @buffer.slice!(0, bytes)
                            if piece
                                ret << piece
                                bytes -= piece.size
                                break if bytes == 0
                            end
                        else
                            ret << @buffer
                            @buffer.clear
                        end

                        if @producer.alive?
                            @producer.resume
                        else
                            break
                        end
                    end

                    if outbuf
                        outbuf.clear
                        outbuf << ret
                    end

                    return nil if ret.empty? && !bytes.nil? && bytes > 0
                    ret
                end

                def write(chunk)
                    @buffer << chunk.to_s
                    Fiber.yield
                    self
                end

                alias << write

                def closed?
                    false
                end

                def close
                end

                def inspect
                    "@buffer: " + @buffer[0, 32].inspect + "...#{@buffer.size} bytes"
                end
            end
        end
    end
end

module RestClient
  module Payload
    class Base
      def headers
          ({'content-length' => size.to_s} if size) || {}
      end
    end
  end
end
