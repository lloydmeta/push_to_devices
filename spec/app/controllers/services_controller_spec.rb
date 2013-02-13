require 'spec_helper'

describe "ServicesController", :type => :controller do

  before(:each) do
    @service = FactoryGirl.create(:service)
  end

  describe "get /" do

    context "with server credentials" do

      it "should return the current service" do
        get '/services/me', params={}, rack_env=credentials_to_headers(server_api_auth_params(@service.server_client_id, @service.server_client_secret))
        JSON.parse(last_response.body)["server_client_secret"].should eq(@service.server_client_secret)
      end

    end

    context "with mobile credentials" do

      it "should return the current service" do
        get '/services/me', params={}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
        JSON.parse(last_response.body)["mobile_client_secret"].should eq(@service.mobile_client_secret)
      end

    end

    context "with invalid" do

      it "client_id should not be successful" do
        get '/services/me', params={}, rack_env=credentials_to_headers(server_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
        last_response.should_not be_successful
      end

      it "client_signature should not be successful" do
        get '/services/me', params={}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, "hahah lala"))
        last_response.should_not be_successful
      end

      it "timestamp should not be successful" do
        get '/services/me', params={}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret).merge(:timestamp => 10.days.ago))
        last_response.should_not be_successful
      end

    end

  end

end
