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

  describe "#send_notifications_to_users" do

    it "should call #notifications with (:ios) on a NotificationsGenerator instance" do
      NotificationsGenerator.any_instance.should_receive(:notifications).with(:ios)
      service.send_notifications_to_users
    end

    it "should call #notifications with (:android) on a NotificationsGenerator instance" do
      NotificationsGenerator.any_instance.should_receive(:notifications).with(:android)
      service.send_notifications_to_users
    end

  end

end
