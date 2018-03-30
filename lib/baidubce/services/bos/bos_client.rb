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

# This module provides a client class for BOS.

require 'mimemagic'

require_relative '../../bce_base_client'

module Baidubce
    module Services

        class BosClient < BceBaseClient

            # List buckets of user.
            # returns all buckets owned by the user.
            def list_buckets()
                send_request(GET)
            end

            # Create bucket with specific name.
            def create_bucket(bucket_name)
                send_request(PUT, bucket_name)
            end

            # Delete bucket with specific name.
            def delete_bucket(bucket_name)
                send_request(DELETE, bucket_name)
            end

            # Check whether there is a bucket with specific name.
            def does_bucket_exist(bucket_name)
                begin
                    send_request(HEAD, bucket_name)
                rescue BceServerException => e
                    return false if e.status_code == 404
                    return true if e.status_code == 403
                end
                true
            end

            # Get the region which the bucket located in.
            # returns region of the bucket(bj/gz/sz).
            def get_bucket_location(bucket_name)
                params = { location: "" }
                resp = send_request(GET, bucket_name, params)
                resp['locationConstraint']
            end

            # Get Access Control Level of bucket.
            def get_bucket_acl(bucket_name)
                params = { acl: "" }
                send_request(GET, bucket_name, params)
            end

            # Set Access Control Level of bucket by body.
            def set_bucket_acl(bucket_name, acl)
                params = { acl: "" }
                headers = { CONTENT_TYPE => JSON_TYPE }
                body = { accessControlList: acl }.to_json
                send_request(PUT, bucket_name, params, "", headers, body)
            end

            # Set Access Control Level of bucket by headers.
            def set_bucket_canned_acl(bucket_name, canned_acl)
                params = { acl: "" }
                headers = {BCE_ACL => canned_acl}
                send_request(PUT, bucket_name, params, "", headers)
            end

            # Put Bucket Lifecycle.
            def put_bucket_lifecycle(bucket_name, rules)
                params = { lifecycle: "" }
                headers = { CONTENT_TYPE => JSON_TYPE }
                body = { rule: rules }.to_json
                send_request(PUT, bucket_name, params, "", headers, body)
            end

            # Gut Bucket Lifecycle.
            def get_bucket_lifecycle(bucket_name)
                params = { lifecycle: "" }
                send_request(GET, bucket_name, params)
            end

            # Delete Bucket Lifecycle.
            def delete_bucket_lifecycle(bucket_name)
                params = { lifecycle: "" }
                send_request(DELETE, bucket_name, params)
            end

            # Put Bucket Storageclass.
            def put_bucket_storageclass(bucket_name, storage_class)
                params = { storageClass: "" }
                headers = { CONTENT_TYPE => JSON_TYPE }
                body = { storageClass: storage_class }.to_json
                send_request(PUT, bucket_name, params, "", headers, body)
            end

            # Get Bucket Storageclass.
            def get_bucket_storageclass(bucket_name)
                params = { storageClass: "" }
                send_request(GET, bucket_name, params)
            end

            # Put Bucket Cors.
            def put_bucket_cors(bucket_name, cors_configuration)
                params = { cors: "" }
                headers = { CONTENT_TYPE => JSON_TYPE }
                body = { corsConfiguration: cors_configuration }.to_json
                send_request(PUT, bucket_name, params, "", headers, body)
            end

            # Get Bucket Cors.
            def get_bucket_cors(bucket_name)
                params = { cors: "" }
                send_request(GET, bucket_name, params)
            end

            # Delete Bucket Cors.
            def delete_bucket_cors(bucket_name)
                params = { cors: "" }
                send_request(DELETE, bucket_name, params)
            end

            # Put Bucket Logging.
            def put_bucket_logging(source_bucket, target_bucket, target_prefix="")
                params = { logging: "" }
                headers = { CONTENT_TYPE => JSON_TYPE }
                body = { targetBucket: target_bucket, targetPrefix: target_prefix }.to_json
                send_request(PUT, source_bucket, params, "", headers, body)
            end

            # Get Bucket Logging.
            def get_bucket_logging(bucket_name)
                params = { logging: "" }
                send_request(GET, bucket_name, params)
            end

            # Delete Bucket Logging.
            def delete_bucket_logging(bucket_name)
                params = { logging: "" }
                send_request(DELETE, bucket_name, params)
            end

            # Get Object Information of bucket.
            def list_objects(bucket_name, options={})
                params = { maxKeys: 1000 }
                params.merge! options
                send_request(GET, bucket_name, params)
            end

            def get_object(bucket_name, key, range, save_path=nil)
                headers = range.nil? ? {} : get_range_header_dict(range)
                send_request(GET, bucket_name, {}, key, headers, "", save_path)
            end

            # Get Content of Object and Put Content to String.
            def get_object_as_string(bucket_name, key, range=nil)
                get_object(bucket_name, key, range)
            end

            # Get Content of Object and Put Content to File.
            def get_object_to_file(bucket_name, key, save_path, range=nil)
                get_object(bucket_name, key, range, save_path)
            end

            # Put an appendable object to BOS or add content to an appendable object.
            def append_object(bucket_name, key, data, offset, content_md5, content_length, options={})
                if content_length > MAX_APPEND_OBJECT_LENGTH
                    raise BceClientException.new("Object length should be less than
                        #{MAX_APPEND_OBJECT_LENGTH}. Use multi-part upload instead.")
                end
                params = { append: "" }
                params[:offset] = offset unless offset.nil?
                headers = {
                    CONTENT_MD5 => content_md5,
                    CONTENT_LENGTH => content_length,
                }
                headers.merge! options
                populate_headers_with_user_metadata(headers) unless headers['user_metadata'].nil?
                send_request(POST, bucket_name, params, key, headers, data)
            end

            # Create an appendable object and put content of string to the object
            # or add content of string to an appendable object.
            def append_object_from_string(bucket_name, key, data, options={})
                data_md5 = Digest::MD5.base64digest(data)
                append_object(bucket_name, key, data, options['offset'], data_md5, data.length, options)
            end

            # Put object to BOS.
            def put_object(bucket_name, key, data, content_md5, content_length, options)
                if content_length > MAX_PUT_OBJECT_LENGTH
                    raise BceClientException.new("Object length should be less than
                        #{MAX_PUT_OBJECT_LENGTH}. Use multi-part upload instead.")
                end

                headers = {
                    CONTENT_MD5 => content_md5,
                    CONTENT_LENGTH => content_length,
                }
                headers.merge! options
                populate_headers_with_user_metadata(headers) unless headers['user_metadata'].nil?
                send_request(PUT, bucket_name, {}, key, headers, data)
            end

            # Create object and put content of string to the object.
            def put_object_from_string(bucket_name, key, data, options={})
                data_md5 = Digest::MD5.base64digest(data)
                put_object(bucket_name, key, data, data_md5, data.length, options)
            end

            # Put object and put content of file to the object.
            def put_object_from_file(bucket_name, key, file_name, options={})
                content_type = MimeMagic.by_path(file_name).type
                { CONTENT_TYPE => content_type }.merge! options
                data_md5 = Utils.get_md5_from_file(file_name, @config.recv_buf_size)
                data = File.open(file_name)
                put_object(bucket_name, key, data, data_md5, data.size, options)
            end

            # Get an authorization url with expire time.
            def generate_pre_signed_url(bucket_name, key, options={})
                headers = options['headers'].nil? ? {} : options['headers']
                params = options['params'].nil? ? {} : options['params']

                path = Utils.append_uri("/", bucket_name, key)
                url, host = Utils.parse_url_host(@config)
                headers[HOST] = host
                params[AUTHORIZATION.downcase] = @signer.sign(@config.credentials,
                                                                    GET,
                                                                    path,
                                                                    headers,
                                                                    params,
                                                                    options['timestamp'],
                                                                    options['expiration_in_seconds'] || 1800,
                                                                    options['headers_to_sign'])
                url = url + Utils.url_encode_except_slash(path)
                query_str = Utils.get_canonical_querystring(params, false)
                url += "?#{query_str}" unless query_str.to_s.empty?
                url
            end

            # Get meta of object.
            def get_object_meta_data(bucket_name, key)
                send_request(HEAD, bucket_name, {}, key)
            end

            # Copy one object to another object.
            def copy_object(source_bucket_name, source_key, target_bucket_name, target_key, options={})
                headers = options
                headers[BCE_COPY_SOURCE_IF_MATCH] = headers['etag'] unless headers['etag'].nil?
                if headers['user_metadata'].nil?
                    headers[BCE_COPY_METADATA_DIRECTIVE] = 'copy'
                else
                    headers[BCE_COPY_METADATA_DIRECTIVE] = 'replace'
                    populate_headers_with_user_metadata(headers)
                end

                headers[BCE_COPY_SOURCE] =
                    Utils.url_encode_except_slash("/#{source_bucket_name}/#{source_key}")

                send_request(PUT, target_bucket_name, {}, target_key, headers)
            end

            # Delete Object.
            def delete_object(bucket_name, key)
                send_request(DELETE, bucket_name, {}, key)
            end

            # Delete Multiple Objects.
            def delete_multiple_objects(bucket_name, key_list)
                params = { delete: "" }
                key_arr = []
                key_list.each { |item| key_arr << { key: item } }
                body = { objects: key_arr }.to_json
                send_request(POST, bucket_name, params, "", {}, body)
            end

            # Initialize multi_upload_file.
            def initiate_multipart_upload(bucket_name, key, options={})
                params = { uploads: "" }
                headers = { BOS_STORAGE_CLASS => "STANDARD" }
                headers.merge! options
                send_request(POST, bucket_name, params, key, headers)
            end

            # Upload a part.
            def upload_part(bucket_name, key, upload_id, part_number, part_size, part_fp=nil, part_md5=nil, &block)
                params={ partNumber: part_number, uploadId: upload_id }
                if part_number < MIN_PART_NUMBER || part_number > MAX_PART_NUMBER
                        raise BceClientException.new(sprintf("Invalid part_number %d. The valid range is from %d to %d.",
                                                             part_number, MIN_PART_NUMBER, MAX_PART_NUMBER))
                end
                if part_size > MAX_PUT_OBJECT_LENGTH
                        raise BceClientException.new(sprintf("Single part length should be less than %d. ",
                                                             MAX_PUT_OBJECT_LENGTH))
                end

                headers = { CONTENT_LENGTH => part_size,
                            CONTENT_TYPE => OCTET_STREAM_TYPE
                }
                headers[CONTENT_MD5] = part_md5 unless part_md5.nil?
                send_request(POST, bucket_name, params, key, headers, part_fp, &block)
            end

            # Upload a part from file.
            def upload_part_from_file(bucket_name, key, upload_id, part_number,
                                      part_size, file_name, offset=0, part_md5=nil)

                left_size = part_size
                buf_size = @config.send_buf_size
                upload_part(bucket_name, key, upload_id, part_number, part_size) do |buf_writer|
                    File.open(file_name, "r") do |part_fp|
                        part_fp.seek(offset)
                        bytes_to_read = left_size > buf_size ? buf_size : left_size
                        until left_size <= 0
                            buf_writer << part_fp.read(bytes_to_read)
                            left_size -= bytes_to_read
                        end
                    end
                end
            end

            # Copy part.
            def upload_part_copy(source_bucket_name, source_key, target_bucket_name, target_key, upload_id,
                                 part_number, part_size, offset, options={})
                headers = options
                params={ partNumber: part_number, uploadId: upload_id }

                populate_headers_with_user_metadata(headers) unless headers['user_metadata'].nil?
                headers[BCE_COPY_SOURCE_IF_MATCH] = headers['etag'] unless headers['etag'].nil?
                headers[BCE_COPY_SOURCE_RANGE] = sprintf("bytes=%d-%d", offset, offset + part_size - 1)
                headers[BCE_COPY_SOURCE] =
                    Utils.url_encode_except_slash("/#{source_bucket_name}/#{source_key}")
                send_request(PUT, target_bucket_name, params, target_key, headers)

            end

            # After finish all the task, complete multi_upload_file.
            def complete_multipart_upload(bucket_name, key,upload_id, part_list, options={})
                headers = options
                params = { uploadId: upload_id }

                populate_headers_with_user_metadata(headers) unless headers['user_metadata'].nil?
                part_list.each { |part| part['eTag'].gsub!("\"", "") }
                body = { parts: part_list }.to_json
                send_request(POST, bucket_name, params, key, headers, body)
            end

            # Abort upload a part which is being uploading.
            def abort_multipart_upload(bucket_name, key, upload_id)
                params = { uploadId: upload_id }
                send_request(DELETE, bucket_name, params, key)
            end

            # List all the parts that have been upload success.
            def list_parts(bucket_name, key, upload_id, options={})
                params = { uploadId: upload_id }
                params.merge! options
                send_request(GET, bucket_name, params, key)
            end

            # List all Multipart upload task which haven't been ended.(Completed Init_MultiPartUpload
            # but not completed Complete_MultiPartUpload or Abort_MultiPartUpload).
            def list_multipart_uploads(bucket_name, options={})
                params = { uploads: "" }
                params.merge! options
                send_request(GET, bucket_name, params)
            end

            # Get object acl.
            def get_object_acl(bucket_name, key)
                params = { acl: "" }
                send_request(GET, bucket_name, params, key)
            end

            # Set object acl by body.
            def set_object_acl(bucket_name, key, acl)
                params = { acl: "" }
                headers = { CONTENT_TYPE => JSON_TYPE }
                body = { accessControlList: acl }.to_json
                send_request(PUT, bucket_name, params, key, headers, body)
            end

            # Set object acl by headers.
            def set_object_canned_acl(bucket_name, key, canned_acl={})
                params = { acl: "" }
                send_request(PUT, bucket_name, params, key, canned_acl)
            end

            # Delete object acl.
            def delete_object_acl(bucket_name, key)
                params = { acl: "" }
                send_request(DELETE, bucket_name, params, key)
            end

            def send_request(http_method, bucket_name="", params={}, key="", headers={}, body="", save_path=nil, &block)
                path = Utils.append_uri("/", bucket_name, key)
                body, headers = @http_client.send_request(@config, @signer, http_method, path, params, headers, body, save_path, &block)
                # Generate result from headers and body
                Utils.generate_response(headers, body)
            end

            def get_range_header_dict(range)
                raise BceClientException.new("range type should be a array") unless range.is_a? Array
                raise BceClientException.new("range should have length of 2") unless range.length == 2
                raise BceClientException.new("range all element should be integer") unless range.all? { |i| i.is_a?(Integer) }
                { RANGE => "bytes=#{range[0]}-#{range[1]}" }
            end

            def populate_headers_with_user_metadata(headers)
                meta_size = 0
                user_metadata = headers['user_metadata']
                raise BceClientException.new("user_metadata should be of type hash.") unless user_metadata.is_a? Hash

                user_metadata.each do |k, v|
                    k = k.encode("UTF-8")
                    v = v.encode("UTF-8")
                    normalized_key = BCE_USER_METADATA_PREFIX + k
                    headers[normalized_key] = v
                    meta_size += normalized_key.length
                    meta_size += v.length
                end

                if meta_size > MAX_USER_METADATA_SIZE
                    raise BceClientException.new("Metadata size should not be greater than #{MAX_USER_METADATA_SIZE}")
                end
                headers.delete('user_metadata')
            end

        end
    end
end


