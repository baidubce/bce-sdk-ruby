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

require_relative 'retry_policy'

module Baidubce

    DEFAULT_PROTOCOL = "http"
    DEFAULT_REGION = "bj"
    DEFAULT_OPEN_TIMEOUT_IN_MILLIS = 60 * 1000
    DEFAULT_READ_TIMEOUT_IN_MILLIS = 10 * 60 * 1000
    DEFAULT_SEND_BUF_SIZE = 1024 * 1024
    DEFAULT_RECV_BUF_SIZE = 10 * 1024 * 1024

    class BceClientConfiguration
        attr_accessor :credentials, :endpoint, :protocol, :region, :open_timeout_in_millis,
                      :read_timeout_in_millis, :send_buf_size, :recv_buf_size, :retry_policy

        def initialize(credentials,
                       endpoint,
                       options={})

            @credentials = credentials
            @endpoint = endpoint
            @protocol = options['protocol'] || DEFAULT_PROTOCOL
            @region = options['region'] || DEFAULT_REGION
            @open_timeout_in_millis = options['open_timeout_in_millis'] ||
                DEFAULT_OPEN_TIMEOUT_IN_MILLIS
            @read_timeout_in_millis = options['read_timeout_in_millis'] || DEFAULT_READ_TIMEOUT_IN_MILLIS
            @send_buf_size = options['send_buf_size'] || DEFAULT_SEND_BUF_SIZE
            @recv_buf_size = options['recv_buf_size'] || DEFAULT_RECV_BUF_SIZE
            @retry_policy = options['retry_policy'] || BackOffRetryPolicy.new
        end

    end
end
