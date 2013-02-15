FactoryGirl.define do
  factory :service do
    name Faker::Name.first_name
    pemfile File.open("#{Padrino.root}/spec/fixtures/pem/fake_cert.pem")
    apn_host "fake_apple.com"
    gcm_api_key "asdfa12341234"
    gcm_host "https://fake.google.com/fakegcm/send"
  end
end
