# Copyright (c) 2017 Baidu.com, Inc. All Rights Reserved
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

# Samples for sts client.

$LOAD_PATH.unshift(File.expand_path("../../../lib", __FILE__))

require 'baidubce/services/sts/sts_client'
require 'baidubce/services/bos/bos_client'

credentials = Baidubce::Auth::BceCredentials.new(
    # "your ak",
    # "your sk"

)

sts_conf = Baidubce::BceClientConfiguration.new(
    credentials,
    "http://sts.bj.baidubce.com"
)

sts_client = Baidubce::Services::StsClient.new(sts_conf)

# log config
Baidubce::Log.set_log_file("./test.log")
Baidubce::Log.set_log_level(Logger::DEBUG)

def demo(msg)
  puts "--------- #{msg} --------"
  puts
  yield
  puts "----------- end --------------"
  puts
end

demo 'sts client' do
    acl = {
            id: '8c47a952db4444c5a097b41be3f24c94',
            accessControlList: [
                {
                    eid: 'shj',
                    service: 'bce:bos',
                    region: 'bj',
                    effect: 'Allow',
                    resource: ["bos-demo"],
                    permission: ["READ"]
                }
            ]
    }

    # puts sts_client.get_session_token(acl, 1024)
    sts_response = sts_client.get_session_token(acl)
    # durationSeconds为非int值，会使用默认的12小时作为失效时间
    # puts sts_client.get_session_token(acl, "test")
    
    # 使用获取到的ak, sk, token新建BosClient访问BOS
    sts_ak = sts_response["accessKeyId"]
    sts_sk = sts_response['secretAccessKey']
    token = sts_response['sessionToken']

    sts_credentials = Baidubce::Auth::BceCredentials.new(
        sts_ak,
        sts_sk
    )

    conf = Baidubce::BceClientConfiguration.new(
        sts_credentials,
        "http://bj.bcebos.com",
        'security_token' => token
    )

    client = Baidubce::Services::BosClient.new(conf)

    puts client.get_bucket_location('bos-demo')
end
