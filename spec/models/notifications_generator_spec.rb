require 'spec_helper'

describe "NotificationsGenerator" do

  let(:default_message){
    {random_hash_key: "random value"}.to_json
  }

  let(:ios_specific_fields){
    {ios_stuff: "hi"}.to_json
  }

  let(:android_specific_fields){
    {android_stuff: "hi"}.to_json
  }


  let(:apn_users){
    10.times.map do
      user = FactoryGirl.create(:user)
      user.apn_device_tokens.build(apn_device_token: "hahahdasdf").save!
      user.notifications.build(message: default_message, ios_specific_fields: ios_specific_fields, android_specific_fields: android_specific_fields).save!
      user
    end +

    # users with multiple apn device tokens
    10.times.map do
      user = FactoryGirl.create(:user)
      user.apn_device_tokens.build(apn_device_token: "hahahdaasdfasfsdf").save!
      user.apn_device_tokens.build(apn_device_token: "da25tasdgt3").save!
      user.apn_device_tokens.build(apn_device_token: "asdfafasf").save!
      user.notifications.build(message: default_message, ios_specific_fields: ios_specific_fields, android_specific_fields: android_specific_fields).save!
      user
    end
  }

  let(:gcm_users){
    10.times.map do
      user = FactoryGirl.create(:user)
      user.gcm_device_tokens.build(gcm_registration_id: "hahahdas1234df").save!
      user.notifications.build(message: default_message, ios_specific_fields: ios_specific_fields, android_specific_fields: android_specific_fields).save!
      user
    end
  }

  let(:apn_and_gcm_users){
    10.times.map do
      user = FactoryGirl.create(:user)
      user.apn_device_tokens.build(apn_device_token: "hahah42dasdf").save!
      user.gcm_device_tokens.build(gcm_registration_id: "hahahdas1234df").save!
      user.notifications.build(message: default_message, ios_specific_fields: ios_specific_fields, android_specific_fields: android_specific_fields).save!
      user
    end
  }

  describe "initialization" do

    it "should not fail" do
      expect{
        NotificationsGenerator.new(users: apn_users)
      }.to_not raise_error
    end

    it "should set the generator's @users instance variable to what was passed in" do
      ng = NotificationsGenerator.new(users: apn_users)
      ng.users.should eq(apn_users)
    end

  end

  describe "#notifications" do

    context "APN users" do

      before(:each) do
        @notifications_generator = NotificationsGenerator.new(users: apn_users)
      end

      context "type set to ios" do

        it "should not fail" do
          expect{
            @notifications_generator.notifications(:ios)
          }.to_not raise_error
        end

        it "should return an array" do
          @notifications_generator.notifications(:ios).should be_a(Array)
        end

        it "should return an array with APN::notifications" do
          @notifications_generator.notifications(:ios).each do |e|
            e.should be_a(APNS::Notification)
          end
        end

      end

      context "type set to android" do

        it "return an empty array" do
          @notifications_generator.notifications(:android).should be_empty
        end

      end

    end

    context "GCM users" do

      before(:each) do
        @notifications_generator = NotificationsGenerator.new(users: gcm_users)
      end

      context "type set to android" do

        it "should not fail" do
          expect{
            @notifications_generator.notifications(:android)
          }.to_not raise_error
        end

        it "should return an array" do
          @notifications_generator.notifications(:android).should be_a(Array)
        end

        it "should return an array with APN::notifications" do
          @notifications_generator.notifications(:android).each do |e|
            e.should be_a(GCM::Notification)
          end
        end

      end

      context "type set to ios" do

        it "return an empty array" do
          @notifications_generator.notifications(:ios).should be_empty
        end

      end

    end

    context "APN and GCM users" do

      before(:each) do
        @notifications_generator = NotificationsGenerator.new(users: apn_and_gcm_users)
      end

      context "type set to android" do

        it "should return an array" do
          @notifications_generator.notifications(:android).should be_a(Array)
        end

        it "should return an array with APN::notifications" do
          @notifications_generator.notifications(:android).each do |e|
            e.should be_a(GCM::Notification)
          end
        end

      end

      context "type set to ios" do

        it "should return an array" do
          @notifications_generator.notifications(:ios).should be_a(Array)
        end

        it "should return an array with APN::notifications" do
          @notifications_generator.notifications(:ios).each do |e|
            e.should be_a(APNS::Notification)
          end
        end

      end

    end

  end

  describe "#clear_users_notifications!" do

    it "should clear all the notifications for each user in @users" do
      notifications_generator = NotificationsGenerator.new(users: apn_and_gcm_users)
      notifications_generator.clear_users_notifications!
      apn_and_gcm_users.each do |u|
        u.notifications.should be_empty
      end
    end

  end

end
