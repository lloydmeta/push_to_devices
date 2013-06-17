FactoryGirl.define do
  factory :notification do |u|
    u.association(:user)
    u.sequence(:ios_specific_fields){|n|
      {alert: "ios random value #{n}"}.to_json
    }
    u.sequence(:android_specific_fields){|n|
      {
        data: {text: "android random value #{n}", title: "bloop #{n}"},
        options: {time_to_live: 200}
      }.to_json
    }
  end
end
