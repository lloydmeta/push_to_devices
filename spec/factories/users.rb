FactoryGirl.define do
  factory :user do |u|
    u.sequence(:unique_hash){|n| "#{n}"}
    u.association(:service)

    factory :user_with_apn_token do
      after(:create) do |user, evaluator|
        FactoryGirl.create(:apn_device_token, user: user)
      end
    end

    factory :user_with_gcm_token do
      after(:create) do |user, evaluator|
        FactoryGirl.create(:gcm_device_token, user: user)
      end
    end

    factory :user_with_tokens do
      after(:create) do |user, evaluator|
        FactoryGirl.create(:apn_device_token, user: user)
        FactoryGirl.create(:gcm_device_token, user: user)
      end
    end
  end
end
