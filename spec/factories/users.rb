FactoryGirl.define do
  factory :user do |u|
    u.sequence(:unique_hash){|n| "#{n}"}
    u.association(:service)
  end
end
