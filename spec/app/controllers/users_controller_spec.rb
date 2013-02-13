require 'spec_helper'

describe "UsersController", :type => :controller do

  before(:each) do
    @service = FactoryGirl.create(:service)
  end

  describe "POST /users" do

    context "with mobile credentials" do

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

    end

  end

end
