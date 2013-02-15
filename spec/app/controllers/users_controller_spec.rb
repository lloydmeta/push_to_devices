require 'spec_helper'

describe "UsersController", :type => :controller do

  let(:ios_specific_fields){{badge: 5}}
  let(:android_specific_fields){{google_is_the_best: true}}
  let(:notification_data){{ios_specific_fields: ios_specific_fields, android_specific_fields: android_specific_fields}}

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
            post '/users', params={"unique_hash" => "hahahlalala1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to change(User, :count).by(1)
        end

        it "should return the current created user" do
          post '/users', params={"unique_hash" => "hahahlalala1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          JSON.parse(last_response.body)["unique_hash"].should eq("hahahlalala1234")
        end

        it "should not create 2 users for when using the same @service and same unique_hash" do
          post '/users', params={"unique_hash" => "hahahlalala1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          expect{
            post '/users', params={"unique_hash" => "hahahlalala1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to_not change(User, :count)
        end

        it "should create 2 users when using different services despite the same unique_hash" do
          another_service = FactoryGirl.create(:service)
          expect{
            post '/users', params={"unique_hash" => "hahahlalala1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
            post '/users', params={"unique_hash" => "hahahlalala1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(another_service.mobile_client_id, another_service.mobile_client_secret))
          }.to change(User, :count).by(2)
        end

      end

    end # end only unique_hash

    context "with unique_hash and apn_device_token" do

      context "new user, new apn_device_token" do

        it "should create a new user" do
          expect{
            post '/users', params={"unique_hash" => "hahahlalala1234", "apn_device_token" => "asdf1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to change(User, :count).by(1)
        end

        it "should create a new apn_device_token on the user" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "apn_device_token" => "asdf1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          User.find_by(unique_hash: "hahahlalala1234").apn_device_tokens.count.should eq(1)
        end

        it "should create a new apn_device_token_on this user that contains the same apn_device_token" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "apn_device_token" => "asdf1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
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
            post '/users', params={"unique_hash" => "hahahlalala1234", "apn_device_token" => "asdf1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to_not change(User, :count)
        end

        it "should create a new apn_device_token on the user" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "apn_device_token" => "asdf1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
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
            post '/users', params={"unique_hash" => "hahahlalala1234", "apn_device_token" => "asdf1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to_not change(User, :count)
        end

        it "should not create a new apn_device_token on the user" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "apn_device_token" => "asdf1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          User.find_by(unique_hash: "hahahlalala1234").apn_device_tokens.count.should eq(1)
        end

      end

    end

    context "with unique_hash and gcm_registration_id" do

      context "new user, new gcm_registration_id" do

        it "should create a new user" do
          expect{
            post '/users', params={"unique_hash" => "hahahlalala1234", "gcm_registration_id" => "asdf1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to change(User, :count).by(1)
        end

        it "should create a new gcm_device_token on the user" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "gcm_registration_id" => "asdf1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          User.find_by(unique_hash: "hahahlalala1234").gcm_device_tokens.count.should eq(1)
        end


        it "should create a new gcm_device_token this user that contains the same apn_device_token" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "gcm_registration_id" => "asdf1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
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
            post '/users', params={"unique_hash" => "hahahlalala1234", "gcm_registration_id" => "asdf1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to_not change(User, :count)
        end

        it "should create a new gcm_device_token on the user" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "gcm_registration_id" => "asdf1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
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
            post '/users', params={"unique_hash" => "hahahlalala1234", "gcm_registration_id" => "asdf1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          }.to_not change(User, :count)
        end

        it "should not create a new gcm_device_token on the user" do
          post '/users', params={"unique_hash" => "hahahlalala1234", "gcm_registration_id" => "asdf1234"}.to_json, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
          User.find_by(unique_hash: "hahahlalala1234").gcm_device_tokens.count.should eq(1)
        end

      end

    end

  end #end POST users

  context "POST users/:unique_hash/notifications" do

    before(:each) do
      @service_user_unique_hash = "asdf1234"
      @service_user = @service.users.create!(unique_hash: @service_user_unique_hash)
    end

    context "unique_hash is invalid" do

      it "should be successful" do
        post "/users/1234asdf/notifications", params=notification_data.to_json, rack_env=credentials_to_headers(server_api_auth_params(@service.server_client_id, @service.server_client_secret))
        last_response.should be_successful
      end

      it "should have an error message in the response" do
        post "/users/1234asdf/notifications", params=notification_data.to_json, rack_env=credentials_to_headers(server_api_auth_params(@service.server_client_id, @service.server_client_secret))
        JSON.parse(last_response.body)["error"].should_not be_nil
      end

    end

    context 'params["message"] only' do

      it "should create a new notification for the user" do
        @service_user.notifications.count.should eq(0)
        post "/users/#{@service_user_unique_hash}/notifications", params=notification_data.to_json, rack_env=credentials_to_headers(server_api_auth_params(@service.server_client_id, @service.server_client_secret))
        @service_user.reload
        @service_user.notifications.count.should eq(1)
      end

      it "should create a notification on the user with a messsage" do
        post "/users/#{@service_user_unique_hash}/notifications", params=notification_data.to_json, rack_env=credentials_to_headers(server_api_auth_params(@service.server_client_id, @service.server_client_secret))
        @service_user.reload
        @service_user.notifications.first.ios_specific_fields.should_not be_nil
      end

    end


    context 'ios_specific_fields' do

      it "should create a new notification for the user" do
        @service_user.notifications.count.should eq(0)
        post "/users/#{@service_user_unique_hash}/notifications", params=notification_data.to_json, rack_env=credentials_to_headers(server_api_auth_params(@service.server_client_id, @service.server_client_secret))
        @service_user.reload
        @service_user.notifications.count.should eq(1)
      end

      it "should create a notification on the user ios_specific_fields" do
        post "/users/#{@service_user_unique_hash}/notifications", params=notification_data.to_json, rack_env=credentials_to_headers(server_api_auth_params(@service.server_client_id, @service.server_client_secret))
        @service_user.reload
        @service_user.notifications.first.ios_specific_fields.should_not be_nil
      end

    end

    context 'android_specific_fields' do

      it "should create a new notification for the user" do
        @service_user.notifications.count.should eq(0)
        post "/users/#{@service_user_unique_hash}/notifications", params=notification_data.to_json, rack_env=credentials_to_headers(server_api_auth_params(@service.server_client_id, @service.server_client_secret))
        @service_user.reload
        @service_user.notifications.count.should eq(1)
      end

      it "should create a notification on the user with android_specific_fields" do
        post "/users/#{@service_user_unique_hash}/notifications", params=notification_data.to_json, rack_env=credentials_to_headers(server_api_auth_params(@service.server_client_id, @service.server_client_secret))
        @service_user.reload
        @service_user.notifications.first.android_specific_fields.should_not be_nil
      end

    end

    context 'ios_specific_fields and android_specific_fields ' do

      it "should create a new notification for the user" do
        @service_user.notifications.count.should eq(0)
        post "/users/#{@service_user_unique_hash}/notifications", params=notification_data.to_json, rack_env=credentials_to_headers(server_api_auth_params(@service.server_client_id, @service.server_client_secret))
        @service_user.reload
        @service_user.notifications.count.should eq(1)
      end

      it "should create a notification on the user with a messsage, ios_specific_fields and android_specific_fields" do
        post "/users/#{@service_user_unique_hash}/notifications", params=notification_data.to_json, rack_env=credentials_to_headers(server_api_auth_params(@service.server_client_id, @service.server_client_secret))
        @service_user.reload
        @service_user.notifications.first.ios_specific_fields.should_not be_nil
        @service_user.notifications.first.android_specific_fields.should_not be_nil
      end

    end

  end # end posting to users/:unique_hash_notifications

  context "POST users/notifications" do
    before(:each) do
      @service_user_unique_hash_1 = "asdf1234"
      @service_user_unique_hash_2 = "asdf12343"
      @service_user_unique_hash_3 = "asdf1234f"
      @service_user_1 = @service.users.create!(unique_hash: @service_user_unique_hash_1)
      @service_user_2 = @service.users.create!(unique_hash: @service_user_unique_hash_2)
      @service_user_3 = @service.users.create!(unique_hash: @service_user_unique_hash_3)
    end

    it "should create notifications for all the users that have hashes in the unique_hashes key" do
      @service_user_1.notifications.count.should eq(0)
      @service_user_2.notifications.count.should eq(0)
      @service_user_3.notifications.count.should eq(0)
      full_params = {unique_hashes: [@service_user_unique_hash_1, @service_user_unique_hash_2, @service_user_unique_hash_3]}.merge(notification_data)
      post "/users/notifications", params=full_params.to_json, rack_env=credentials_to_headers(server_api_auth_params(@service.server_client_id, @service.server_client_secret))
      @service_user_1.reload
      @service_user_2.reload
      @service_user_3.reload
      @service_user_1.notifications.count.should eq(1)
      @service_user_2.notifications.count.should eq(1)
      @service_user_3.notifications.count.should eq(1)
    end

  end

end
