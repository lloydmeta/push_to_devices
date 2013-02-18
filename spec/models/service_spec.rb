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

  context "#delete_user_apn_tokens_based_on_apple_feedback" do
    before(:each) do
      @service = FactoryGirl.create(:service)
      @service_user_unique_hash_1 = "asdf1234"
      @service_user_unique_hash_2 = "asdf12343"
      @service_user_unique_hash_3 = "asdf1234f"
      @user_1_apn_token = "asdf"
      @user_2_apn_token = "asdffadsf"
      @user_3_apn_token = "asdasfadsfdf"
      @service_user_1 = @service.users.create!(unique_hash: @service_user_unique_hash_1)
      @service_user_2 = @service.users.create!(unique_hash: @service_user_unique_hash_2)
      @service_user_3 = @service.users.create!(unique_hash: @service_user_unique_hash_3)
      @token_1 = @service_user_1.apn_device_tokens.build(apn_device_token: @user_1_apn_token)
      @token_2 = @service_user_2.apn_device_tokens.build(apn_device_token: @user_2_apn_token)
      @token_3 = @service_user_3.apn_device_tokens.build(apn_device_token: @user_3_apn_token)
      @token_1.save!
      @token_2.save!
      @token_3.save!
    end

    it "should delete the tokens reported as borked by Apple feedback" do
      @service.stub(:get_apn_feedback){[{token: @user_1_apn_token}, {token: @user_2_apn_token}, {token: @user_3_apn_token}]}
      @service.delete_user_apn_tokens_based_on_apple_feedback
      @service_user_1.reload
      @service_user_2.reload
      @service_user_3.reload
      @service_user_1.apn_device_tokens.should be_empty
      @service_user_2.apn_device_tokens.should be_empty
      @service_user_3.apn_device_tokens.should be_empty
    end
  end


  context "sending notifications" do

    before(:each) do
      @service = FactoryGirl.create(:service)
    end

    # Commented out for now because I keep getting SSL errors..
    # Need to figure out how to disable or fix it

    # describe "#send_apn_notifications" do

    #   it "should make requests to a specific address" do
    #     notifications = 10.times.map do
    #       APNS::Notification.new("1234", {test: "lol"})
    #     end

    #     @service.send_apn_notifications(notifications)
    #     a_request(:any, "fake_apn.com").should have_been_made
    #   end
    # end

    describe "#send_gcm_notifications" do

      it "should make requests to a specific address" do
        notifications = 10.times.map do
          GCM::Notification.new("1234", {test: "lol"})
        end

        @service.send_gcm_notifications(notifications)
        a_request(:any, "https://fake.google.com/fakegcm/send").should have_been_made.times(10)
      end
    end

  end

  describe "#batch_iterate_users" do

    it "should iterate over the default 1000 users at a time" do
      2000.times do
        FactoryGirl.create(:user, :service => service)
      end

      service.batch_iterate_users do |batch|
        batch.all.to_a.size.should satisfy{|batch_size| [1000, 0].include? batch_size}
      end
    end
  end

end
