FactoryGirl.define do
  factory :gcm_device_token do |u|
    u.sequence(:gcm_registration_id){|n| "#{n}"}
    u.association(:user)
  end
end
