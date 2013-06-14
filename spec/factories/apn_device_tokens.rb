FactoryGirl.define do
  factory :apn_device_token do |u|
    u.sequence(:apn_device_token){|n| "#{n}"}
    u.association(:user)
  end
end
