# Copyright 2017 Baidu, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

# Samples for bos client.

$LOAD_PATH.unshift(File.expand_path("../../../lib", __FILE__))

require 'baidubce/services/bos/bos_client'

include Baidubce

# debug
credentials = Auth::BceCredentials.new(
    # "your ak",
    # "your sk"
)

conf = BceClientConfiguration.new(
    credentials,
    "http://bj.bcebos.com"
)

client = Services::BosClient.new(conf)

bucket_name = "ruby-test-bucket"

# log config
Log.set_log_file("./test.log")
Log.set_log_level(Logger::DEBUG)

def demo(msg)
  puts "--------- #{msg} --------"
  puts
  yield
  puts "----------- end --------------"
  puts
end

demo "list buckets" do
    puts client.list_buckets()
end

demo "delete bucket" do
    # Only can delete the bucket you are owner and it is empty.
    # puts client.delete_bucket("test-bucket") if client.does_bucket_exist("test-bucket")
end

demo "create bucket" do
    puts client.create_bucket(bucket_name) unless client.does_bucket_exist(bucket_name)
end

demo "get bucket location" do
    puts client.get_bucket_location(bucket_name)
end

demo "set/get bucket acl" do
    client.set_bucket_canned_acl(bucket_name, "private")
    puts "before set bucket acl"
    puts client.get_bucket_acl(bucket_name)
    acl = [{'grantee' => [{'id' => 'b124deeaf6f641c9ac27700b41a350a8'},
                          {'id' => 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'}],
    'permission' => ['FULL_CONTROL']}]

    client.set_bucket_acl(bucket_name, acl)
    puts "after set bucket acl"
    puts client.get_bucket_acl(bucket_name)
end

demo "put/get bucket lifecycle" do
    puts "before put bucket lifecycle"
    # TODO 404
    # puts client.get_bucket_lifecycle(bucket_name)
    lifecycle = [
        {
            id: "rule-id",
            status: "enabled",
            resource: [
                "ruby-test-bucket/prefix/*"
            ],
            condition: {
                time: {
                    dateGreaterThan: "2016-09-07T00:00:00Z"
                }
            },
            action: {
                name: "DeleteObject"
            }
        }
    ]

    client.put_bucket_lifecycle(bucket_name, lifecycle)
    puts "after put bucket lifecycle"
    puts client.get_bucket_lifecycle(bucket_name)

    puts "after delete bucket lifecycle"
    puts client.delete_bucket_lifecycle(bucket_name)
end

demo "put/get bucket cors" do
    puts "before put bucket cors"
    # TODO 404
    # puts client.get_bucket_cors(bucket_name)
    cors = [
        {
            allowedOrigins: [
                "http://www.example.com",
                "www.example2.com"
            ],
            allowedMethods: [
                "GET",
                "HEAD",
                "DELETE"
            ],
            allowedHeaders: [
                "Authorization",
                "x-bce-test",
                "x-bce-test2"
            ],
            allowedExposeHeaders: [
                "user-custom-expose-header"
            ],
            maxAgeSeconds: 3600
        }
    ]

    client.put_bucket_cors(bucket_name, cors)
    puts "after put bucket cors"
    puts client.get_bucket_cors(bucket_name)

    puts "after delete bucket cors"
    puts client.delete_bucket_cors(bucket_name)
end

demo "put/get bucket logging" do
    puts "before put bucket logging"
    # puts client.get_bucket_logging(bucket_name)

    client.put_bucket_logging(bucket_name, bucket_name)
    puts "after put bucket logging"
    puts client.get_bucket_logging(bucket_name)

    puts "after delete bucket logging"
    puts client.delete_bucket_logging(bucket_name)
end

demo "put/get bucket storage_class" do
    puts "before put bucket storage_class"
    puts client.get_bucket_storageclass(bucket_name)

    client.put_bucket_storageclass(bucket_name, "STANDARD")
    puts "after put bucket storage_class"
    puts client.get_bucket_storageclass(bucket_name)

end

demo "put object" do

    user_metadata = { "key1" => "value1" }
    options = { Http::CONTENT_TYPE => 'string',
                "key1" => "value1",
                'Content-Disposition' => 'inline',
                'user_metadata' => user_metadata
    }

    client.put_object_from_string(bucket_name, "obj.txt", "obj", options)
    puts client.get_object_as_string(bucket_name, "obj.txt")
    client.get_object_to_file(bucket_name, "obj.txt", "obj_file.txt")

    # put cold storage class object
    client.put_object_from_file(bucket_name, "obj_cold.txt", "obj.txt", 'x-bce-storage-class' => 'COLD')
    puts client.get_object_as_string(bucket_name, "obj_cold.txt")
end

demo "list objects" do

    options = { prefix: 'obj',
                maxKeys: 10,
                delimiter: '',
                marker: ''
    }
    puts client.list_objects(bucket_name, options)
end

demo "get object" do
    puts client.put_object_from_string(bucket_name, "obj.txt", "object%123456")
    puts client.get_object_as_string(bucket_name, "obj.txt", [0,2])
    puts client.get_object_meta_data(bucket_name, "obj.txt")
end

demo "append object" do
    puts client.append_object_from_string(bucket_name, "append.txt", "append")
    puts client.get_object_as_string(bucket_name, "append.txt")
    puts client.append_object_from_string(bucket_name, "append.txt", "append", offset: 6)
    puts client.get_object_as_string(bucket_name, "append.txt")
end

demo "delete object" do
    object_key = "delete_obj.txt"
    puts client.put_object_from_string(bucket_name, object_key, "object%123456")
    puts client.get_object_as_string(bucket_name, object_key)
    puts client.delete_object(bucket_name, object_key)
end

demo "delete multiple objects" do
    object_list = ["multi_obj0.txt", "multi_obj1.txt","multi_obj2.txt"]
    object_list.each { |key| client.put_object_from_string(bucket_name, key, "content") }
    # object_list << "other.txt"
    puts client.delete_multiple_objects(bucket_name, object_list)
end

demo "generate pre signed url" do

    options = { 'expiration_in_seconds' => 60,
                'timestamp' => Time.now.to_i,
                'headers_to_sign' => ["host", "content-md5", "content-length"]
    }

    puts client.generate_pre_signed_url(bucket_name, 'obj.txt', options)
end

demo "copy object" do
    user_metadata = { "key1" => "value1" }

    options = { Http::CONTENT_TYPE => 'string',
                Http::CONTENT_MD5 => 'kkkkkkkk',
                'user_metadata' => user_metadata
    }
    client.copy_object(bucket_name, "obj.txt", bucket_name, 'obj2.txt', options)
    puts client.get_object_meta_data(bucket_name, "obj2.txt")
end

demo "set/get/delete object acl" do
    # puts "before set object acl"
    key = "obj.txt"
    # client.get_object_acl(bucket_name, key)
    acl = [{'grantee' => [{'id' => 'b124deeaf6f641c9ac27700b41a350a8'},
                          {'id' => 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'}],
    'permission' => ['FULL_CONTROL']}]

    puts "after set object canned x-bce-acl: private"
    client.set_object_canned_acl(bucket_name, key, 'x-bce-acl' => 'private')
    puts client.get_object_acl(bucket_name, key)

    puts "after set object canned x-bce-grant-read"
    id_permission = "id=\"6c47a952db4444c5a097b41be3f24c94\",id=\"8c47a952db4444c5a097b41be3f24c94\",id=\"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\""
    client.set_object_canned_acl(bucket_name, key, 'x-bce-grant-read' => id_permission)
    puts client.get_object_acl(bucket_name, key)

    puts "after set object body acl"
    client.set_object_acl(bucket_name, key, acl)
    puts client.get_object_acl(bucket_name, key)

end

# create a 18MB file for multi upload
multi_file = "/Users/xiaoyong/Desktop/bos/baidu/bce-sdk/ruby/baidubce-sdk/multi_upload.txt"

demo "multi-upload" do
    # step 1: init multi-upload
    key = "multi_file"
    upload_id = client.initiate_multipart_upload(bucket_name, key)["uploadId"]
    # step 2: upload file part by part
    left_size = File.open(multi_file, "r").size()
    offset = 0
    part_number = 1
    part_list = []

    while left_size > 0 do
        part_size = 5 * 1024 * 1024
        if left_size < part_size
            part_size = left_size
        end

        puts "offset: #{offset}, part_number: #{part_number}, part_list: #{part_list}, left_size: #{left_size}, part_size: #{part_size}"
        response = client.upload_part_from_file(
            bucket_name, key, upload_id, part_number, part_size, multi_file, offset)
        left_size -= part_size
        offset += part_size
        # your should store every part number and etag to invoke complete multi-upload
        part_list << {
            "partNumber" => part_number,
            "eTag" => response[:etag]
        }
        part_number += 1
    end

    # list parts
    puts "------------------ list parts ---------------"
    puts client.list_parts(bucket_name, key, upload_id)

    # SuperFile step 3: complete multi-upload
    user_metadata = { "key1" => "value1" }
    options = {
        'user_metadata' => user_metadata
    }

    client.complete_multipart_upload(bucket_name, key, upload_id, part_list, options)

end

demo "multi-copy" do
    # step 1: init multi-upload
    key = "multi_file"
    upload_id = client.initiate_multipart_upload(bucket_name, key+"_copy")["uploadId"]
    # step 2: copy a object part by part
    left_size = client.get_object_meta_data(bucket_name, key)[:content_length].to_i
    offset = 0
    part_number = 1
    part_list = []

    while left_size > 0 do
        part_size = 5 * 1024 * 1024
        if left_size < part_size
            part_size = left_size
        end

        puts "offset: #{offset}, part_number: #{part_number}, part_list: #{part_list}, left_size: #{left_size}, part_size: #{part_size}"
        response = client.upload_part_copy(
            bucket_name, key, bucket_name, key+"_copy", upload_id, part_number, part_size, offset)
        puts response
        left_size -= part_size
        offset += part_size
        # your should store every part number and etag to invoke complete multi-upload
        part_list << {
            "partNumber" => part_number,
            "eTag" => response["eTag"]
        }
        part_number += 1
    end

    # list parts
    puts "------------------ list parts ---------------"
    puts client.list_parts(bucket_name, key+"_copy", upload_id)

    # SuperFile step 3: complete multi-upload

    user_metadata = { "key1" => "value1" }
    options = {
        'user_metadata' => user_metadata
    }
    client.complete_multipart_upload(bucket_name, key+"_copy", upload_id, part_list, options)
end

demo "abort-multi-upload" do
    key = "multi_file"
    upload_id_abort = client.initiate_multipart_upload(bucket_name, key + "_abort")["uploadId"]

    # list multi-uploads
    puts "------------------ list multi-uploads ---------------"
    puts client.list_multipart_uploads(bucket_name)

    # abort multi-upload
    client.abort_multipart_upload(bucket_name, key + "_abort", upload_id_abort)
end
