require 'spec_helper'

describe "Service Model" do
  let(:service) { Service.new }

  it 'can be created' do
    service.should_not be_nil
  end

  context "api credential values" do

    it "server_client_id should not be nil" do
      service.server_client_id.should_not be_nil
    end

    it "server_client_secret should not be nil" do
      service.server_client_secret.should_not be_nil
    end

    it "mobile_client_id should not be nil" do
      service.mobile_client_id.should_not be_nil
    end

    it "mobile_client_secret should not be nil" do
      service.mobile_client_secret.should_not be_nil
    end

  end

end
