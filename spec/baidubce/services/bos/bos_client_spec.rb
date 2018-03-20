require 'spec_helper'

module Baidubce
    module Services

        RSpec.describe BosClient do

            before :each do
                credentials = Baidubce::Auth::BceCredentials.new(
                    "your ak",
                    "your sk"
                )
                conf = Baidubce::BceClientConfiguration.new(
                    credentials,
                    "http://bj.bcebos.com"
                )
                @client = Baidubce::Services::BosClient.new(conf)
            end

            it "generate response from headers and body" do

                headers = { :date=>"Mon, 19 Mar 2018 08:40:34 GMT",
                            :content_type=>"application/json;" }

                body = '{"bucket":"ruby-test-bucket","key":"multi_file_abort",
                         "uploadId":"ed26564508494f40113dc2ddea3bb973"}'

                resp = @client.generate_response(headers, body)
                expected_body = { "bucket"=>"ruby-test-bucket", "key"=>"multi_file_abort",
                                 "uploadId"=>"ed26564508494f40113dc2ddea3bb973" }
                expect(resp).to eq(expected_body)

                body = ''
                resp = @client.generate_response(headers, body)
                expect(resp).to eq(headers)

                body = nil
                resp = @client.generate_response(headers, body)
                expect(resp).to eq(headers)

            end

            it "get range header dict" do
                expect{ @client.get_range_header_dict(1) }.
                    to raise_error(BceClientException, "range type should be a array")

                expect{ @client.get_range_header_dict([1, 2, 3]) }.
                    to raise_error(BceClientException, "range should have length of 2")

                expect{ @client.get_range_header_dict([1, 'str']) }.
                    to raise_error(BceClientException, "range all element should be integer")

                dict = @client.get_range_header_dict([1, 2])
                expect(dict).to eq({ Baidubce::Http::RANGE => "bytes=1-2" })

            end

            it "populate headers with user metadata" do

                user_metadata = { "key1" => "value1" }
                headers ={
                    'Content-Disposition' => 'inline',
                    'user_metadata' => user_metadata
                }

                @client.populate_headers_with_user_metadata(headers)

                expected_headers = {
                    'Content-Disposition' => 'inline',
                    'x-bce-meta-key1' => 'value1'
                }
                expect(headers).to eq(expected_headers)
            end

        end

    end
end


