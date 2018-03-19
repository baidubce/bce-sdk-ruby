require 'spec_helper'

module Baidubce

    RSpec.describe Utils do

        it "should encode url except slash" do
        path = "bucket/object"

        encoded_path = Utils.url_encode_except_slash(path)
        expect(encoded_path).to eq("bucket/object")

        path = "中文bucket/中文object"

        encoded_path = Utils.url_encode_except_slash(path)
        expect(encoded_path).to eq("%E4%B8%AD%E6%96%87bucket/%E4%B8%AD%E6%96%87object")

        end

        it "should get canonical querystring" do
            params = { a: 'va', 'b' => 'vb' }

            query_str = Utils.get_canonical_querystring(params, true)
            expect(query_str).to eq("a=va&b=vb")
            
            params = { A: '中文value', 'b' => '' }

            query_str = Utils.get_canonical_querystring(params, true)
            expect(query_str).to eq("A=%E4%B8%AD%E6%96%87value&b=")

        end

    end
end

