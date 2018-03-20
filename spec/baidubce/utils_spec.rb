require 'spec_helper'

module Baidubce

    RSpec.describe Utils do

        it "parse url host" do
            bce_credentials = Baidubce::Auth::BceCredentials.new("your ak", "your sk")
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
            expect(path).to eq("/%E4%B8%AD%E6%96%87bucket%2F%2F/object")
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

    end
end

