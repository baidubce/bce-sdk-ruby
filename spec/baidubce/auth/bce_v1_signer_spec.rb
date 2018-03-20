require 'spec_helper'

module Baidubce
    module Auth

        RSpec.describe BceV1Signer do

            before :each do
                @signer = BceV1Signer.new
            end

            it "get canonical headers" do

                headers = { 'host' => 'x.x.x', 'CONTENT-length' => 10,  'x-bce-a' => 'value' }
                canonical_headers, header_arr = @signer.get_canonical_headers(headers, nil)

                expect(canonical_headers).to eq("content-length:10\nhost:x.x.x\nx-bce-a:value")
                expect(header_arr).to eq(["content-length", "host", "x-bce-a"])

                headers_to_sign = ["host", "content-md5", "date"]
                headers = { 'host' => 'x.x.x', 'CONTENT-length' => 10,
                            'x-bce-a' => 'value', 'date' => '2017-01-02' }
                canonical_headers, header_arr = @signer.get_canonical_headers(headers, headers_to_sign)

                expect(canonical_headers).to eq("date:2017-01-02\nhost:x.x.x")
                expect(header_arr).to eq(["date", "host"])

            end

            it "get canonical uri path" do
                encoded_path = @signer.get_canonical_uri_path("")
                expect(encoded_path).to eq("/")

                encoded_path = @signer.get_canonical_uri_path(nil)
                expect(encoded_path).to eq("/")

                path = "中文bucket/中文object"

                encoded_path = @signer.get_canonical_uri_path(path)
                expect(encoded_path).to eq("/%E4%B8%AD%E6%96%87bucket/%E4%B8%AD%E6%96%87object")

                path = "/bucket/object"

                encoded_path = @signer.get_canonical_uri_path(path)
                expect(encoded_path).to eq("/bucket/object")

            end

            it "sign to create authorization" do

            end

        end
    end
end

