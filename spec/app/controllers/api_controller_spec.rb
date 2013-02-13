require 'spec_helper'

describe "ApiController", :type => :controller do

  before(:each) do
    @service = FactoryGirl.create(:service)
  end

  describe "get /" do

    context "with server credentials" do

      it "should return the current service" do
        get '/', params={}, rack_env=credentials_to_headers(server_api_auth_params(@service.server_client_id, @service.server_client_secret))
        JSON.parse(last_response.body)["server_client_secret"].should eq(@service.server_client_secret)
      end

    end

    context "with mobile credentials" do

      it "should return the current service" do
        get '/', params={}, rack_env=credentials_to_headers(mobile_api_auth_params(@service.mobile_client_id, @service.mobile_client_secret))
        JSON.parse(last_response.body)["mobile_client_secret"].should eq(@service.mobile_client_secret)
      end

    end

  end

end
