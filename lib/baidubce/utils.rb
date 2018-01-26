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

require_relative "http/http_headers"

module Baidubce

    class Utils

        def self.parse_url_host(config)
            endpoint = config.endpoint
            if !endpoint.include?"://"
                protocol = config.protocol.downcase
                raise "Invalid protocol #{protocol}." if protocol != "http" && protocol != 'https'
                endpoint = sprintf("%s://%s", protocol, endpoint)
            end
            parsed_endpoint = URI.parse(endpoint)
            scheme = parsed_endpoint.scheme.downcase
            raise "Invalid endpoint #{endpoint}, unsupported scheme #{scheme}." if scheme != "http" && protocol != 'https'
            host = parsed_endpoint.host
            port = parsed_endpoint.port
            host += ":#{port}" unless scheme == 'http' && port == 80 || scheme == 'http' && port == 80
            return "#{scheme}://#{host}", host
        end

        def self.append_uri(base_uri, *path_components)
            uri = [base_uri]
            path_components.reject(&:empty?)
            path_components.each { |path| uri << ERB::Util.url_encode(path)}

            if !uri.empty?
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
            if params.nil? || params.empty?
                return ''
            end
            arr = []
            params.each do |key, value|
                if !for_signature || key.downcase != Baidubce::Http::AUTHORIZATION.downcase
                    value = '' if value.nil?
                    str = ERB::Util.url_encode(key) + "=" + ERB::Util.url_encode(value)
                    arr << str
                end
            end
            arr.sort!
            arr.join("&")
        end
    end

end
