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

# This module provide base class for BCE service clients.

require_relative 'auth/bce_v1_signer'
require_relative 'auth/bce_credentials'
require_relative 'http/base_http_client'
require_relative 'bce_client_configuration'

module Baidubce

    class BceBaseClient

        def initialize(config, service_id="", region_supported=true)
            @config = config
            @service_id = service_id
            @region_supported = region_supported
            @config.endpoint = compute_endpoint if @config.endpoint.nil?
            @http_client = Baidubce::Http::BaseHttpClient.new()
            @signer = Baidubce::Auth::BceV1Signer.new()
        end

        def compute_endpoint
            return @config.endpoint if !@config.endpoint.nil? && !@config.endpoint.empty?
            if @region_supported
                return sprintf('%s://%s.%s.%s',
                               @config.protocol,
                               @service_id,
                               @config.region,
                               DEFAULT_SERVICE_DOMAIN)
            else
                return sprintf('%s://%s.%s',
                               @config.protocol,
                               @service_id,
                               DEFAULT_SERVICE_DOMAIN)
            end

        end
    end
end
