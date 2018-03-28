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

require_relative '../version'
require_relative '../exception'
require_relative '../retry_policy'
require_relative '../utils/utils'
require_relative '../utils/log'
require_relative '../bce'
require_relative 'http_constants'

module Baidubce
    module Http

        class BaseHttpClient

            include Log
            # Send request to BCE services.
            def send_request(config, signer, http_method, path, params, headers, body)
                headers[USER_AGENT] = sprintf(
                    'bce-sdk-ruby/%s/%s/%s',
                    VERSION,
                    RUBY_VERSION,
                    RUBY_PLATFORM
                )

                should_get_new_date = false
                should_get_new_date = true unless headers.has_key?(BCE_DATE)

                url, host = Utils.parse_url_host(config)
                headers[HOST] = host
                url = url + Utils.url_encode_except_slash(path)
                query_str = Utils.get_canonical_querystring(params, false)
                url += "?#{query_str}" unless query_str.to_s.empty?

                logger.info("url: #{url}, params: #{params}")
                if body.to_s.empty?
                    headers[CONTENT_LENGTH] = 0
                elsif body.instance_of?(String)
                    body = body.encode('UTF-8') if body.encoding.name != 'UTF-8'
                    headers[CONTENT_LENGTH] = body.length
                elsif body.instance_of?(File)
                    headers[CONTENT_LENGTH] = body.size()
                else
                    headers[CONTENT_LENGTH] = ObjectSpace.memsize_of(body)
                end

                headers[STS_SECURITY_TOKEN] = config.security_token unless config.security_token.to_s.empty?

                retries_attempted = 0
                while true
                    headers[BCE_DATE] = Time.now.utc.iso8601 if should_get_new_date
                    headers[AUTHORIZATION] = signer.sign(config.credentials, http_method,
                                                         path, headers, params)

                    logger.debug("Request headers: #{headers}")
                    @request = RestClient::Request.new(
                        method: http_method,
                        url: url,
                        headers: headers,
                        payload: body,
                        open_timeout: config.open_timeout_in_millis / 1000.0,
                        read_timeout: config.read_timeout_in_millis / 1000.0
                    )

                    begin
                        resp = @request.execute
                        logger.debug("Response code: #{resp.code}")
                        logger.debug("Response headers: #{resp.headers.to_s}")
                        # logger.debug("Response body: #{resp.body}")
                        return resp.body, resp.headers
                    rescue RestClient::ExceptionWithResponse => err
                        logger.debug("ExceptionWithResponse: #{err.http_code}, #{err.http_body}, #{err.message}")
                        if config.retry_policy.should_retry(err, retries_attempted)
                            delay_in_millis = config.retry_policy.get_delay_before_next_retry_in_millis(
                                err, retries_attempted)
                            sleep(delay_in_millis / 1000.0)
                        else
                            raise BceServerException.new(err.http_code, err.message + ", " + err.http_body)
                        end
                    end

                    retries_attempted += 1
                end

            end

        end
    end
end
