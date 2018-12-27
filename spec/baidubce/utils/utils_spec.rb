require 'spec_helper'

module Baidubce

    RSpec.describe Utils do

        it "parse url host" do
            bce_credentials = Auth::BceCredentials.new("your ak", "your sk")
            endpoint = "http://bj.bcebos.com"
            conf = BceClientConfiguration.new(bce_credentials, endpoint)

            url, host = Utils.parse_url_host(conf)
            expect(url).to eq(endpoint)
            expect(host).to eq("bj.bcebos.com")

            endpoint = "test.bcebos.com"
            conf = BceClientConfiguration.new(bce_credentials, endpoint)

            url, host = Utils.parse_url_host(conf)
            expect(url).to eq("http://" + endpoint)
            expect(host).to eq(endpoint)

            endpoint = "test.bcebos.com:8080"
            conf = BceClientConfiguration.new(bce_credentials, endpoint)

            url, host = Utils.parse_url_host(conf)
            expect(url).to eq("http://" + endpoint)
            expect(host).to eq(endpoint)

        end

        it "append uri" do
            path = Utils.append_uri("/", "中文bucket//", "object")
            expect(path).to eq("/中文bucket/object")
        end

        it "encode url except slash" do
            path = "bucket/object"

            encoded_path = Utils.url_encode_except_slash(path)
            expect(encoded_path).to eq("bucket/object")

            path = "中文bucket/中文object"

            encoded_path = Utils.url_encode_except_slash(path)
            expect(encoded_path).to eq("%E4%B8%AD%E6%96%87bucket/%E4%B8%AD%E6%96%87object")

        end

        it "get canonical querystring" do
            params = { a: 'va', 'b' => 'vb' }

            query_str = Utils.get_canonical_querystring(params, true)
            expect(query_str).to eq("a=va&b=vb")

            params = { A: '中文value', 'b' => '' }

            query_str = Utils.get_canonical_querystring(params, true)
            expect(query_str).to eq("A=%E4%B8%AD%E6%96%87value&b=")

        end

        it "generate response from headers and body" do

            headers = { :date=>"Mon, 19 Mar 2018 08:40:34 GMT",
                        :content_type=>"application/json;",
                        :x_bce_meta_key1=>"value1" }

            body = '{"bucket":"ruby-test-bucket","key":"multi_file_abort",
                         "uploadId":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}'

            resp = Utils.generate_response(headers, body, false)
            expected_body = { "bucket"=>"ruby-test-bucket", "key"=>"multi_file_abort",
                              "uploadId"=>"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }
            expect(resp).to eq(expected_body)

            body = ''
            headers = { "date"=>"Mon, 19 Mar 2018 08:40:34 GMT",
                        "content-type"=>"application/json;",
                        "user-metadata" => { "key1" => "value1" } }

            resp = Utils.generate_response(headers, body, false)
            expect(resp).to eq(headers)

            body = '{\"hello\":\"goodbye\"}'
            resp = Utils.generate_response(headers, body, true)
            expect(resp).to eq(body)

        end

    end
end

