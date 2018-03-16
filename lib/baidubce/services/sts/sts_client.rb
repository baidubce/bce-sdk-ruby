# Copyright (c) 2014 Baidu.com, Inc. All Rights Reserved
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

# This module provides a client for STS.

require 'json'

require_relative '../../bce_base_client'
require_relative '../../utils'
require_relative '../../bce'
require_relative '../../http/http_methods'
require_relative '../../http/http_headers'
require_relative '../../http/http_content_types'

module Baidubce
    module Services

        class StsClient < Baidubce::BceBaseClient

            STS_URL_PREFIX = "/";
            GET_SESSION_TOKEN_VERSION = "v1";
            GET_SESSION_TOKEN_PATH = "sessionToken";

            def get_session_token(acl, duration_seconds=nil)
                params = duration_seconds.nil? ? {} : { durationSeconds: duration_seconds }
                headers = { Baidubce::Http::CONTENT_TYPE => Baidubce::Http::JSON }
                body = acl.to_json
                path = Baidubce::Utils.append_uri(STS_URL_PREFIX, GET_SESSION_TOKEN_VERSION, GET_SESSION_TOKEN_PATH)
                @http_client.send_request(@config, @signer, Baidubce::Http::POST, path, params, headers, body)
            end

        end
    end
end

