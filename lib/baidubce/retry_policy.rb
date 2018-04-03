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

# This module defines a retry policy for BCE.

require_relative 'utils/log'

module Baidubce

    # A policy that never retries.
    class NoRetryPolicy

        # Always returns False.
        def should_retry(http_code, retries_attempted)
            false
        end

        # Always returns 0.
        def get_delay_before_next_retry_in_millis(retries_attempted)
            0
        end

    end

    # A policy that retries with exponential back-off strategy.
    # This policy will keep retrying until the maximum number of retries is reached. The delay time
    # will be a fixed interval for the first time then 2 * interval for the second, 4 * internal for
    # the third, and so on. In general, the delay time will be 2^number_of_retries_attempted*interval.

    # When a maximum of delay time is specified, the delay time will never exceed this limit.
    class BackOffRetryPolicy

        include Log

        attr_accessor :max_error_retry, :max_delay_in_millis, :base_interval_in_millis

        def initialize(max_error_retry=3,
                       max_delay_in_millis=20 * 1000,
                       base_interval_in_millis=300)

            max_error_retry_msg = "max_error_retry should be a non-negative integer."
            max_delay_in_millis_msg = "max_delay_in_millis should be a non-negative integer."
            raise BceClientException.new(max_error_retry_msg) if max_error_retry < 0
            raise BceClientException.new(max_delay_in_millis_msg) if max_delay_in_millis < 0
            @max_error_retry = max_error_retry
            @max_delay_in_millis = max_delay_in_millis
            @base_interval_in_millis = base_interval_in_millis
        end

        # Return true if the http client should retry the request.
        def should_retry(http_code, retries_attempted)

            # stop retrying when the maximum number of retries is reached
            return false if retries_attempted >= @max_error_retry

            # Only retry on a subset of service exceptions
            if http_code >= 500 && http_code != 501
                logger.debug('Retry for server error.')
                return true
            end
            if http_code == 408
                logger.debug('Retry for request timeout.')
                return true
            end

            return false
        end

        # Returns the delay time in milliseconds before the next retry.
        def get_delay_before_next_retry_in_millis(retries_attempted)
            return 0 if retries_attempted < 0
            delay_in_millis = (1 << retries_attempted) * @base_interval_in_millis
            return @max_delay_in_millis if delay_in_millis > @max_delay_in_millis
            return delay_in_millis
        end
    end

end
