# Copyright (c) 2017 Baidu.com, Inc. All Rights Reserved
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

# This module provides authentication functions for bce services.

require 'time'
require 'openssl'

require_relative '../utils'

module Baidubce
    module Auth
        class BceV1Signer

            def get_canonical_headers(headers, headers_to_sign = nil)
                default = false
                if headers_to_sign.to_a.empty?
                    default = true
                    headers_to_sign = ["host", "content-md5", "content-length", "content-type"]
                end

                ret_arr = []
                headers_arr = []
                headers.each do |key, value|
                    next if value.to_s.strip.empty?
                    if headers_to_sign.include?(key.downcase) ||
                            (default && key.downcase.to_s.start_with?(Baidubce::Http::BCE_PREFIX))
                        str = ERB::Util.url_encode(key.downcase) + ":" + ERB::Util.url_encode(value.to_s.strip)
                        ret_arr << str
                        headers_arr << key.downcase
                    end
                end
                ret_arr.sort!
                headers_arr.sort!
                return ret_arr.join("\n"), headers_arr
            end

            def get_canonical_uri_path(path)
                return '/' if path.to_s.empty?
                encoded_path = Baidubce::Utils.url_encode_except_slash(path)
                return path[0] == '/' ? encoded_path : '/' + encoded_path
            end

            # Create the authorization.
            def sign(credentials, http_method, path, headers, params,
                     timestamp=nil, expiration_in_seconds=1800, headers_to_sign=nil)

                timestamp = Time.now.to_i if timestamp.nil?
                sign_key_info = sprintf('bce-auth-v1/%s/%s/%d',
                                        credentials.access_key_id,
                                        Time.at(timestamp).utc.iso8601,
                                        expiration_in_seconds)
                sign_key = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'),
                                                   credentials.secret_access_key, sign_key_info)
                canonical_uri = get_canonical_uri_path(path)
                canonical_querystring = Baidubce::Utils.get_canonical_querystring(params, true)
                canonical_headers, headers_to_sign = get_canonical_headers(headers, headers_to_sign)
                canonical_request = [http_method, canonical_uri, canonical_querystring, canonical_headers].join("\n")
                signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'),
                                                    sign_key, canonical_request)

                headers_str = headers_to_sign.join(';') unless headers_to_sign.nil?
                sign_key_info + '/' + headers_str + '/' + signature
            end
        end
    end
end
