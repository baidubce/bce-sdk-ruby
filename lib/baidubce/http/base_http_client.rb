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
require_relative '../utils'
require_relative '../exception'
require_relative '../log'
require_relative 'http_headers'

module Baidubce
    module Http

        class BaseHttpClient

            # Send request to BCE services.
            def send_request(config, signer, http_method, path, params, headers, body)
                headers[Baidubce::Http::USER_AGENT] = sprintf(
                    'bce-sdk-ruby/%s/%s/%s',
                    Baidubce::VERSION,
                    RUBY_VERSION,
                    RUBY_PLATFORM
                )

                headers[Baidubce::Http::BCE_DATE] = Time.now.utc.iso8601 unless headers.has_key?(Baidubce::Http::BCE_DATE)

                url, host = Baidubce::Utils.parse_url_host(config)
                headers[Baidubce::Http::HOST] = host
                url = url + Baidubce::Utils.url_encode_except_slash(path)
                query_str = Baidubce::Utils.get_canonical_querystring(params, false)
                url += "?#{query_str}" unless query_str.to_s.empty?

                 Baidubce::Log.logger.info("url: #{url}, params: #{params}")
                if body.to_s.empty?
                    headers[Baidubce::Http::CONTENT_LENGTH] = 0
                elsif body.instance_of?(String)
                    body = body.encode('UTF-8') if body.encoding.name != 'UTF-8'
                    headers[Baidubce::Http::CONTENT_LENGTH] = body.length
                elsif body.instance_of?(File)
                    headers[Baidubce::Http::CONTENT_LENGTH] = body.size()
                else
                    headers[Baidubce::Http::CONTENT_LENGTH] = ObjectSpace.memsize_of(body)
                end
                headers[Baidubce::Http::AUTHORIZATION] = signer.sign(config.credentials, http_method,
                                                     path, headers, params)

                Baidubce::Log.logger.debug("Request headers: #{headers}")
                @request = RestClient::Request.new(
                    method: http_method,
                    url: url,
                    headers: headers,
                    payload: body,
                    open_timeout: config.connection_timeout_in_millis,
                    read_timeout: config.socket_timeout_in_millis
                )
                # handle http response, body and header
                @request.execute do |resp, &block|
                    Baidubce::Log.logger.debug("Response body: #{resp.body}")
                    Baidubce::Log.logger.debug("Response headers: #{resp.headers.to_s}")
                    if resp.code >= 300
                        raise BceServerException.new(resp.code, resp.body)
                    else
                        return resp.body, resp.headers
                    end
                end
            end

        end
    end
end
