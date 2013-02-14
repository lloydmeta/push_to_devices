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

    it "should call #notifications with (:ios) and (:android) on a NotificationsGenerator instance" do
      NotificationsGenerator.any_instance.should_receive(:notifications).with(:ios)
      NotificationsGenerator.any_instance.should_receive(:notifications).with(:android)
      service.send_notifications_to_users
    end

    it "should call #clear_users_notifications! " do
      NotificationsGenerator.any_instance.should_receive(:clear_users_notifications!)
      service.send_notifications_to_users
    end

  end

  # Commented out for now because I keep getting SSL errors..
  # Need to figure out how to disable or fix it
  # context "sending notifications" do

  #   before(:each) do
  #     @service = FactoryGirl.create(:service)
  #   end

  #   describe "#send_apn_notifications" do

  #     it "should make requests to a specific address" do
  #       notifications = 10.times.map do
  #         APNS::Notification.new("1234", {test: "lol"})
  #       end

  #       @service.send_apn_notifications(notifications)
  #       a_request(:any, "fake_apn.com").should have_been_made
  #     end
  #   end

  # end

end
