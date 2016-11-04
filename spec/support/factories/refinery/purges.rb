
FactoryGirl.define do
  factory :purge, :class => Refinery::Cloudflare::Purge do
    sequence(:context) { |n| "refinery#{n}" }
  end
end

