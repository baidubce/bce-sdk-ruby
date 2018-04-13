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

# This module provide some utils for bce client.

require "ERB"
require "uri"
require 'json'
require 'digest/md5'

require_relative "../http/http_constants"

module Baidubce

    class Utils

        # parse protocol, host, port from endpoint in config.
        def self.parse_url_host(config)
            endpoint = config.endpoint
            unless endpoint.include?"://"
                protocol = config.protocol.downcase
                raise "Invalid protocol #{protocol}." if protocol != "http" && protocol != 'https'
                endpoint = sprintf("%s://%s", protocol, endpoint)
            end
            parsed_endpoint = URI.parse(endpoint)
            scheme = parsed_endpoint.scheme.downcase
            raise "Invalid endpoint #{endpoint}, unsupported scheme #{scheme}." if scheme != "http" && protocol != 'https'
            host = parsed_endpoint.host
            port = parsed_endpoint.port
            host += ":#{port}" unless scheme == 'http' && port == 80 || scheme == 'https' && port == 443
            return "#{scheme}://#{host}", host
        end

        # Append path_components to the end of base_uri in order.
        def self.append_uri(base_uri, *path_components)
            uri = [base_uri]
            path_components.reject(&:empty?)
            path_components.each { |path| uri << path }

            unless uri.empty?
                uri[0].gsub!(/([\/]*$)/, '')
                uri[-1].gsub!(/(^[\/]*)/, '')
                uri.each { |u| u.gsub!(/(^[\/]*)|([\/]*$)/, '') }
            end

            uri.join("/")
        end

        def self.url_encode_except_slash(path)
             encoded_path = ERB::Util.url_encode(path)
             encoded_path.gsub('%2F', '/')
        end

        def self.get_canonical_querystring(params, for_signature)
            return '' if params.nil? || params.empty?

            arr = []
            params.each do |key, value|
                if !for_signature || key.downcase != Http::AUTHORIZATION.downcase
                    value = '' if value.nil?
                    str = ERB::Util.url_encode(key) + "=" + ERB::Util.url_encode(value)
                    arr << str
                end
            end
            arr.sort!
            arr.join("&")
        end

        def self.get_md5_from_file(file_name, buf_size=8192)

            md5 = Digest::MD5.new
            buf = ""
            File.open(file_name, 'rb') do |io|
                md5.update(buf) while io.read(buf_size, buf)
            end
            md5.base64digest
        end

        def self.generate_response(headers, body)
            return generate_headers(headers) if body.to_s.empty?
            ret = JSON.parse(body)
            return ret
            rescue JSON::ParserError
            return body
        end

        def self.generate_headers(headers)
            user_metadata = {}

            resp_headers = headers.inject({}) do |ret, (k, v)|
                key = k.to_s.tr('_', '-')
                if key.start_with?(Http::BCE_USER_METADATA_PREFIX)
                    key.slice!(Http::BCE_USER_METADATA_PREFIX)
                    user_metadata[key] = v
                elsif key.downcase == 'etag'
                    ret[key] = v.delete('\"')
                elsif key.downcase == 'content-length'
                    ret[key] = v.to_i
                else
                    ret[key] = v
                end
                ret
            end
            resp_headers['user-metadata'] = user_metadata unless user_metadata.empty?
            resp_headers
        end

    end

end
