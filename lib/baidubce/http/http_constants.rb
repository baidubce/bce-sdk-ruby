# Copyright 2017 Baidu, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License") you may not use this file
# except in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the
# License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific language governing permissions
# and limitations under the License.

# This module defines string constants for HTTP

module Baidubce
    module Http

        # HTTP Content Types
        JSON_TYPE         = 'application/json; charset=utf-8'
        OCTET_STREAM_TYPE = 'application/octet-stream'

        # HTTP Methods
        GET    = 'GET'
        PUT    = 'PUT'
        POST   = 'POST'
        DELETE = 'DELETE'
        HEAD   = 'HEAD'

        # HTTP Headers
        AUTHORIZATION = "Authorization"

        CACHE_CONTROL = "Cache-Control"

        CONTENT_DISPOSITION = "Content-Disposition"

        CONTENT_ENCODING = "Content-Encoding"

        CONTENT_LENGTH = "Content-Length"

        CONTENT_MD5 = "Content-MD5"

        CONTENT_RANGE = "Content-Range"

        CONTENT_TYPE = "Content-Type"

        DATE = "Date"

        ETAG = "ETag"

        EXPIRES = "Expires"

        HOST = "Host"

        LAST_MODIFIED = "Last-Modified"

        RANGE = "Range"

        SERVER = "Server"

        USER_AGENT = "User-Agent"

        # BCE Common HTTP Headers

        BCE_PREFIX = "x-bce-"

        BCE_ACL = "x-bce-acl"

        BCE_CONTENT_SHA256 = "x-bce-content-sha256"

        BCE_CONTENT_CRC32 = "x-bce-content-crc32"

        BCE_COPY_METADATA_DIRECTIVE = "x-bce-metadata-directive"

        BCE_COPY_SOURCE = "x-bce-copy-source"

        BCE_COPY_SOURCE_IF_MATCH = "x-bce-copy-source-if-match"

        BCE_COPY_SOURCE_IF_MODIFIED_SINCE = "x-bce-copy-source-if-modified-since"

        BCE_COPY_SOURCE_IF_NONE_MATCH = "x-bce-copy-source-if-none-match"

        BCE_COPY_SOURCE_IF_UNMODIFIED_SINCE = "x-bce-copy-source-if-unmodified-since"

        BCE_COPY_SOURCE_RANGE = "x-bce-copy-source-range"

        BCE_DATE = "x-bce-date"

        BCE_USER_METADATA_PREFIX = "x-bce-meta-"

        BCE_REQUEST_ID = "x-bce-request-id"

        # BOS HTTP Headers

        BOS_DEBUG_ID = "x-bce-bos-debug-id"

        BOS_STORAGE_CLASS = "x-bce-storage-class"

        # STS HTTP Headers

        STS_SECURITY_TOKEN = "x-bce-security-token"
    end
end
