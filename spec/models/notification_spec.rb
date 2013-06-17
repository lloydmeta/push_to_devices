require 'spec_helper'

describe "Notification Model" do

  let(:ios_specific_fields){
    {random_hash_key: "ios random value"}
  }

  let(:android_specific_fields){
    {
      data: {random_hash_key: "android random value"},
      options: {time_to_live: 200}
    }
  }

  let(:notification) {
    user = FactoryGirl.create(:user)
    user.notifications.build(
      ios_specific_fields: ios_specific_fields.to_json,
      android_specific_fields: android_specific_fields.to_json
    )
  }

  it 'can be created' do
    notification.should_not be_nil
  end

  it 'should have a user' do
    notification.user.should_not be_nil
  end

  context "validations" do

      let(:user){FactoryGirl.create(:user)}

      it "should be valid if it is a valid JSON string" do
        message = {value: 3}.to_json
        notification = user.notifications.build(ios_specific_fields: message)
        notification.should be_valid
      end

      it "should not be valid if it is not a valid JSON string" do
        broken_message = {value: 3}.to_json.chop
        notification = user.notifications.build(ios_specific_fields: broken_message)
        notification.should_not be_valid
      end

  end

  context "instance methods" do

    describe "#ios_version" do

      it "should return a merged hash containing the ios specific fields" do
        notification.ios_version.symbolize_keys.should eq(Notification::DEFAULT_NOTIFICATION_IOS.merge(ios_specific_fields))
      end

    end

    describe "#android_version" do

      it "should return a merged hash containing the android specific fields" do
        notification.android_version.to_json.should eq(android_specific_fields.to_json)
      end

    end

    describe "#sendable" do

      context "with/without APN token(s)" do

        it "should return an empty array for a user with no APN tokens" do
          notification = FactoryGirl.create(:notification)
          notification.sendable(:ios).should be_empty
        end

        it "should return 1 sendable notification for a notification with a user that only has 1 APN token" do
          user = FactoryGirl.create(:user_with_apn_token)
          notification = FactoryGirl.create(:notification, user: user)
          notification.sendable(:ios).size.should be 1
        end

        it "should return as many sendable notifications as the notification's user has APN tokens" do
          user = FactoryGirl.create(:user_with_apn_token)
          FactoryGirl.create(:apn_device_token, user: user)
          notification = FactoryGirl.create(:notification, user: user)
          notification.sendable(:ios).size.should be 2
        end

      end

      context "with/without GCM token(s)" do

        def sendable_gcm(notification)
          user = notification.user
          android_noti = notification.android_version
          GCM::Notification.new(user.gcm_device_tokens.map(&:device_id),  android_noti.delete(:data), android_noti.delete(:options))
        end

        it "should return nil for a user with no GCM tokens" do
          notification = FactoryGirl.create(:notification)
          notification.sendable(:android).should be_nil
        end

        it "should return a sendable notification with 1 GCM token in it for a notification with a user who only has 1 GCM token" do
          user = FactoryGirl.create(:user_with_gcm_token)
          notification = FactoryGirl.create(:notification, user: user)

          notification.sendable(:android).should eq sendable_gcm(notification)
        end

        it "should return a sendable notification with as many GCM tokens in it as the notificaiton's user has GCM tokens" do
          user = FactoryGirl.create(:user_with_gcm_token)
          FactoryGirl.create(:gcm_device_token, user: user)
          notification = FactoryGirl.create(:notification, user: user)

          notification.sendable(:android).should eq sendable_gcm(notification)
        end

      end

    end

  end

end
