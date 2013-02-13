require 'spec_helper'

describe "UsersController", :type => :controller do

  before(:each) do
    @service = FactoryGirl.create(:service)
  end

  describe "POST /users" do

    context "with mobile credentials" do

      it "should fail if unique_hash not present" do
        post '/users', params={}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
        last_response.should_not be_successful
      end

      context "only with unique_hash" do

        it "should create a user" do
          expect{
            post '/users', params={"unique_hash" => "hahahlalala1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to change(User, :count).by(1)
        end

        it "should return the current created user" do
          post '/users', params={"unique_hash" => "hahahlalala1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          JSON.parse(last_response.body)["unique_hash"].should eq("hahahlalala1234")
        end

        it "should not create 2 users for when using the same @service and same unique_hash" do
          post '/users', params={"unique_hash" => "hahahlalala1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          expect{
            post '/users', params={"unique_hash" => "hahahlalala1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to_not change(User, :count)
        end

        it "should create 2 users when using different services despite the same unique_hash" do
          another_service = FactoryGirl.create(:service)
          expect{
            post '/users', params={"unique_hash" => "hahahlalala1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
            post '/users', params={"unique_hash" => "hahahlalala1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(another_service.mobile_client_id, another_service.mobile_client_secret))
          }.to change(User, :count).by(2)
        end

      end

    end # end only unique_hash

    context "with unique_hash and apn_device_token" do

      context "new user, new apn_device_token" do

        it "should create a new user" do
          expect{
            post '/users', params={"unique_hash" => "hahahlalala1234", "apn_device_token" => "asdf1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to change(User, :count).by(1)
        end

        it "should create a new apn_device_token on the user" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "apn_device_token" => "asdf1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          User.find_by(unique_hash: "hahahlalala1234").apn_device_tokens.count.should eq(1)
        end

        it "should create a new apn_device_token_on this user that contains the same apn_device_token" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "apn_device_token" => "asdf1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          User.find_by(unique_hash: "hahahlalala1234").apn_device_tokens.first.device_id.should eq("asdf1234")
        end

      end

      context "old user, new apn_device_token" do

        before(:each) do
          user = User.create(unique_hash: "hahahlalala1234", service: @service)
          user.apn_device_tokens.build(apn_device_token: "xyz1234").save!
        end

        it "should not create a new user" do
          expect{
            post '/users', params={"unique_hash" => "hahahlalala1234", "apn_device_token" => "asdf1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to_not change(User, :count)
        end

        it "should create a new apn_device_token on the user" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "apn_device_token" => "asdf1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          User.find_by(unique_hash: "hahahlalala1234").apn_device_tokens.count.should eq(2)
        end

      end

      context "old user, old apn_device_token" do

        before(:each) do
          user = User.create(unique_hash: "hahahlalala1234", service: @service)
          user.apn_device_tokens.build(apn_device_token: "asdf1234").save!
        end

        it "should not create a new user" do
          expect{
            post '/users', params={"unique_hash" => "hahahlalala1234", "apn_device_token" => "asdf1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to_not change(User, :count)
        end

        it "should not create a new apn_device_token on the user" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "apn_device_token" => "asdf1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          User.find_by(unique_hash: "hahahlalala1234").apn_device_tokens.count.should eq(1)
        end

      end

    end

    context "with unique_hash and gcm_registration_id" do

      context "new user, new gcm_registration_id" do

        it "should create a new user" do
          expect{
            post '/users', params={"unique_hash" => "hahahlalala1234", "gcm_registration_id" => "asdf1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to change(User, :count).by(1)
        end

        it "should create a new gcm_device_token on the user" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "gcm_registration_id" => "asdf1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          User.find_by(unique_hash: "hahahlalala1234").gcm_device_tokens.count.should eq(1)
        end


        it "should create a new gcm_device_token this user that contains the same apn_device_token" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "gcm_registration_id" => "asdf1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          User.find_by(unique_hash: "hahahlalala1234").gcm_device_tokens.first.device_id.should eq("asdf1234")
        end

      end

      context "old user, new gcm_registration_id" do

        before(:each) do
          user = User.create(unique_hash: "hahahlalala1234", service: @service)
          user.gcm_device_tokens.build(gcm_registration_id: "xyz1234").save!
        end

        it "should not create a new user" do
          expect{
            post '/users', params={"unique_hash" => "hahahlalala1234", "gcm_registration_id" => "asdf1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to_not change(User, :count)
        end

        it "should create a new gcm_device_token on the user" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "gcm_registration_id" => "asdf1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          User.find_by(unique_hash: "hahahlalala1234").gcm_device_tokens.count.should eq(2)
        end

      end

      context "old user, old gcm_registration_id" do

        before(:each) do
          user = User.create(unique_hash: "hahahlalala1234", service: @service)
          user.gcm_device_tokens.build(gcm_registration_id: "asdf1234").save!
        end

        it "should not create a new user" do
          expect{
            post '/users', params={"unique_hash" => "hahahlalala1234", "gcm_registration_id" => "asdf1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to_not change(User, :count)
        end

        it "should not create a new gcm_device_token on the user" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "gcm_registration_id" => "asdf1234"}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          User.find_by(unique_hash: "hahahlalala1234").gcm_device_tokens.count.should eq(1)
        end

      end

    end

  end

end
