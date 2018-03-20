require 'spec_helper'

module Baidubce
    module Auth

        RSpec.describe BceCredentials do

            it "create BceCredentials with ak and sk" do
                bce_credentials = BceCredentials.new("your ak", "your sk")
                expect(bce_credentials).to have_attributes(
                    :access_key_id => "your ak", :secret_access_key => "your sk"
                )
            end

        end
    end
end

