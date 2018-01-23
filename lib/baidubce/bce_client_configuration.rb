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

# This module defines a common configuration class for BCE.

module Baidubce

    DEFAULT_PROTOCOL = "http"
    DEFAULT_REGION = "bj"
    DEFAULT_CONNECTION_TIMEOUT_IN_MILLIS = 50 * 1000
    DEFAULT_SOCKET_TIMEOUT_IN_MILLIS = 50 * 1000
    DEFAULT_SEND_BUF_SIZE = 1024 * 1024
    DEFAULT_RECV_BUF_SIZE = 10 * 1024 * 1024

    class BceClientConfiguration
        attr_accessor :credentials, :endpoint, :protocol, :region, :connection_timeout_in_mills,
                      :socket_timeout_in_mills, :send_buf_size, :recv_buf_size, :retry_policy, :security_token

        def initialize(credentials,
                       endpoint,
                       protocol=DEFAULT_PROTOCOL,
                       region=DEFAULT_REGION,
                       connection_timeout_in_mills=DEFAULT_CONNECTION_TIMEOUT_IN_MILLIS,
                       socket_timeout_in_mills=DEFAULT_SOCKET_TIMEOUT_IN_MILLIS,
                       send_buf_size=DEFAULT_SEND_BUF_SIZE,
                       recv_buf_size=DEFAULT_RECV_BUF_SIZE,
                       retry_policy=0,
                       security_token="")

            @credentials = credentials
            @endpoint = endpoint
            @protocol = protocol
            @region = region
            @connection_timeout_in_mills = connection_timeout_in_mills
            @socket_timeout_in_mills = socket_timeout_in_mills
            @send_buf_size = send_buf_size
            @recv_buf_size = recv_buf_size
            @retry_policy = retry_policy
            @security_token = security_token
        end

    end
end
