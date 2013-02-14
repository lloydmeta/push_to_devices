FactoryGirl.define do
  factory :service do
    name Faker::Name.first_name
    apn_pem_path "#{Padrino.root}/spec/fixtures/pem/fake_cert.pem"
    gcm_api_key "asdfa12341234"
  end
end
