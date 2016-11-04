require 'spec_helper'

module Refinery
  module Cloudflare
    describe Purge do
      describe "validations", type: :model do
        subject do
          FactoryGirl.create(:purge,
          :context => "Refinery CMS")
        end

        it { should be_valid }
        its(:errors) { should be_empty }
        its(:context) { should == "Refinery CMS" }
      end
    end
  end
end
