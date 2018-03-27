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

# This module provide logger utils for bce client.

require 'logger'

module Baidubce

    module Log
        DEFAULT_LOG_FILE = "./baidubce-sdk.log"
        MAX_NUM_LOG = 100
        LOG_FILE_SIZE = 10 * 1024 * 1024

        def logger
            Log.logger
        end

        # level : Logger::DEBUG | Logger::INFO | Logger::ERROR | Logger::FATAL
        def self.set_log_level(level)
            Log.logger.level = level
        end

        def self.set_log_file(file)
            @log_file = file
        end

        private

        def self.logger
            unless @logger
                @logger = Logger.new(
                    @log_file ||= DEFAULT_LOG_FILE, MAX_NUM_LOG, LOG_FILE_SIZE)
                @logger.level = Logger::INFO
            end
            @logger
        end

    end

end

