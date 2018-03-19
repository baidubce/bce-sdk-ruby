require 'spec_helper'

module Baidubce
    module Auth

        RSpec.describe BceV1Signer do

            before :each do
                @signer = BceV1Signer.new
            end

            it "should get canonical uri path" do
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

        end
    end
end

